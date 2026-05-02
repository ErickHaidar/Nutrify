import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/assets.dart';
import 'package:nutrify/widgets/skeletons/home_skeleton.dart';
import 'add_meal_screen.dart';
import 'body_data_goals_screen.dart';
import 'tracking_kalori_screen.dart';
import 'help_screen.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import '../services/food_log_api_service.dart';
import '../services/profile_api_service.dart';
import '../widgets/notification_modal.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int totalCalories = 0;
  int targetCalories = 0;
  bool _isLoadingData = false;
  bool _showTip = false;
  Timer? _tipTimer;
  final FoodLogApiService _foodLogApi = FoodLogApiService();
  final ProfileApiService _profileApi = ProfileApiService();
  ApiProfileData? _profile;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;
  Map<String, int> caloriesByType = {
    AppStrings.breakfast: 0,
    AppStrings.lunch: 0,
    AppStrings.dinner: 0,
    AppStrings.snack: 0,
  };

  Offset? _notificationTapStart;

  @override
  void initState() {
    super.initState();
    loadDailyData();
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  void loadDailyData({bool forceRefresh = false}) async {
    if (_isLoadingData) return;

    _showTip = false;
    _tipTimer?.cancel();
    _tipTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && _isLoadingData) {
        setState(() => _showTip = true);
      }
    });

    setState(() {
      _isLoadingData = true;
    });
    final now = DateTime.now();

    try {
      final results = await Future.wait([
        _foodLogApi.getSummary(now).catchError((_) => null),
        _profileApi.getProfile(forceRefresh: forceRefresh).catchError((_) => null),
      ]);

      final summary = results[0] as DailySummary?;
      final profile = results[1] as ApiProfileData?;

      if (mounted) {
        setState(() {
          if (profile != null) {
            _profile = profile;
          }

          if (summary != null) {
            totalCalories = summary.totalCaloriesInt;
            totalProtein = summary.totals.protein;
            totalCarbs = summary.totals.carbohydrates;
            totalFat = summary.totals.fat;
            targetCalories = (summary.targetCalories > 0)
                ? summary.targetCalories
                : (profile?.targetCalories ?? 0);
            caloriesByType = {
              AppStrings.breakfast: summary.caloriesForMeal('Breakfast'),
              AppStrings.lunch: summary.caloriesForMeal('Lunch'),
              AppStrings.dinner: summary.caloriesForMeal('Dinner'),
              AppStrings.snack: summary.caloriesForMeal('Snack'),
            };
          } else if (profile != null) {
            targetCalories = profile.targetCalories;
          }
        });
      }
    } finally {
      _tipTimer?.cancel();
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  static String formatCalories(int calories) {
    return calories.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatCalories(int calories) => formatCalories(calories);

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = AppStrings.monthNames;
    return "${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}";
  }

  void _navigateToAddMeal(String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(mealType: mealType),
      ),
    );

    if (result == true) {
      loadDailyData();
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const NotificationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => loadDailyData(),
          color: AppColors.amber,
          backgroundColor: AppColors.navy,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              Assets.nutrifyLogo,
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nutrify',
                              style: GoogleFonts.inter(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFFB26B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _getFormattedDate(),
                          style: TextStyle(
                            color: AppColors.navy.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTapDown: (details) {
                        _notificationTapStart = details.globalPosition;
                      },
                      onTapUp: (details) {
                        final start = _notificationTapStart;
                        if (start != null) {
                          final dx = (details.globalPosition.dx - start.dx).abs();
                          final dy = (details.globalPosition.dy - start.dy).abs();
                          const double deadzone = 8.0; // logical pixels
                          if (dx <= deadzone && dy <= deadzone) {
                            _showNotifications();
                          }
                        }
                        _notificationTapStart = null;
                      },
                      onTapCancel: () {
                        _notificationTapStart = null;
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColors.navy.withOpacity(0.1),
                        child: const Icon(Icons.notifications, color: AppColors.navy),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

          // Card/banner
          if (_profile == null || _profile!.age == 0 || _profile!.weight == 0 || _profile!.height == 0)
            _buildCompleteProfileBanner(),

          // Tracking Kalori Harian Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: NutrifyTheme.lightCard,
              borderRadius: BorderRadius.circular(30),
              image: const DecorationImage(
                image: AssetImage(Assets.makananRegister),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
              boxShadow: [
                BoxShadow(
                  color: NutrifyTheme.lightCard.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppColors.navy,
                        size: 20,
                      ),
                    ),
                    Text(
                      AppStrings.dailyCalorieTracking,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${_formatCalories(totalCalories)} ${AppStrings.cal}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedProgressBar(
                  value: targetCalories > 0 ? (totalCalories / targetCalories).clamp(0.0, 1.0) : 0,
                  backgroundColor: AppColors.navy.withOpacity(0.1),
                  valueColor: AppColors.navy,
                  minHeight: 10,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.percentOfTarget(targetCalories > 0 ? (totalCalories / targetCalories * 100).toInt() : 0),
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrackingKaloriScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        AppStrings.details,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Target Kalori Card
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BodyDataGoalsScreen(),
                ),
              );
              if (result == true) {
                loadDailyData(forceRefresh: true);
              }
            },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: NutrifyTheme.lightCard,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: NutrifyTheme.lightCard.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.dailyCalorieTarget,
                        style: TextStyle(
                          color: AppColors.navy.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatCalories(targetCalories)} kCal',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.navy),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black12, height: 40),

          // Grid Makan
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              MealTile(
                title: AppStrings.breakfast,
                imagePath: Assets.iconPagi,
                color: AppColors.peach,
                calories: caloriesByType[AppStrings.breakfast] ?? 0,
                onTap: () => _navigateToAddMeal(AppStrings.breakfast),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
              MealTile(
                title: AppStrings.lunch,
                imagePath: Assets.iconSiang,
                color: AppColors.peach,
                calories: caloriesByType[AppStrings.lunch] ?? 0,
                onTap: () => _navigateToAddMeal(AppStrings.lunch),
              ).animate(delay: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
              MealTile(
                title: AppStrings.dinner,
                imagePath: Assets.iconMalam,
                color: AppColors.peach,
                calories: caloriesByType[AppStrings.dinner] ?? 0,
                onTap: () => _navigateToAddMeal(AppStrings.dinner),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
              MealTile(
                title: AppStrings.snack,
                imagePath: Assets.iconCemilan,
                color: AppColors.peach,
                calories: caloriesByType[AppStrings.snack] ?? 0,
                onTap: () => _navigateToAddMeal(AppStrings.snack),
              ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
        ),
      ),
    );
  }

  Widget _buildCompleteProfileBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.peach.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  AppStrings.helloJourneyStarts,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.completeProfileDesc,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BodyDataGoalsScreen(),
                  ),
                );
                if (result == true) {
                  loadDailyData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shadowColor: AppColors.navy.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.completeProfileNow,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MealTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color color;
  final int calories;
  final VoidCallback onTap;

  const MealTile({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.color,
    required this.calories,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = color == AppColors.navy;
    final Color textColor = isDark ? Colors.white : AppColors.navy;
    final Color subTextColor = isDark ? Colors.white54 : AppColors.navy.withOpacity(0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
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
                Icon(Icons.add_circle, size: 16, color: subTextColor),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Image.asset(
                imagePath,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                calories > 0 ? '${HomeScreenState.formatCalories(calories)} Kal' : '- Kal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: subTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
