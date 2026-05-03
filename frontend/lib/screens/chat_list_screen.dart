import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/screens/chat_detail_screen.dart';
import 'package:nutrify/screens/user_profile_screen.dart';
import 'package:nutrify/services/chat_api_service.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:nutrify/widgets/shimmer_loading.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatApi = ChatApiService();
  final _communityApi = CommunityPostApiService();
  final _searchCtrl = TextEditingController();
  List<ConversationItem> _conversations = [];
  List<ConversationItem> _filtered = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all' or 'unread'
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadConversations(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final convs = await _chatApi.getConversations(filter: _filter);
      if (mounted) {
        setState(() {
          _conversations = convs;
          _applySearch();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filtered = _conversations;
    } else {
      _filtered = _conversations.where((c) {
        return c.otherUserName.toLowerCase().contains(query) ||
            c.otherUsername.toLowerCase().contains(query);
      }).toList();
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Sekarang';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}mg';
    return DateFormat('dd/MM/yy').format(dt);
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
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
              ListTile(
                leading: Icon(Icons.list, color: AppColors.navy),
                title: Text('Semua', style: TextStyle(color: AppColors.navy, fontWeight: _filter == 'all' ? FontWeight.bold : FontWeight.normal)),
                trailing: _filter == 'all' ? Icon(Icons.check, color: AppColors.navy) : null,
                onTap: () { Navigator.pop(ctx); setState(() => _filter = 'all'); _loadConversations(); },
              ),
              ListTile(
                leading: Icon(Icons.markunread, color: AppColors.navy),
                title: Text('Belum Dibaca', style: TextStyle(color: AppColors.navy, fontWeight: _filter == 'unread' ? FontWeight.bold : FontWeight.normal)),
                trailing: _filter == 'unread' ? Icon(Icons.check, color: AppColors.navy) : null,
                onTap: () { Navigator.pop(ctx); setState(() => _filter = 'unread'); _loadConversations(); },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.done_all, color: AppColors.navy),
                title: Text('Tandai Semua Dibaca', style: TextStyle(color: AppColors.navy)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _chatApi.markAllRead();
                  _loadConversations();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewChatSheet() {
    final searchCtrl = TextEditingController();
    List<Map<String, dynamic>> results = [];
    bool isSearching = false;
    bool hasSearched = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
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
                    const Text('Mulai Obrolan', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
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
                  controller: searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau username...',
                    hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.4)),
                    prefixIcon: const Icon(Icons.search, color: AppColors.navy, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onChanged: (q) async {
                    if (q.trim().length < 2) { setSheetState(() { results = []; hasSearched = false; }); return; }
                    setSheetState(() => isSearching = true);
                    try {
                      final users = await _communityApi.searchUsers(q.trim());
                      setSheetState(() { results = users; isSearching = false; hasSearched = true; });
                    } catch (_) { setSheetState(() => isSearching = false); }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: isSearching
                    ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                    : !hasSearched
                        ? Center(child: Text('Ketik minimal 2 karakter', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 13)))
                        : results.isEmpty
                            ? Center(child: Text('User tidak ditemukan', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 13)))
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: results.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  final u = results[i];
                                  final name = u['name'] as String? ?? '';
                                  final username = u['username'] as String? ?? '';
                                  final avatarUrl = u['avatar_url'] as String? ?? '';
                                  final userId = u['id'] as int? ?? 0;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                    leading: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.peach,
                                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl.startsWith('http') ? avatarUrl : 'https://nutrify-app.my.id/$avatarUrl') : null,
                                      child: avatarUrl.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)) : null,
                                    ),
                                    title: Text(name, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 14)),
                                    subtitle: username.isNotEmpty ? Text('@$username', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 12)) : null,
                                    onTap: () async {
                                      Navigator.pop(ctx);
                                      try {
                                        final conv = await _chatApi.createConversation(userId);
                                        if (mounted) {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => ChatDetailScreen(
                                              conversationId: conv.id,
                                              otherUserName: conv.otherUserName,
                                              otherUserAvatarUrl: conv.otherUserAvatarUrl,
                                            )),
                                          );
                                          if (result == true) _loadConversations();
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Gagal memulai obrolan: $e'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
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
        title: const Text(
          'Chat',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.navy),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'all' || value == 'unread') {
                setState(() => _filter = value);
                _loadConversations();
              } else if (value == 'mark_all_read') {
                await _chatApi.markAllRead();
                _loadConversations();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'all',
                child: Row(children: [
                  Icon(Icons.list, color: AppColors.navy, size: 20),
                  const SizedBox(width: 8),
                  Text('Semua', style: TextStyle(color: AppColors.navy, fontWeight: _filter == 'all' ? FontWeight.bold : FontWeight.normal)),
                ]),
              ),
              PopupMenuItem(
                value: 'unread',
                child: Row(children: [
                  Icon(Icons.markunread, color: AppColors.navy, size: 20),
                  const SizedBox(width: 8),
                  Text('Belum Dibaca', style: TextStyle(color: AppColors.navy, fontWeight: _filter == 'unread' ? FontWeight.bold : FontWeight.normal)),
                ]),
              ),
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(children: [
                  Icon(Icons.done_all, color: AppColors.navy, size: 20),
                  SizedBox(width: 8),
                  Text('Tandai Semua Dibaca', style: TextStyle(color: AppColors.navy)),
                ]),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari percakapan...',
                hintStyle: TextStyle(color: AppColors.navy.withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search, color: AppColors.navy, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() => _applySearch()),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const ChatListShimmer()
          : _filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.navy.withValues(alpha: 0.15)),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada percakapan',
                          style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _showNewChatSheet,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Mulai Obrolan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  color: AppColors.amber,
                  backgroundColor: AppColors.navy,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(color: AppColors.navy.withValues(alpha: 0.06), height: 1),
                    itemBuilder: (_, i) => _buildConversationTile(_filtered[i]),
                  ),
                ),
      floatingActionButton: _conversations.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _showNewChatSheet,
              backgroundColor: AppColors.navy,
              child: const Icon(Icons.chat, color: Colors.white),
            ),
    );
  }

  Widget _buildConversationTile(ConversationItem conv) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.peach,
        backgroundImage: conv.otherUserAvatarUrl != null
            ? NetworkImage(conv.otherUserAvatarUrl!)
            : null,
        child: conv.otherUserAvatarUrl == null
            ? Text(
                conv.otherUserName.isNotEmpty ? conv.otherUserName[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 20),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conv.otherUserName,
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conv.lastMessageAt != null)
            Text(
              _formatTime(conv.lastMessageAt!),
              style: TextStyle(
                color: conv.unreadCount > 0 ? AppColors.navy : AppColors.navy.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: conv.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conv.lastMessageContent ?? (conv.lastMessageImageUrl != null ? '[Gambar]' : ''),
              style: TextStyle(
                color: conv.unreadCount > 0 ? AppColors.navy.withValues(alpha: 0.8) : AppColors.navy.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: conv.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conv.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                conv.unreadCount > 99 ? '99+' : '${conv.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      onTap: () async {
        await _chatApi.markAsRead(conv.id);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              conversationId: conv.id,
              otherUserName: conv.otherUserName,
              otherUserAvatarUrl: conv.otherUserAvatarUrl,
            ),
          ),
        );
        if (result == true) _loadConversations();
      },
    );
  }
}
