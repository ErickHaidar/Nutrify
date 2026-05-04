import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/add_post_screen.dart';
import 'package:nutrify/screens/full_screen_image_screen.dart';
import 'package:nutrify/screens/post_detail_screen.dart';
import 'package:nutrify/screens/user_profile_screen.dart';
import 'package:nutrify/screens/comment_detail_screen.dart';
import 'package:nutrify/screens/chat_list_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:nutrify/services/chat_api_service.dart';
import 'package:nutrify/services/notification_api_service.dart';
import 'package:nutrify/widgets/notification_modal.dart';
import 'package:nutrify/widgets/shimmer_loading.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:intl/intl.dart';

class KomunitasScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  const KomunitasScreen({super.key, this.onNavigateToProfile});

  @override
  State<KomunitasScreen> createState() => KomunitasScreenState();
}

class KomunitasScreenState extends State<KomunitasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _api = CommunityPostApiService();
  final _notifApi = NotificationApiService();
  List<CommunityPost> _posts = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  int _chatUnreadCount = 0;
  final Set<String> _likingPostIds = {};
  final Set<int> _followingUserIds = {};
  final Map<String, double> _likeScales = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
    _loadUnreadCount();
    _loadChatUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notifApi.getUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  Future<void> _loadChatUnreadCount() async {
    try {
      final chatApi = ChatApiService();
      final count = await chatApi.getUnreadCount();
      if (mounted) setState(() => _chatUnreadCount = count);
    } catch (_) {}
  }

  void _openChatList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatListScreen()),
    );
    _loadChatUnreadCount();
  }

  void _showNotifications() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const NotificationModal(),
    );
    _loadUnreadCount();
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

  void navigateToAddPost() => _navigateToAddPost();

  void refreshPosts() => _loadPosts();

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

  void _animateLike(String postId) {
    setState(() => _likeScales[postId] = 0.8);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _likeScales[postId] = 1.0);
    });
  }

  void _toggleLike(String postId) async {
    if (_likingPostIds.contains(postId)) return; // Debounce
    _likingPostIds.add(postId);
    _animateLike(postId);
    
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
    } finally {
      _likingPostIds.remove(postId);
    }
  }

  void _toggleFollow(String postId) async {
    final post = _posts.firstWhere((p) => p.id == postId);
    final authorId = post.authorId;
    if (_followingUserIds.contains(authorId)) return; // Debounce
    _followingUserIds.add(authorId);
    
    final wasFollowed = post.isFollowed;
    final wasRequested = post.isRequested;
    setState(() {
      for (final p in _posts) {
        if (p.authorId == authorId) {
          p.isFollowed = false;
          p.isRequested = false;
        }
      }
    });
    try {
      final result = await _api.toggleFollow(authorId);
      if (mounted) {
        setState(() {
          for (final p in _posts) {
            if (p.authorId == authorId) {
              p.isFollowed = result['followed'] as bool? ?? false;
              p.isRequested = result['requested'] as bool? ?? false;
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          for (final p in _posts) {
            if (p.authorId == authorId) {
              p.isFollowed = wasFollowed;
              p.isRequested = wasRequested;
            }
          }
        });
      }
    } finally {
      _followingUserIds.remove(authorId);
    }
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
        title: GestureDetector(
          onTap: _navigateToAddPost,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  'Posting',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF49426E), size: 26),
            onPressed: _showUserSearch,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xFF49426E), size: 24),
                onPressed: _showNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: _openChatList,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: AppColors.navy, size: 20),
                ),
                if (_chatUnreadCount > 0)
                  Positioned(
                    right: 4,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _chatUnreadCount > 99 ? '99+' : '$_chatUnreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(22),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.navy,
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
          ? const KomunitasShimmer()
          : TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: AppColors.navy,
                  onRefresh: _loadPosts,
                  child: _buildFeed(_posts),
                ),
                RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: AppColors.navy,
                  onRefresh: _loadPosts,
                  child: followingPosts.isEmpty
                      ? _buildEmptyState(AppStrings.noFollowingPosts)
                      : _buildFeed(followingPosts),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            height: constraints.maxHeight,
            alignment: Alignment.center,
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
        ],
      ),
    );
  }

  Widget _buildFeed(List<CommunityPost> feedPosts) {
    if (feedPosts.isEmpty) {
      return _buildEmptyState(AppStrings.noFollowingPosts);
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      itemCount: feedPosts.length,
      separatorBuilder: (context, index) => Divider(
        color: AppColors.navy.withOpacity(0.1), thickness: 1, height: 32,
      ),
      itemBuilder: (context, index) => _buildPostCard(feedPosts[index]),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      onTap: () => _navigateToPostDetail(post),
      behavior: HitTestBehavior.opaque,
      child: Padding(
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
                    backgroundImage: post.authorAvatarUrl.isNotEmpty
                        ? NetworkImage(post.authorAvatarUrl.startsWith('http') ? post.authorAvatarUrl : 'https://nutrify-app.my.id${post.authorAvatarUrl}')
                        : null,
                    child: post.authorAvatarUrl.isEmpty
                        ? Text(
                            post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '-',
                            style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
                          )
                        : null,
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
                        color: post.isFollowed
                            ? AppColors.navy
                            : post.isRequested
                                ? AppColors.navy.withOpacity(0.5)
                                : AppColors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        post.isFollowed
                            ? AppStrings.following
                            : post.isRequested
                                ? (AppStrings.isId ? 'Diminta' : 'Requested')
                                : AppStrings.follow,
                        style: TextStyle(
                          color: post.isFollowed || post.isRequested ? Colors.white : AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Post content
            if (post.content.length > 200) ...[
              Text(
                '${post.content.substring(0, 200)}...',
                style: const TextStyle(color: AppColors.navy, fontSize: 14, height: 1.5),
              ),
              GestureDetector(
                onTap: () => _navigateToPostDetail(post),
                child: Text(
                  AppStrings.showMore,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ] else
              Text(post.content, style: const TextStyle(color: AppColors.navy, fontSize: 14, height: 1.5)),
            if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenImageScreen(imageUrl: post.imagePath!))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    post.imagePath!.startsWith('http') ? post.imagePath! : 'https://nutrify-app.my.id${post.imagePath!}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
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
            const SizedBox(height: 12),

            // Action buttons (like/comment) — stop propagation so tap doesn't go to detail
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(post.id),
                  child: Row(
                    children: [
                      AnimatedScale(
                        scale: _likeScales[post.id] ?? 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : AppColors.navy.withOpacity(0.6), size: 22),
                      ),
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
      ),
    );
  }

  void _navigateToPostDetail(CommunityPost post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post, api: _api),
      ),
    );
    if (mounted) {
      if (result == true) {
        // Post was deleted, remove it from the list
        setState(() {
          _posts.removeWhere((p) => p.id == post.id);
        });
      } else {
        setState(() {}); // Refresh like/comment counts
      }
    }
  }

  void _navigateToUserProfile(CommunityPost post) async {
    if (post.isOwnPost) {
      widget.onNavigateToProfile?.call();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: post.authorId,
          userName: post.authorName,
          api: _api,
        ),
      ),
    );
    // Refresh follow status for posts by this author after returning
    if (mounted) {
      _refreshFollowStatus(post.authorId);
    }
  }

  void _refreshFollowStatus(int authorId) async {
    try {
      final data = await _api.getUserProfile(authorId);
      final isFollowing = data['is_following'] as bool? ?? false;
      final isRequested = data['is_requested'] as bool? ?? false;
      if (mounted) {
        setState(() {
          for (final post in _posts) {
            if (post.authorId == authorId) {
              post.isFollowed = isFollowing;
              post.isRequested = isRequested;
            }
          }
        });
      }
    } catch (_) {}
  }

  void _showUserSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => _UserSearchSheet(api: _api),
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  final CommunityPostApiService api;
  const _UserSearchSheet({required this.api});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.length < 2) return;

    setState(() => _isSearching = true);
    try {
      final users = await widget.api.searchUsers(q);
      if (mounted) {
        setState(() {
          _results = users;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                const Text('Cari User', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                    child: const Icon(Icons.close, size: 18, color: AppColors.navy),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cari nama atau username...',
                hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search, color: AppColors.navy, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _doSearch(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : !_hasSearched
                    ? Center(
                        child: Text('Ketik minimal 2 karakter untuk mencari',
                            style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 13)))
                    : _results.isEmpty
                        ? Center(
                            child: Text('User tidak ditemukan',
                                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 13)))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final u = _results[i];
                              return _buildUserTile(u);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> u) {
    final name = u['name'] as String? ?? '';
    final username = u['username'] as String? ?? '';
    final avatarUrl = u['avatar_url'] as String? ?? '';
    final isFollowing = u['is_following'] as bool? ?? false;
    final isRequested = u['is_requested'] as bool? ?? false;
    final userId = u['id'] as int? ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.peach,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty
            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold))
            : null,
      ),
      title: Text(name, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: username.isNotEmpty ? Text('@$username', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 12)) : null,
      trailing: GestureDetector(
        onTap: () async {
          try {
            final result = await widget.api.toggleFollow(userId);
            if (mounted) {
              setState(() {
                u['is_following'] = result['followed'] as bool? ?? false;
                u['is_requested'] = result['requested'] as bool? ?? false;
              });
            }
          } catch (_) {}
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isFollowing
                ? AppColors.navy
                : isRequested
                    ? AppColors.navy.withValues(alpha: 0.5)
                    : AppColors.amber,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isFollowing ? 'Diikuti' : isRequested ? 'Diminta' : 'Ikuti',
            style: TextStyle(color: isFollowing || isRequested ? Colors.white : AppColors.navy, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(userId: userId, userName: name, api: widget.api),
          ),
        );
      },
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
  CommentItem? _replyTarget;
  final _commentFocusNode = FocusNode();
  final Set<int> _loadingReplies = {};

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
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
      String textToSend = text;
      if (_replyTarget != null && !text.startsWith('@${_replyTarget!.userName}')) {
        textToSend = '@${_replyTarget!.userName} $text';
      }
      final newComment = await widget.api.addComment(
        int.parse(widget.post.id),
        textToSend,
        parentId: _replyTarget?.id,
      );
      widget.commentCtrl.clear();
      final target = _replyTarget;
      if (mounted) {
        setState(() {
          _isSending = false;
          _replyTarget = null;
          if (target != null) {
            final topLevelId = target.parentId ?? target.id;
            final idx = _comments.indexWhere((c) => c.id == topLevelId);
            if (idx != -1) {
              final parent = _comments[idx];
              _comments[idx] = CommentItem(
                id: parent.id, content: parent.content, userId: parent.userId, userName: parent.userName, userUsername: parent.userUsername, userAvatarUrl: parent.userAvatarUrl, parentId: parent.parentId, likesCount: parent.likesCount, isLiked: parent.isLiked, repliesCount: parent.repliesCount + 1, replies: [...parent.replies, newComment], createdAt: parent.createdAt,
              );
            }
          } else {
            _comments.add(newComment);
          }
        });
        widget.onCommentAdded();
      }
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _toggleCommentLike(CommentItem c, {bool isReply = false, int? parentIndex}) async {
    final wasLiked = c.isLiked;
    setState(() {
      final updated = CommentItem(
        id: c.id, content: c.content, userId: c.userId, userName: c.userName, userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId, likesCount: wasLiked ? c.likesCount - 1 : c.likesCount + 1, isLiked: !wasLiked, repliesCount: c.repliesCount, replies: c.replies, createdAt: c.createdAt,
      );
      if (isReply && parentIndex != null) {
        final parent = _comments[parentIndex];
        final replyIdx = parent.replies.indexWhere((r) => r.id == c.id);
        if (replyIdx != -1) {
          final newReplies = List<CommentItem>.from(parent.replies);
          newReplies[replyIdx] = updated;
          _comments[parentIndex] = CommentItem(id: parent.id, content: parent.content, userId: parent.userId, userName: parent.userName, userUsername: parent.userUsername, userAvatarUrl: parent.userAvatarUrl, parentId: parent.parentId, likesCount: parent.likesCount, isLiked: parent.isLiked, repliesCount: parent.repliesCount, replies: newReplies, createdAt: parent.createdAt);
        }
      } else {
        final idx = _comments.indexWhere((item) => item.id == c.id);
        if (idx != -1) _comments[idx] = updated;
      }
    });
    try {
      await widget.api.toggleCommentLike(c.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          final reverted = CommentItem(
            id: c.id, content: c.content, userId: c.userId, userName: c.userName, userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId, likesCount: wasLiked ? c.likesCount + 1 : c.likesCount - 1, isLiked: wasLiked, repliesCount: c.repliesCount, replies: c.replies, createdAt: c.createdAt,
          );
          if (isReply && parentIndex != null) {
            final parent = _comments[parentIndex];
            final replyIdx = parent.replies.indexWhere((r) => r.id == c.id);
            if (replyIdx != -1) {
              final newReplies = List<CommentItem>.from(parent.replies);
              newReplies[replyIdx] = reverted;
              _comments[parentIndex] = CommentItem(id: parent.id, content: parent.content, userId: parent.userId, userName: parent.userName, userUsername: parent.userUsername, userAvatarUrl: parent.userAvatarUrl, parentId: parent.parentId, likesCount: parent.likesCount, isLiked: parent.isLiked, repliesCount: parent.repliesCount, replies: newReplies, createdAt: parent.createdAt);
            }
          } else {
            final idx = _comments.indexWhere((item) => item.id == c.id);
            if (idx != -1) _comments[idx] = reverted;
          }
        });
      }
    }
  }

  Future<void> _loadMoreReplies(CommentItem c, int parentIndex) async {
    if (_loadingReplies.contains(c.id)) return;
    setState(() => _loadingReplies.add(c.id));

    try {
      final page = (c.replies.length ~/ 10) + 1;
      final newReplies = await widget.api.getCommentReplies(c.id, page: page);
      
      if (mounted) {
        setState(() {
          _loadingReplies.remove(c.id);
          
          final existingIds = c.replies.map((r) => r.id).toSet();
          final merged = List<CommentItem>.from(c.replies);
          for (var r in newReplies) {
            if (!existingIds.contains(r.id)) merged.add(r);
          }
          
          final updated = CommentItem(
            id: c.id, content: c.content, userId: c.userId, userName: c.userName, userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId, likesCount: c.likesCount, isLiked: c.isLiked, repliesCount: c.repliesCount, replies: merged, createdAt: c.createdAt,
          );
          _comments[parentIndex] = updated;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingReplies.remove(c.id));
    }
  }

  void _openCommentDetail(CommentItem comment) async {
    final updatedComment = await Navigator.push<CommentItem>(
      context,
      MaterialPageRoute(
        builder: (_) => CommentDetailScreen(
          comment: comment,
          api: widget.api,
          postId: int.parse(widget.post.id),
        ),
      ),
    );
    if (updatedComment != null && mounted) {
      setState(() {
        final idx = _comments.indexWhere((c) => c.id == updatedComment.id);
        if (idx != -1) _comments[idx] = updatedComment;
      });
    }
  }

  void _openProfile(int userId, String userName) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => UserProfileScreen(userId: userId, userName: userName, api: widget.api),
    ));
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return DateFormat('dd MMM').format(dt);
  }

  Widget _buildContentWithMentions(String content, {required double fontSize}) {
    final regex = RegExp(r'(@\w+)');
    final spans = <TextSpan>[];
    int lastEnd = 0;
    for (final match in regex.allMatches(content)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: content.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: fontSize),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < content.length) {
      spans.add(TextSpan(text: content.substring(lastEnd)));
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(color: AppColors.navy.withValues(alpha: 0.8), fontSize: fontSize, height: 1.4),
        children: spans,
      ),
    );
  }

  Widget _buildSingleComment(CommentItem c, {bool isReply = false, int? parentIndex, VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openProfile(c.userId, c.userName),
          child: CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: AppColors.peach,
            backgroundImage: c.userAvatarUrl != null ? NetworkImage(c.userAvatarUrl!) : null,
            child: c.userAvatarUrl == null
                ? Text(c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '-',
                    style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: isReply ? 10 : 14))
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: c.userName,
                      style: TextStyle(
                        color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: isReply ? 12 : 13),
                    ),
                    TextSpan(
                      text: '  ${_formatTime(c.createdAt)}',
                      style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 10),
                    ),
                  ]),
                ),
                const SizedBox(height: 2),
                _buildContentWithMentions(c.content, fontSize: isReply ? 12 : 13),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleCommentLike(c, isReply: isReply, parentIndex: parentIndex),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: c.isLiked ? Colors.red : AppColors.navy.withValues(alpha: 0.4),
                              size: isReply ? 12 : 14),
                          if (c.likesCount > 0) ...[
                            const SizedBox(width: 3),
                            Text('${c.likesCount}',
                                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 11)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyTarget = c;
                          _commentFocusNode.requestFocus();
                        });
                      },
                      child: Text('Balas',
                          style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentTile(CommentItem c, int parentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSingleComment(c, onTap: () => _openCommentDetail(c)),
        if (c.replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...c.replies.asMap().entries.map((entry) {
            final idx = entry.key;
            final r = entry.value;
            return Padding(
              padding: const EdgeInsets.only(left: 42, bottom: 8),
              child: _buildSingleComment(r, isReply: true, parentIndex: parentIndex, onTap: () => _openCommentDetail(c)),
            );
          }),
          if (c.repliesCount > c.replies.length)
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: _loadingReplies.contains(c.id)
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                  : GestureDetector(
                      onTap: () => _loadMoreReplies(c, parentIndex),
                      child: Text(
                        'Lihat ${c.repliesCount - c.replies.length} balasan lainnya',
                        style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
        ] else if (c.repliesCount > 0) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: _loadingReplies.contains(c.id)
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                : GestureDetector(
                    onTap: () => _loadMoreReplies(c, parentIndex),
                    child: Text(
                      'Lihat ${c.repliesCount} balasan',
                      style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Komentar',
                  style: TextStyle(
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
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final c = _comments[index];
                          return _buildCommentTile(c, index);
                        },
                      ),
          ),
          const Divider(height: 1, color: Colors.black12),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyTarget != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Membalas @${_replyTarget!.userName}',
                              style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _replyTarget = null),
                            child: Icon(Icons.close, size: 16, color: AppColors.navy.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.commentCtrl,
                          focusNode: _commentFocusNode,
                          enabled: !_isSending,
                          decoration: InputDecoration(
                            hintText: _replyTarget != null ? 'Balas @${_replyTarget!.userName}...' : 'Tulis komentar...',
                            hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.4)),
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
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
