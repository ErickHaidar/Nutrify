import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/food_log_api_service.dart';
import '../services/notification_api_service.dart';
import '../screens/post_detail_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/add_meal_screen.dart';
import '../services/chat_api_service.dart';
import '../services/community_post_api_service.dart';
import '../domain/entity/post/community_post.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final _notifApi = NotificationApiService();
  final _foodLogApi = FoodLogApiService();
  bool _isLoading = true;
  List<_UnifiedNotification> _allNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _notifApi.getNotifications(),
        _foodLogApi.getLogs(DateTime.now()),
      ]);
      if (!mounted) return;

      final serverNotifs = results[0] as List<NotificationItem>;
      final todayLogs = results[1] as List<FoodLogEntry>;

      final List<_UnifiedNotification> unified = [];

      // Server notifications (like, comment, follow)
      for (final n in serverNotifs) {
        unified.add(_UnifiedNotification(
          id: n.id,
          type: n.type,
          title: n.body,
          subtitle: _formatTime(n.createdAt),
          actorName: n.actorName,
          actorId: n.actorId,
          postId: n.postId,
          isRead: n.isRead,
          createdAt: n.createdAt,
          icon: _iconForType(n.type),
          iconColor: _colorForType(n.type),
        ));
      }

      // Meal reminders (only show for times that have passed today)
      final now = DateTime.now();
      final meals = [
        _MealDef('Breakfast', 7, AppStrings.isId ? 'Makan Pagi' : 'Breakfast', Icons.wb_twilight, const Color(0xFFFF9800)),
        _MealDef('Lunch', 12, AppStrings.isId ? 'Makan Siang' : 'Lunch', Icons.wb_sunny_rounded, const Color(0xFFFFC107)),
        _MealDef('Snack', 15, AppStrings.isId ? 'Camilan Sore' : 'Afternoon Snack', Icons.cookie_rounded, const Color(0xFF8D6E63)),
        _MealDef('Dinner', 18, AppStrings.isId ? 'Makan Malam' : 'Dinner', Icons.nightlight_round, const Color(0xFF5C6BC0)),
      ];
      for (final meal in meals) {
        if (now.hour >= meal.hour) {
          final menu = _getMenuFor(todayLogs, meal.apiType);
          unified.add(_UnifiedNotification(
            id: -(meal.hour), // negative IDs for local items
            type: 'meal',
            mealType: meal.apiType,
            title: menu.isNotEmpty
                ? '${meal.label}: ${menu.split(', ').take(3).join(', ')}'
                : (AppStrings.isId ? '${meal.label} — belum dicatat' : '${meal.label} — not logged'),
            subtitle: '${_twoDigits(meal.hour)}.00',
            icon: meal.icon,
            iconColor: meal.color,
            isRead: true,
            createdAt: DateTime(now.year, now.month, now.day, meal.hour),
          ));
        }
      }

      // Sort all by time descending
      unified.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _allNotifications = unified;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getMenuFor(List<FoodLogEntry> logs, String mealApiType) {
    final items = logs.where((l) => l.mealTime == mealApiType).toList();
    if (items.isEmpty) return '';
    return items.map((e) => e.foodName).join(', ');
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'like': return Icons.favorite;
      case 'comment': return Icons.chat_bubble;
      case 'follow': return Icons.person_add;
      case 'follow_request': return Icons.person_add_disabled;
      case 'message': return Icons.chat;
      default: return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'like': return Colors.red;
      case 'comment': return const Color(0xFF64B5F6);
      case 'follow': return const Color(0xFF81C784);
      case 'follow_request': return Colors.orange;
      case 'message': return const Color(0xFF7E57C2);
      default: return Colors.orangeAccent;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return DateFormat('dd MMM').format(dt);
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _markAllRead() async {
    try {
      await _notifApi.markAllAsRead();
      _loadData();
    } catch (_) {}
  }

  Future<void> _onTap(_UnifiedNotification notif) async {
    // Mark as read (server notifications only)
    if (!notif.isRead && notif.id > 0) {
      try { await _notifApi.markAsRead(notif.id); } catch (_) {}
    }

    // Meal reminder → navigate to AddMealScreen
    if (notif.type == 'meal' && notif.mealType != null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddMealScreen(mealType: notif.mealType!),
        ),
      );
      return;
    }

    // Community notifications
    if (notif.type == 'message' && notif.actorId != null) {
      try {
        final chatApi = ChatApiService();
        final conv = await chatApi.createConversation(notif.actorId!);
        if (mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                conversationId: conv.id,
                otherUserName: notif.actorName ?? '',
              ),
            ),
          );
        }
      } catch (_) {}
    } else if (notif.type == 'follow' && notif.actorId != null) {
      final route = MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: notif.actorId!,
          userName: notif.actorName ?? '',
          api: CommunityPostApiService(),
        ),
      );
      Navigator.pop(context);
      Navigator.push(context, route);
    } else if ((notif.type == 'like' || notif.type == 'comment') && notif.postId != null) {
      // Fetch post BEFORE closing modal to avoid context issues
      try {
        final api = CommunityPostApiService();
        final posts = await api.getPosts();
        final post = posts.where((p) => p.id == notif.postId.toString()).firstOrNull;
        if (post != null && mounted) {
          final route = MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post, api: api),
          );
          Navigator.pop(context);
          Navigator.push(context, route);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: AppColors.navy, size: 18),
                  ),
                ),
                const Spacer(),
                Text(
                  AppStrings.inbox,
                  style: const TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_allNotifications.any((n) => !n.isRead))
                  GestureDetector(
                    onTap: _markAllRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppStrings.isId ? 'Baca semua' : 'Read all',
                        style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : _allNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.navy.withOpacity(0.2)),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.isId ? 'Belum ada notifikasi' : 'No notifications yet',
                              style: TextStyle(color: AppColors.navy.withOpacity(0.4), fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: AppColors.navy,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _allNotifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _buildNotifTile(_allNotifications[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifTile(_UnifiedNotification notif) {
    final isMeal = notif.type == 'meal';
    final isFollowRequest = notif.type == 'follow_request';
    return GestureDetector(
      onTap: isFollowRequest ? null : () => _onTap(notif),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: !notif.isRead && !isMeal
              ? AppColors.navy.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: !notif.isRead && !isMeal
              ? Border.all(color: AppColors.navy.withOpacity(0.1))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: notif.iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, color: notif.iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      children: [
                        if (notif.actorName != null)
                          TextSpan(
                            text: '${notif.actorName} ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
                          ),
                        TextSpan(text: notif.title),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.subtitle,
                    style: TextStyle(color: AppColors.navy.withOpacity(0.4), fontSize: 11),
                  ),
                  if (isFollowRequest) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _handleFollowRequest(notif.actorId, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.isId ? 'Terima' : 'Accept',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _handleFollowRequest(notif.actorId, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.close, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.isId ? 'Tolak' : 'Decline',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!notif.isRead && !isMeal && !isFollowRequest)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFollowRequest(int? actorId, bool approve) async {
    if (actorId == null) return;
    try {
      final api = CommunityPostApiService();
      if (approve) {
        await api.approveFollowRequest(actorId);
      } else {
        await api.rejectFollowRequest(actorId);
      }
      _loadData();
    } catch (_) {}
  }
}

class _UnifiedNotification {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final String? actorName;
  final int? actorId;
  final int? postId;
  final String? mealType;
  final bool isRead;
  final DateTime createdAt;
  final IconData icon;
  final Color iconColor;

  _UnifiedNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.actorName,
    this.actorId,
    this.postId,
    this.mealType,
    required this.isRead,
    required this.createdAt,
    required this.icon,
    required this.iconColor,
  });
}

class _MealDef {
  final String apiType;
  final int hour;
  final String label;
  final IconData icon;
  final Color color;
  _MealDef(this.apiType, this.hour, this.label, this.icon, this.color);
}
