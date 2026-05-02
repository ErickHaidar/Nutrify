import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/add_post_screen.dart';
import 'package:nutrify/screens/post_detail_screen.dart';
import 'package:nutrify/screens/user_profile_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/widgets/notification_modal.dart';
import 'package:intl/intl.dart';

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
      builder: (sheetCtx) => _CommentSheet(
        post: post,
        api: _api,
        commentCtrl: commentCtrl,
        onCommentAdded: () {
          if (mounted) setState(() => post.comments++);
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
          // Author row
          Row(
            children: [
              GestureDetector(
                onTap: () => _navigateToUserProfile(post),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.peach,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '-',
                    style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToUserProfile(post),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(post.timeAgo, style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
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
          const SizedBox(height: 12),

          // Post content (tappable → post detail)
          GestureDetector(
            onTap: () => _navigateToPostDetail(post),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.content, style: const TextStyle(color: AppColors.navy, fontSize: 14, height: 1.5)),
                if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(post.localImageFile!, width: double.infinity, height: 200, fit: BoxFit.cover),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
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

  void _navigateToPostDetail(CommunityPost post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post, api: _api),
      ),
    );
    if (mounted) setState(() {});
  }

  void _navigateToUserProfile(CommunityPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: post.authorId,
          userName: post.authorName,
          api: _api,
        ),
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final CommunityPost post;
  final CommunityPostApiService api;
  final TextEditingController commentCtrl;
  final VoidCallback onCommentAdded;

  const _CommentSheet({
    required this.post,
    required this.api,
    required this.commentCtrl,
    required this.onCommentAdded,
  });

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  List<CommentItem> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await widget.api.getComments(int.parse(widget.post.id));
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = widget.commentCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final newComment = await widget.api.addComment(int.parse(widget.post.id), text);
      widget.commentCtrl.clear();
      if (mounted) {
        setState(() {
          _comments.add(newComment);
          _isSending = false;
        });
        widget.onCommentAdded();
      }
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  AppStrings.comments(_comments.length.toString()),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.navy.withOpacity(0.1),
                    child: const Icon(Icons.close, size: 18, color: AppColors.navy),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          // Comment list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : _comments.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada komentar',
                          style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = _comments[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.peach,
                                child: Text(
                                  c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '-',
                                  style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.userName,
                                      style: const TextStyle(
                                        color: AppColors.navy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.content,
                                      style: TextStyle(
                                        color: AppColors.navy.withOpacity(0.8),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(c.createdAt),
                                      style: TextStyle(
                                        color: AppColors.navy.withOpacity(0.4),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
          const Divider(height: 1, color: Colors.black12),
          // Input field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.commentCtrl,
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        hintStyle: TextStyle(color: AppColors.navy.withOpacity(0.4)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.navy.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.navy.withOpacity(0.3)),
                        ),
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.navy,
                    child: _isSending
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: _sendComment,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
