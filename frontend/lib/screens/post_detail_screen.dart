import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/comment_detail_screen.dart';
import 'package:nutrify/screens/user_profile_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;
  final CommunityPostApiService api;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.api,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> with SingleTickerProviderStateMixin {
  List<CommentItem> _comments = [];
  bool _isLoadingComments = true;
  bool _isSending = false;
  final _commentCtrl = TextEditingController();
  final _commentFocusNode = FocusNode();
  final Set<int> _loadingReplies = {};
  CommentItem? _replyTarget;
  bool _isLikingPost = false;
  late AnimationController _likeAnimController;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.7,
      upperBound: 1.3,
    )..value = 1.0;
    _fetchComments();
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    _commentCtrl.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await widget.api.getComments(int.parse(widget.post.id));
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
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
      _commentCtrl.clear();
      final target = _replyTarget;
      if (mounted) {
        setState(() {
          _isSending = false;
          if (target != null) {
            // Add reply to parent's replies list
            final topLevelId = target.parentId ?? target.id;
            final idx = _comments.indexWhere((c) => c.id == topLevelId);
            if (idx != -1) {
              final parent = _comments[idx];
              _comments[idx] = CommentItem(
                id: parent.id,
                content: parent.content,
                userId: parent.userId,
                userName: parent.userName,
                userUsername: parent.userUsername,
                userAvatarUrl: parent.userAvatarUrl,
                parentId: parent.parentId,
                likesCount: parent.likesCount,
                isLiked: parent.isLiked,
                repliesCount: parent.repliesCount + 1,
                replies: [...parent.replies, newComment],
                createdAt: parent.createdAt,
              );
            }
          } else {
            _comments.add(newComment);
          }
          widget.post.comments++;
          _replyTarget = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _animateLike() {
    _likeAnimController.forward(from: 0.8).then((_) {
      if (mounted) _likeAnimController.animateTo(1.0);
    });
  }

  void _toggleLike() async {
    if (_isLikingPost) return; // Debounce
    _isLikingPost = true;
    _animateLike();

    final wasLiked = widget.post.isLiked;
    setState(() {
      widget.post.isLiked = !widget.post.isLiked;
      widget.post.isLiked ? widget.post.likes++ : widget.post.likes--;
      if (widget.post.likes < 0) widget.post.likes = 0;
    });
    try {
      final result = await widget.api.toggleLike(int.parse(widget.post.id));
      if (mounted) {
        setState(() {
          final liked = result['liked'] as bool;
          final count = result['likes_count'] as int;
          widget.post.isLiked = liked;
          widget.post.likes = liked && count < 1 ? 1 : (!liked && count < 0 ? 0 : count);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          widget.post.isLiked = wasLiked;
          wasLiked ? widget.post.likes++ : widget.post.likes--;
          if (widget.post.likes < 0) widget.post.likes = 0;
        });
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLikingPost = false;
    }
  }

  Future<void> _toggleCommentLike(CommentItem c, {bool isReply = false, int? parentIndex}) async {
    final wasLiked = c.isLiked;
    setState(() {
      c = CommentItem(
        id: c.id, content: c.content, userId: c.userId, userName: c.userName,
        userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId,
        likesCount: wasLiked ? c.likesCount - 1 : c.likesCount + 1,
        isLiked: !wasLiked, repliesCount: c.repliesCount, replies: c.replies, createdAt: c.createdAt,
      );
      if (isReply && parentIndex != null) {
        final parent = _comments[parentIndex];
        final replyIdx = parent.replies.indexWhere((r) => r.id == c.id);
        if (replyIdx != -1) {
          _comments[parentIndex] = CommentItem(
            id: parent.id, content: parent.content, userId: parent.userId, userName: parent.userName,
            userUsername: parent.userUsername, userAvatarUrl: parent.userAvatarUrl, parentId: parent.parentId,
            likesCount: parent.likesCount, isLiked: parent.isLiked, repliesCount: parent.repliesCount,
            replies: [...parent.replies.sublist(0, replyIdx), c, ...parent.replies.sublist(replyIdx + 1)],
            createdAt: parent.createdAt,
          );
        }
      } else {
        final idx = _comments.indexWhere((x) => x.id == c.id);
        if (idx != -1) _comments[idx] = c;
      }
    });
    try {
      final result = await widget.api.toggleCommentLike(c.id);
      // Server confirms — already updated optimistically
    } catch (_) {
      // Revert
      if (mounted) {
        setState(() {
          if (isReply && parentIndex != null) {
            final parent = _comments[parentIndex];
            final replyIdx = parent.replies.indexWhere((r) => r.id == c.id);
            if (replyIdx != -1) {
              _comments[parentIndex] = CommentItem(
                id: parent.id, content: parent.content, userId: parent.userId, userName: parent.userName,
                userUsername: parent.userUsername, userAvatarUrl: parent.userAvatarUrl, parentId: parent.parentId,
                likesCount: parent.likesCount, isLiked: parent.isLiked, repliesCount: parent.repliesCount,
                replies: [...parent.replies.sublist(0, replyIdx), CommentItem(
                  id: c.id, content: c.content, userId: c.userId, userName: c.userName,
                  userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId,
                  likesCount: wasLiked ? c.likesCount + 1 : c.likesCount - 1,
                  isLiked: wasLiked, repliesCount: c.repliesCount, replies: c.replies, createdAt: c.createdAt,
                ), ...parent.replies.sublist(replyIdx + 1)],
                createdAt: parent.createdAt,
              );
            }
          } else {
            final idx = _comments.indexWhere((x) => x.id == c.id);
            if (idx != -1) _comments[idx] = CommentItem(
              id: c.id, content: c.content, userId: c.userId, userName: c.userName,
              userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId,
              likesCount: wasLiked ? c.likesCount + 1 : c.likesCount - 1,
              isLiked: wasLiked, repliesCount: c.repliesCount, replies: c.replies, createdAt: c.createdAt,
            );
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
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => CommentDetailScreen(comment: comment, api: widget.api, postId: int.parse(widget.post.id)),
    ));
    _fetchComments();
  }

  void _openProfile(int userId, String userName) {
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

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Postingan',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostContent(post),
                  const Divider(height: 1, color: Colors.black12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Text('${_formatCount(post.likes)} Suka',
                            style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        Text('${_formatCount(post.comments)} Komentar',
                            style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _toggleLike,
                            icon: ScaleTransition(
                              scale: _likeAnimController,
                              child: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: post.isLiked ? Colors.red : AppColors.navy.withValues(alpha: 0.7), size: 22),
                            ),
                            label: Text(post.isLiked ? 'Disukai' : 'Suka',
                                style: TextStyle(color: post.isLiked ? Colors.red : AppColors.navy.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
                            icon: Icon(Icons.chat_bubble_outline, color: AppColors.navy.withValues(alpha: 0.7), size: 20),
                            label: Text('Komentar',
                                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text('Komentar', style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (_isLoadingComments)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
                    )
                  else if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text('Belum ada komentar. Jadilah yang pertama!',
                            style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 14)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      itemCount: _comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final c = _comments[index];
                        return _buildCommentTile(c, index);
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentItem c, int parentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSingleComment(c, onTap: () => _openCommentDetail(c)),
        // Preview replies (max 2)
        if (c.replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...c.replies.asMap().entries.map((entry) {
            final idx = entry.key;
            final r = entry.value;
            return Padding(
              padding: const EdgeInsets.only(left: 42, bottom: 8),
              child: _buildSingleComment(r, isReply: true, parentIndex: parentIndex, replyToName: c.userName, onTap: () => _openCommentDetail(c)),
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

  Widget _buildSingleComment(CommentItem c, {bool isReply = false, int? parentIndex, String? replyToName, VoidCallback? onTap}) {
    String headerName = c.userName;
    String displayContent = c.content;
    if (isReply && replyToName != null) {
      headerName = 'Membalas $replyToName';
      final mentionPrefix = '@$replyToName';
      if (c.content.startsWith(mentionPrefix)) {
        displayContent = c.content.substring(mentionPrefix.length).trimLeft();
      }
    }
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
                      text: headerName,
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
                _buildContentWithMentions(displayContent, fontSize: isReply ? 12 : 13),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Like button
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
                    // Reply button
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

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
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
                      controller: _commentCtrl,
                      focusNode: _commentFocusNode,
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: _replyTarget != null ? 'Balas @${_replyTarget!.userName}...' : 'Tulis komentar...',
                        hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: AppColors.cream,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.navy,
                    child: _isSending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
    );
  }

  Widget _buildPostContent(CommunityPost post) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (post.isOwnPost) return;
              _openProfile(post.authorId, post.authorName);
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.peach,
                  backgroundImage: post.authorAvatarUrl.isNotEmpty
                      ? NetworkImage(post.authorAvatarUrl.startsWith('http') ? post.authorAvatarUrl : 'https://nutrify-app.my.id${post.authorAvatarUrl}')
                      : null,
                  child: post.authorAvatarUrl.isEmpty
                      ? Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '-',
                          style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(post.timeAgo, style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 12)),
                    ],
                  ),
                ),
                if (post.isOwnPost)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: AppColors.navy.withValues(alpha: 0.6)),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Hapus Postingan?', style: TextStyle(color: AppColors.navy)),
                            content: const Text('Postingan ini akan dihapus secara permanen.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await widget.api.deletePost(int.parse(post.id));
                            if (mounted) Navigator.pop(context, true);
                          } catch (_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus postingan')));
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ]),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(post.content, style: const TextStyle(color: AppColors.navy, fontSize: 15, height: 1.6)),
          if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post.imagePath!.startsWith('http') ? post.imagePath! : 'https://nutrify-app.my.id${post.imagePath!}',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
