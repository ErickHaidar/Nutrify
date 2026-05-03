import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/screens/full_screen_image_screen.dart';
import 'package:nutrify/services/chat_api_service.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String otherUserName;
  final String? otherUserAvatarUrl;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _chatApi = ChatApiService();
  final _communityApi = CommunityPostApiService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<MessageItem> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      await _loadMyUserId();
      await _chatApi.markAsRead(widget.conversationId);
      final msgs = await _chatApi.getMessages(widget.conversationId);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
        _scrollToBottom();
        _startPolling();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final msgs = await _chatApi.getMessages(widget.conversationId);
        if (mounted && msgs.length != _messages.length) {
          setState(() => _messages = msgs);
          _scrollToBottom();
          await _chatApi.markAsRead(widget.conversationId);
        }
      } catch (_) {}
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({File? imageFile}) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty && imageFile == null) return;
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final msg = await _chatApi.sendMessage(
        widget.conversationId,
        content: text.isNotEmpty ? text : null,
        imageFile: imageFile,
      );
      _msgCtrl.clear();
      if (mounted) {
        setState(() {
          _messages.add(msg);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = getIt<ImagePicker>();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked != null) {
      _sendMessage(imageFile: File(picked.path));
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return 'Hari ini';
    if (msgDate == yesterday) return 'Kemarin';
    return DateFormat('EEE, dd MMM').format(dt);
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == 0) return true;
    final current = _messages[index].createdAt;
    final previous = _messages[index - 1].createdAt;
    return current.year != previous.year || current.month != previous.month || current.day != previous.day;
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
          onPressed: () => Navigator.pop(context, true),
        ),
        title: GestureDetector(
          onTap: () {
            // Navigate to user profile
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.peach,
                backgroundImage: widget.otherUserAvatarUrl != null
                    ? NetworkImage(widget.otherUserAvatarUrl!)
                    : null,
                child: widget.otherUserAvatarUrl == null
                    ? Text(
                        widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Mulai percakapan!',
                          style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMe = _isMe(msg.senderId);

                          return Column(
                            children: [
                              if (_shouldShowSeparator(i))
                                _buildDateSeparator(msg.createdAt),
                              _buildMessageBubble(msg, isMe),
                            ],
                          );
                        },
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  int? _myUserId;

  Future<void> _loadMyUserId() async {
    if (_myUserId != null) return;
    try {
      final data = await _communityApi.getMyProfile();
      _myUserId = data['id'] as int?;
    } catch (_) {}
  }

  bool _isMe(int senderId) {
    return _myUserId != null && senderId == _myUserId;
  }

  bool _shouldShowSeparator(int index) {
    if (index == 0) return true;
    final current = _messages[index].createdAt;
    final previous = _messages[index - 1].createdAt;
    return current.day != previous.day || current.month != previous.month || current.year != previous.year;
  }

  Widget _buildDateSeparator(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(dt),
            style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageItem msg, bool isMe) {
    final time = DateFormat('HH:mm').format(msg.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(time, style: TextStyle(color: AppColors.navy.withValues(alpha: 0.3), fontSize: 10)),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.imageUrl != null)
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => FullScreenImageScreen(imageUrl: msg.imageUrl!),
                      )),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          msg.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  if (msg.content != null && msg.content!.isNotEmpty) ...[
                    if (msg.imageUrl != null) const SizedBox(height: 8),
                    Text(
                      msg.content!,
                      style: TextStyle(
                        color: isMe ? Colors.white : AppColors.navy,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(time, style: TextStyle(color: AppColors.navy.withValues(alpha: 0.3), fontSize: 10)),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: AppColors.navy.withValues(alpha: 0.6), size: 28),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Pesan...',
                    hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.4)),
                    filled: true,
                    fillColor: AppColors.cream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
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
                        onPressed: () => _sendMessage(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
