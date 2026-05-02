import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/post_detail_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final CommunityPostApiService api;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.api,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowing = false;
  bool _isLoading = true;
  List<CommunityPost> _userPosts = [];
  int _followingCount = 0;
  int _followerCount = 0;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _isCurrentUser = _checkIsCurrentUser();
    _loadUserData();
  }

  bool _checkIsCurrentUser() {
    final currentUserId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return false;
    return currentUserId == widget.userId.toString();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch posts for this user
      final allPosts = await widget.api.getPosts();
      final userPosts = allPosts.where((p) => p.authorId == widget.userId).toList();

      // Check if we're already following this user from the loaded posts
      final isFollowed = userPosts.isNotEmpty ? userPosts.first.isFollowed : false;

      // Count unique followers from post data (approximation)
      // Real follower/following counts would need a dedicated API endpoint
      final postAuthors = <int>{};
      for (final p in allPosts) {
        postAuthors.add(p.authorId);
      }

      if (mounted) {
        setState(() {
          _userPosts = userPosts;
          _isFollowing = isFollowed;
          _isLoading = false;
          // These would come from a real API endpoint
          _followerCount = 0;
          _followingCount = 0;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleFollow() {
    setState(() => _isFollowing = !_isFollowing);
    // TODO: API call to follow/unfollow when backend supports it
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userName,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: AppColors.amber,
              backgroundColor: AppColors.navy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const Divider(height: 1, color: Colors.black12),
                    _buildPostsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.peach,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.peach.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            widget.userName,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Bio placeholder
          if (_isCurrentUser)
            Text(
              'Kelola profil Anda di Pengaturan',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Postingan', _userPosts.length),
              Container(
                width: 1,
                height: 30,
                color: AppColors.navy.withValues(alpha: 0.1),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem('Mengikuti', _followingCount),
              Container(
                width: 1,
                height: 30,
                color: AppColors.navy.withValues(alpha: 0.1),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem('Pengikut', _followerCount),
            ],
          ),
          const SizedBox(height: 20),

          // Follow / Edit profile button
          if (!_isCurrentUser)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? AppColors.navy : AppColors.amber,
                  foregroundColor: _isFollowing ? Colors.white : AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isFollowing ? 'Diikuti' : 'Ikuti',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            'Postingan',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_userPosts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.article_outlined, size: 48, color: AppColors.navy.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada postingan',
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _userPosts.length,
            separatorBuilder: (_, __) => Divider(
              color: AppColors.navy.withValues(alpha: 0.1),
              thickness: 1,
              height: 24,
            ),
            itemBuilder: (context, index) {
              final post = _userPosts[index];
              return _buildPostCard(post);
            },
          ),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post, api: widget.api),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imagePath!.startsWith('http') ? post.imagePath! : 'https://nutrify-app.my.id${post.imagePath!}',
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : AppColors.navy.withValues(alpha: 0.4),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likes}',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.navy.withValues(alpha: 0.4),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.comments}',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  post.timeAgo,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
