import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/screens/user_profile_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:intl/intl.dart';

class CommentDetailScreen extends StatefulWidget {
  final CommentItem comment;
  final CommunityPostApiService api;
  final int postId;

  const CommentDetailScreen({
    super.key,
    required this.comment,
    required this.api,
    required this.postId,
  });

  @override
  State<CommentDetailScreen> createState() => _CommentDetailScreenState();
}

class _CommentDetailScreenState extends State<CommentDetailScreen> {
  late CommentItem _parent;
  List<CommentItem> _replies = [];
  bool _isLoading = true;
  bool _isSending = false;
  CommentItem? _replyTarget;
  final _replyCtrl = TextEditingController();
  final _replyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _parent = widget.comment;
    _loadReplies();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    try {
      final replies = await widget.api.getCommentReplies(_parent.id);
      if (mounted) {
        setState(() {
          _replies = replies;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);

    try {
      final newReply = await widget.api.addComment(widget.postId, text, parentId: _parent.id);
      _replyCtrl.clear();
      if (mounted) {
        setState(() {
          _replies.add(newReply);
          _isSending = false;
          _replyTarget = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _toggleLike(CommentItem c, {bool isParent = false, int? replyIndex}) async {
    final wasLiked = c.isLiked;
    setState(() {
      final updated = CommentItem(
        id: c.id, content: c.content, userId: c.userId, userName: c.userName,
        userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId,
        likesCount: wasLiked ? c.likesCount - 1 : c.likesCount + 1,
        isLiked: !wasLiked, repliesCount: c.repliesCount, replies: c.replies, createdAt: c.createdAt,
      );
      if (isParent) {
        _parent = updated;
      } else if (replyIndex != null && replyIndex < _replies.length) {
        _replies[replyIndex] = updated;
      }
    });
    try {
      await widget.api.toggleCommentLike(c.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          final reverted = CommentItem(
            id: c.id, content: c.content, userId: c.userId, userName: c.userName,
            userUsername: c.userUsername, userAvatarUrl: c.userAvatarUrl, parentId: c.parentId,
            likesCount: wasLiked ? c.likesCount + 1 : c.likesCount - 1,
            isLiked: wasLiked, repliesCount: c.repliesCount, replies: c.replies, createdAt: c.createdAt,
          );
          if (isParent) _parent = reverted;
          else if (replyIndex != null && replyIndex < _replies.length) _replies[replyIndex] = reverted;
        });
      }
    }
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
        title: const Text('Komentar', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Parent comment
                  _buildCommentCard(_parent, isParent: true),
                  const Divider(height: 1, color: Colors.black12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text('Balasan (${_replies.length})',
                        style: TextStyle(color: AppColors.navy, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
                    )
                  else if (_replies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text('Belum ada balasan',
                            style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 14)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      itemCount: _replies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _buildCommentCard(_replies[i], replyIndex: i),
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

  Widget _buildCommentCard(CommentItem c, {bool isParent = false, int? replyIndex}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openProfile(c.userId, c.userName),
            child: CircleAvatar(
              radius: isParent ? 20 : 16,
              backgroundColor: AppColors.peach,
              backgroundImage: c.userAvatarUrl != null ? NetworkImage(c.userAvatarUrl!) : null,
              child: c.userAvatarUrl == null
                  ? Text(c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '-',
                      style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: isParent ? 16 : 12))
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: c.userName,
                      style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: isParent ? 14 : 13),
                    ),
                    TextSpan(
                      text: '  ${_formatTime(c.createdAt)}',
                      style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 10),
                    ),
                  ]),
                ),
                const SizedBox(height: 2),
                Text(c.content,
                    style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.8), fontSize: isParent ? 14 : 13, height: 1.4)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(c, isParent: isParent, replyIndex: replyIndex),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: c.isLiked ? Colors.red : AppColors.navy.withValues(alpha: 0.4),
                              size: isParent ? 16 : 14),
                          if (c.likesCount > 0) ...[
                            const SizedBox(width: 3),
                            Text('${c.likesCount}',
                                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyTarget = c;
                          _replyFocusNode.requestFocus();
                        });
                      },
                      child: Text('Balas',
                          style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
                      controller: _replyCtrl,
                      focusNode: _replyFocusNode,
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: _replyTarget != null ? 'Balas @${_replyTarget!.userName}...' : 'Tulis balasan...',
                        hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: AppColors.cream,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _sendReply(),
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
                            onPressed: _sendReply,
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
}
