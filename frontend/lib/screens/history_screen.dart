// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/food_log_api_service.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import '../services/profile_api_service.dart';
import '../widgets/nutrify_calendar_picker.dart' show showNutrifyDatePicker, SelectionMode;
import 'food_detail_screen.dart';
import '../constants/assets.dart';
import '../widgets/nutrify_calendar_picker.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void refreshData() => _loadData();

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
    final date = await showNutrifyDatePicker(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      startMode: SelectionMode.day,
    );
    if (date != null && mounted) {
      _onDateChanged(date);
    }
  }

  List<FoodLogEntry> _logsForMeal(String mealTime) =>
      _logs.where((l) => l.mealTime == mealTime).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
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
                          Text(
                            'Nutrify',
                            style: GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.peach,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppStrings.nutritionHistory,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.calendar_month, color: AppColors.navy),
                      onPressed: _showCalendarPicker,
                    ),
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
                      color: NutrifyTheme.accentOrange,
                      backgroundColor: AppColors.cream,
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
                                    AppStrings.targetCalorie,
                                    _formatNumber(_targetCalories),
                                    'kkal',
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildSummaryCard(
                                    AppStrings.dailyCalorie,
                                    _formatNumber(_summary.totalCaloriesInt),
                                    'kkal',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),

                            // Meal Categories
                            _buildMealSection(
                                AppStrings.breakfast, 'Breakfast', Assets.iconPagi),
                            const SizedBox(height: 15),
                            _buildMealSection(
                                AppStrings.lunch, 'Lunch', Assets.iconSiang),
                            const SizedBox(height: 15),
                            _buildMealSection(
                                AppStrings.dinner, 'Dinner', Assets.iconMalam),
                            const SizedBox(height: 15),
                            _buildMealSection(
                                AppStrings.snack, 'Snack', Assets.iconCemilan),

                            if (_logs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    const Icon(Icons.restaurant_menu,
                                        color: Colors.white24, size: 48),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppStrings.noFoodRecordsToday,
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

  Widget _buildMealSection(String label, String mealKey, String iconPath) {
    final mealLogs = _logsForMeal(mealKey);
    final mealNutrition = _summary.byMeal[mealKey];
    final totalKcal = mealNutrition?.calories.round() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(iconPath, width: 32, height: 32),
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
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
