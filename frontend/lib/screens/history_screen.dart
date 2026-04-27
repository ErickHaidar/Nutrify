// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/food_log_api_service.dart';
import '../services/profile_api_service.dart';
import '../widgets/nutrify_calendar_picker.dart';
import 'food_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _foodLogApi = FoodLogApiService();
  final _profileApi = ProfileApiService();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  int _targetCalories = 0;
  DailySummary _summary = DailySummary.empty();
  List<FoodLogEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _foodLogApi.getSummary(_selectedDate),
        _foodLogApi.getLogs(_selectedDate),
        _profileApi.getProfile(),
      ]);
      if (mounted) {
        setState(() {
          _summary = results[0] as DailySummary;
          _logs = results[1] as List<FoodLogEntry>;
          final profile = results[2] as ApiProfileData?;
          _targetCalories = profile?.targetCalories ?? 0;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    _loadData();
  }

  void _showCalendarPicker() async {
    final DateTime? picked = await showNutrifyDatePicker(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      _onDateChanged(picked);
    }
  }

  List<FoodLogEntry> _logsForMeal(String mealTime) =>
      _logs.where((l) => l.mealTime == mealTime).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Branded Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/nutrify-logo.png',
                            height: 40,
                            width: 40,
                          ),
                          const Text(
                            'Nutrify',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'History Nutrisi',
                        style: TextStyle(
                          color: AppColors.navy.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: AppColors.navy),
                    onPressed: _showCalendarPicker,
                  ),
                ],
              ),
            ),
            
            // Content Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.navy,
                      backgroundColor: NutrifyTheme.lightCard,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Summary Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Target Kalori',
                                    _formatNumber(_targetCalories),
                                    'kkal',
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Kalori Harian',
                                    _formatNumber(_summary.totalCaloriesInt),
                                    'kkal',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),

                            // Meal Categories
                            _buildMealSection(
                                'Makan Pagi', 'Breakfast', Icons.wb_sunny_outlined),
                            const SizedBox(height: 15),
                            _buildMealSection(
                                'Makan Siang', 'Lunch', Icons.wb_cloudy_outlined),
                            const SizedBox(height: 15),
                            _buildMealSection(
                                'Makan Malam', 'Dinner', Icons.nightlight_outlined),
                            const SizedBox(height: 15),
                            _buildMealSection(
                                'Cemilan', 'Snack', Icons.cookie_outlined),

                            if (_logs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    const Icon(Icons.restaurant_menu,
                                        color: Colors.white24, size: 48),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Belum ada catatan makanan untuk hari ini',
                                      style: TextStyle(
                                          color: Colors.white38, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String label, String mealKey, IconData icon) {
    final mealLogs = _logsForMeal(mealKey);
    final mealNutrition = _summary.byMeal[mealKey];
    final totalKcal = mealNutrition?.calories.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NutrifyTheme.lightCard,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.navy),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$totalKcal kcal',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (mealLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Belum ada catatan',
                style: TextStyle(color: AppColors.navy.withOpacity(0.3), fontSize: 13),
              ),
            )
          else
            ...mealLogs.map((entry) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailScreen(
                            logEntry: entry,
                            mealType: label,
                          ),
                        ),
                      );
                      if (result == true && mounted) {
                        _loadData();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.foodName,
                              style: TextStyle(
                                  color: AppColors.navy.withOpacity(0.7), fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${entry.calories.round()} kcal',
                            style: TextStyle(
                                color: AppColors.navy.withOpacity(0.7), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NutrifyTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(color: AppColors.navy.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// End of HistoryScreen
