import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/food_log_api_service.dart';
import '../services/notification_api_service.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final _foodLogApi = FoodLogApiService();
  final _notifApi = NotificationApiService();
  bool _isLoading = true;
  List<FoodLogEntry> _todayLogs = [];
  List<NotificationItem> _communityNotifs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        _foodLogApi.getLogs(now),
        _notifApi.getNotifications(),
      ]);
      if (mounted) {
        setState(() {
          _todayLogs = results[0] as List<FoodLogEntry>;
          _communityNotifs = results[1] as List<NotificationItem>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getMenuFor(List<FoodLogEntry> logs, String mealApiType) {
    final items = logs.where((l) => l.mealTime == mealApiType).toList();
    if (items.isEmpty) return "";
    return items.map((e) => e.foodName).join(', ');
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('dd MMM').format(dt);
  }

  Future<void> _markAllRead() async {
    try {
      await _notifApi.markAllAsRead();
      _loadData();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final df = DateFormat('dd MMMM', 'id_ID');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: AppColors.navy, size: 20),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.inbox,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_communityNotifs.any((n) => !n.isRead))
                  GestureDetector(
                    onTap: _markAllRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppStrings.isId ? 'Baca semua' : 'Read all',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 50),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.inboxSubtitle,
            style: const TextStyle(color: AppColors.navy, fontSize: 11),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.navy,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // Community notifications
                        if (_communityNotifs.isNotEmpty) ...[
                          _buildSectionHeader(AppStrings.isId ? 'Aktivitas' : 'Activity'),
                          ..._communityNotifs.map((n) => _buildCommunityItem(n)),
                          const SizedBox(height: 16),
                        ],
                        // Meal reminders
                        _buildSectionHeader(AppStrings.isId ? 'Pengingat Makan' : 'Meal Reminders'),
                        if (now.hour >= 18)
                          _buildMealItem(
                            logs: _todayLogs,
                            mealType: 'Dinner',
                            title: AppStrings.dinnerReminder,
                            date: '${df.format(now)} · 18.00',
                            defaultDesc: AppStrings.dinnerDefault,
                            icon: Icons.nightlight_round,
                          ),
                        if (now.hour >= 12)
                          _buildMealItem(
                            logs: _todayLogs,
                            mealType: 'Lunch',
                            title: AppStrings.lunchReminder,
                            date: '${df.format(now)} · 12.00',
                            defaultDesc: AppStrings.lunchDefault,
                            icon: Icons.wb_sunny_rounded,
                          ),
                        if (now.hour >= 7)
                          _buildMealItem(
                            logs: _todayLogs,
                            mealType: 'Breakfast',
                            title: AppStrings.breakfastReminder,
                            date: '${df.format(now)} · 07.00',
                            defaultDesc: AppStrings.breakfastDefault,
                            icon: Icons.wb_twilight,
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCommunityItem(NotificationItem notif) {
    final iconInfo = notif.iconData;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: notif.isRead ? null : Border.all(color: AppColors.navy.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconInfo.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconInfo.icon, color: iconInfo.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.navy.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: notif.actorName ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                      TextSpan(text: ' ${notif.body}'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(notif.createdAt),
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!notif.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealItem({
    required List<FoodLogEntry> logs,
    required String mealType,
    required String title,
    required String date,
    required String defaultDesc,
    required IconData icon,
  }) {
    final menu = _getMenuFor(logs, mealType);
    return NotificationItemWidget(
      icon: icon,
      title: title,
      date: date,
      description: menu.isNotEmpty ? AppStrings.scheduledMenu(menu) : defaultDesc,
    );
  }
}

class NotificationItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String description;

  const NotificationItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orangeAccent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
