import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/food_log_api_service.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final _foodLogApi = FoodLogApiService();
  bool _isLoading = true;
  List<FoodLogEntry> _todayLogs = [];
  List<FoodLogEntry> _yesterdayLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final results = await Future.wait([
        _foodLogApi.getLogs(now),
        _foodLogApi.getLogs(yesterday),
      ]);

      if (mounted) {
        setState(() {
          _todayLogs = results[0];
          _yesterdayLogs = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getMenuFor(List<FoodLogEntry> logs, String mealApiType) {
    final items = logs.where((l) => l.mealTime == mealApiType).toList();
    if (items.isEmpty) return "";
    return items.map((e) => e.foodName).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
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
                const Expanded(
                  child: Center(
                    child: Text(
                      'Kotak Masuk',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tetap teratur dengan pengingat makan harian Anda.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Today's Reminders (Only show if time has passed)
                      if (now.hour >= 18)
                        _buildMealItem(
                          logs: _todayLogs,
                          mealType: 'Dinner',
                          title: 'Pengingat Makan Malam',
                          date: '${df.format(now)} · 18.00',
                          defaultDesc: 'Tutup harimu dengan makan malam yang ringan',
                          icon: Icons.nightlight_round,
                        ),
                      if (now.hour >= 12)
                        _buildMealItem(
                          logs: _todayLogs,
                          mealType: 'Lunch',
                          title: 'Pengingat Makan Siang',
                          date: '${df.format(now)} · 12.00',
                          defaultDesc: 'Isi energi anda dengan makan siang bernutrisi',
                          icon: Icons.wb_sunny_rounded,
                        ),
                      if (now.hour >= 7)
                        _buildMealItem(
                          logs: _todayLogs,
                          mealType: 'Breakfast',
                          title: 'Pengingat Makan Pagi',
                          date: '${df.format(now)} · 07.00',
                          defaultDesc: 'Jangan lupa catat sarapan sehatmu hari ini!',
                          icon: Icons.wb_twilight,
                        ),
                      
                      // Yesterday's Reminders (Always show)
                      _buildMealItem(
                        logs: _yesterdayLogs,
                        mealType: 'Dinner',
                        title: 'Pengingat Makan Malam',
                        date: '${df.format(yesterday)} · 18.00',
                        defaultDesc: 'Tutup harimu dengan makan malam yang ringan',
                        icon: Icons.nightlight_round,
                      ),
                      _buildMealItem(
                        logs: _yesterdayLogs,
                        mealType: 'Lunch',
                        title: 'Pengingat Makan Siang',
                        date: '${df.format(yesterday)} · 12.00',
                        defaultDesc: 'Isi energi anda dengan makan siang bernutrisi',
                        icon: Icons.wb_sunny_rounded,
                      ),
                      _buildMealItem(
                        logs: _yesterdayLogs,
                        mealType: 'Breakfast',
                        title: 'Pengingat Makan Pagi',
                        date: '${df.format(yesterday)} · 07.00',
                        defaultDesc: 'Jangan lupa catat sarapan sehatmu hari ini!',
                        icon: Icons.wb_twilight,
                      ),
                    ],
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
    return NotificationItem(
      icon: icon,
      title: title,
      date: date,
      description: menu.isNotEmpty 
          ? 'Menu yang dijadwalkan: $menu' 
          : defaultDesc,
    );
  }
}

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String description;

  const NotificationItem({
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
