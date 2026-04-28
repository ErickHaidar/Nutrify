import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/add_post_screen.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Local state for UI demonstration
  List<CommunityPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Seed dummy data based on mockups
    _posts = [
      CommunityPost(
        id: '1',
        authorName: 'Erick Haidar',
        authorAvatarUrl: '', 
        timeAgo: '2j lalu',
        content: 'Berhasil mencapai target kalori hari ini dengan nutrisi seimbang. Semangat terus untuk pola hidup sehat!',
        likes: 200000,
        comments: 54000,
        isLiked: false,
        isFollowed: true,
        tabCategory: 'Untuk Anda',
      ),
      CommunityPost(
        id: '2',
        authorName: 'Erick Haidar',
        authorAvatarUrl: '',
        timeAgo: '5j lalu',
        content: 'Sarapan oatmeal dan buah-buahan bikin kenyang lebih lama. Ada yang punya resep oatmeal favorit?',
        likes: 150000,
        comments: 32000,
        isLiked: true,
        isFollowed: false,
        tabCategory: 'Untuk Anda',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAddPost() async {
    final newPost = await Navigator.push<CommunityPost>(
      context,
      MaterialPageRoute(builder: (context) => const AddPostScreen()),
    );

    if (newPost != null) {
      setState(() {
        _posts.insert(0, newPost); // Add to top of the feed
      });
    }
  }

  void _toggleLike(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.isLiked = !post.isLiked;
      post.isLiked ? post.likes++ : post.likes--;
    });
  }

  void _toggleFollow(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.isFollowed = !post.isFollowed;
      // Also update other posts by the same author
      for (var p in _posts.where((p) => p.authorName == post.authorName)) {
        p.isFollowed = post.isFollowed;
      }
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Filter posts for "Diikuti" tab
    final followingPosts = _posts.where((p) => p.isFollowed).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          'Nutrify',
          style: GoogleFonts.inter(
            color: const Color(0xFFFFB26B),
            fontWeight: FontWeight.w900,
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Color(0xFF49426E), size: 28),
            onPressed: _navigateToAddPost,
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF49426E), size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(22),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.navy.withOpacity(0.5),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: AppStrings.forYou),
                  Tab(text: AppStrings.following),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Untuk Anda Feed
          _buildFeed(_posts),
          
          // Diikuti Feed
          followingPosts.isEmpty
              ? _buildEmptyState(AppStrings.noFollowingPosts)
              : _buildFeed(followingPosts),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.navy.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(List<CommunityPost> feedPosts) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: feedPosts.length,
      separatorBuilder: (context, index) => Divider(
        color: AppColors.navy.withOpacity(0.1),
        thickness: 1,
        height: 32,
      ),
      itemBuilder: (context, index) {
        final post = feedPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Time, Follow Button
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.peach,
                child: Text(
                  post.authorName[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Follow / Following Button
              GestureDetector(
                onTap: () => _toggleFollow(post.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: post.isFollowed ? AppColors.navy : AppColors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    post.isFollowed ? AppStrings.following : AppStrings.follow,
                    style: TextStyle(
                      color: post.isFollowed ? Colors.white : AppColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content Text
          Text(
            post.content,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          // Image (if any)
          if (post.localImageFile != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                post.localImageFile!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Actions: Like and Comment
          Row(
            children: [
              // Like Button
              GestureDetector(
                onTap: () => _toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : AppColors.navy.withOpacity(0.6),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.likes(_formatCount(post.likes)),
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Comment Button
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.navy.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.comments(_formatCount(post.comments)),
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
