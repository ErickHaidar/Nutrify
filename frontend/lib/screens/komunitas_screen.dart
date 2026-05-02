import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/add_post_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/widgets/notification_modal.dart';

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _api = CommunityPostApiService();
  List<CommunityPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _api.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToAddPost() async {
    final newPost = await Navigator.push<CommunityPost>(
      context,
      MaterialPageRoute(builder: (context) => const AddPostScreen()),
    );
    if (newPost != null) {
      setState(() {
        _posts.insert(0, newPost);
      });
    }
  }

  void _toggleLike(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    final wasLiked = post.isLiked;
    setState(() {
      post.isLiked = !post.isLiked;
      post.isLiked ? post.likes++ : post.likes--;
    });
    try {
      final result = await _api.toggleLike(int.parse(postId));
      if (mounted) {
        setState(() {
          post.isLiked = result['liked'] as bool;
          post.likes = result['likes_count'] as int;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          post.isLiked = wasLiked;
          wasLiked ? post.likes++ : post.likes--;
        });
      }
    }
  }

  void _toggleFollow(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.isFollowed = !post.isFollowed;
      for (var p in _posts.where((p) => p.authorName == post.authorName)) {
        p.isFollowed = post.isFollowed;
      }
    });
  }

  void _showComments(CommunityPost post) {
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Komentar', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: AppColors.navy)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<List<CommentItem>>(
                    future: _api.getComments(int.parse(post.id)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                      }
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Center(child: Text('Belum ada komentar', style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 14)));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final c = comments[i];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(radius: 16, backgroundColor: AppColors.peach,
                                child: Text(c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 12))),
                              const SizedBox(width: 10),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.userName, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(c.content, style: TextStyle(color: AppColors.navy.withOpacity(0.8), fontSize: 13, height: 1.4)),
                                ],
                              )),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentCtrl,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar...',
                              hintStyle: TextStyle(color: AppColors.navy.withOpacity(0.4)),
                              filled: true,
                              fillColor: const Color(0xFFF5F0EB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            ),
                            style: const TextStyle(color: AppColors.navy, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            final text = commentCtrl.text.trim();
                            if (text.isEmpty) return;
                            try {
                              await _api.addComment(int.parse(post.id), text);
                              commentCtrl.clear();
                              if (mounted) setState(() => post.comments++);
                            } catch (_) {}
                          },
                          icon: const Icon(Icons.send, color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => const NotificationModal(),
              );
            },
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeed(_posts),
                  followingPosts.isEmpty
                      ? _buildEmptyState(AppStrings.noFollowingPosts)
                      : _buildFeed(followingPosts),
                ],
              ),
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
              style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(List<CommunityPost> feedPosts) {
    if (feedPosts.isEmpty) {
      return _buildEmptyState(AppStrings.noFollowingPosts);
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: feedPosts.length,
      separatorBuilder: (context, index) => Divider(
        color: AppColors.navy.withOpacity(0.1), thickness: 1, height: 32,
      ),
      itemBuilder: (context, index) => _buildPostCard(feedPosts[index]),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.peach,
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '-',
                  style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(post.timeAgo, style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
              if (!post.isOwnPost)
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
                      style: TextStyle(color: post.isFollowed ? Colors.white : AppColors.navy, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(post.content, style: const TextStyle(color: AppColors.navy, fontSize: 14, height: 1.5)),
          if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post.imagePath!.startsWith('http') ? post.imagePath! : 'https://nutrify-app.my.id${post.imagePath!}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          if (post.localImageFile != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(post.localImageFile!, width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : AppColors.navy.withOpacity(0.6), size: 22),
                    const SizedBox(width: 6),
                    Text(AppStrings.likes(_formatCount(post.likes)), style: TextStyle(color: AppColors.navy.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => _showComments(post),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: AppColors.navy.withOpacity(0.6), size: 20),
                    const SizedBox(width: 6),
                    Text(AppStrings.comments(_formatCount(post.comments)), style: TextStyle(color: AppColors.navy.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13)),
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
