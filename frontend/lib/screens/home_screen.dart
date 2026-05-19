import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/constants/assets.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/home/store/home_store.dart';
import 'add_meal_screen.dart';
import 'body_data_goals_screen.dart';
import 'calorie_tracking_screen.dart';
import 'help_screen.dart';
import 'progress_screen.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/presentation/home/store/language/language_store.dart';
import '../widgets/notification_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final HomeStore _homeStore = getIt<HomeStore>();
  bool _isShowingNotifications = false;
  void loadDailyData({bool forceRefresh = false}) {
    _homeStore.loadDailyData(forceRefresh: forceRefresh);
  }

  @override
  void initState() {
    super.initState();
    _homeStore.loadDailyData(forceRefresh: true);
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
    final bool isProfileIncomplete = _homeStore.profile == null || 
                                     _homeStore.profile!.age == 0 || 
                                     _homeStore.profile!.weight == 0 || 
                                     _homeStore.profile!.height == 0;
    
    if (isProfileIncomplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan lengkapi profil Anda terlebih dahulu untuk mengatur target nutrisi."),
          backgroundColor: Colors.redAccent,
        ),
      );
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BodyDataGoalsScreen(),
        ),
      );
      if (result == true) {
        _homeStore.loadDailyData(forceRefresh: true);
      }
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(mealType: mealType),
      ),
    );

    if (result == true) {
      _homeStore.loadDailyData();
    }
  }

  void _showNotifications() async {
    if (_isShowingNotifications) return;
    _isShowingNotifications = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const NotificationModal(),
    );
    _isShowingNotifications = false;
    _homeStore.loadDailyData(); // Refresh after notifications
  }

  @override
  Widget build(BuildContext context) {
    final languageStore = getIt<LanguageStore>();
    return Observer(
      builder: (_) {
        // Reference locale to trigger rebuild on language change
        final _ = languageStore.locale;
        return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _homeStore.loadDailyData(forceRefresh: true),
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

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.navy.withOpacity(0.1),
                            child: const Icon(Icons.help_outline, color: AppColors.navy),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showNotifications,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.navy.withOpacity(0.1),
                                child: const Icon(Icons.notifications, color: AppColors.navy),
                              ),
                              Observer(
                                builder: (_) => _homeStore.unreadCount > 0
                                    ? Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                          child: Text(
                                            _homeStore.unreadCount > 99 ? '99+' : '${_homeStore.unreadCount}',
                                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Card/banner
                Observer(
                  builder: (_) => (_homeStore.profile == null || 
                                   _homeStore.profile!.age == 0 || 
                                   _homeStore.profile!.weight == 0 || 
                                   _homeStore.profile!.height == 0)
                      ? _buildCompleteProfileBanner()
                      : const SizedBox.shrink(),
                ),

                // Tracking Kalori Harian Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: NutrifyTheme.lightCard,
                    borderRadius: BorderRadius.circular(30),
                    image: const DecorationImage(
                      image: AssetImage(Assets.foodRegister),
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
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Observer(
                        builder: (_) => Text(
                          '${_formatCalories(_homeStore.totalCalories)} ${AppStrings.cal}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Observer(
                        builder: (_) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _homeStore.targetCalories > 0
                                ? (_homeStore.totalCalories / _homeStore.targetCalories).clamp(0.0, 1.0)
                                : 0,
                            backgroundColor: AppColors.navy.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Observer(
                            builder: (_) => Text(
                              AppStrings.percentOfTarget(_homeStore.targetCalories > 0 
                                  ? (_homeStore.totalCalories / _homeStore.targetCalories * 100).toInt() 
                                  : 0),
                              style: TextStyle(
                                color: AppColors.navy.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CalorieTrackingScreen(),
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              AppStrings.details,
                              style: const TextStyle(
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
                      _homeStore.loadDailyData(forceRefresh: true);
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
                            Observer(
                              builder: (_) => Text(
                                '${_formatCalories(_homeStore.targetCalories)} ${AppStrings.kcal}',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.navy),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Weight Progress Card
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProgressScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Grafik Perkembangan Berat Badan",
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: AppColors.navy.withValues(alpha: 0.1)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Observer(
                              builder: (_) => Text(
                                "${_homeStore.profile?.weight ?? 70} kg",
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 40,
                              child: IgnorePointer(
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(0, 1),
                                          FlSpot(1, 1.5),
                                          FlSpot(2, 1.4),
                                          FlSpot(3, 3.4),
                                          FlSpot(4, 2),
                                          FlSpot(5, 2.2),
                                          FlSpot(6, 1.8),
                                        ],
                                        isCurved: true,
                                        color: AppColors.navy,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.navy.withValues(alpha: 0.2),
                                              AppColors.navy.withValues(alpha: 0.0),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                    Observer(
                      builder: (_) => MealTile(
                        title: AppStrings.breakfast,
                        imagePath: Assets.breakfastIcon,
                        color: AppColors.peach,
                        calories: _homeStore.caloriesByType[AppStrings.breakfast] ?? 0,
                        onTap: () => _navigateToAddMeal(AppStrings.breakfast),
                      ),
                    ),
                    Observer(
                      builder: (_) => MealTile(
                        title: AppStrings.lunch,
                        imagePath: Assets.lunchIcon,
                        color: AppColors.peach,
                        calories: _homeStore.caloriesByType[AppStrings.lunch] ?? 0,
                        onTap: () => _navigateToAddMeal(AppStrings.lunch),
                      ),
                    ),
                    Observer(
                      builder: (_) => MealTile(
                        title: AppStrings.dinner,
                        imagePath: Assets.dinnerIcon,
                        color: AppColors.peach,
                        calories: _homeStore.caloriesByType[AppStrings.dinner] ?? 0,
                        onTap: () => _navigateToAddMeal(AppStrings.dinner),
                      ),
                    ),
                    Observer(
                      builder: (_) => MealTile(
                        title: AppStrings.snack,
                        imagePath: Assets.snackIcon,
                        color: AppColors.peach,
                        calories: _homeStore.caloriesByType[AppStrings.snack] ?? 0,
                        onTap: () => _navigateToAddMeal(AppStrings.snack),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
      },
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
                  style: const TextStyle(
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
            style: const TextStyle(
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
                  _homeStore.loadDailyData(forceRefresh: true);
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
    required this.calories,
    required this.onTap,
  });

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
                calories > 0 ? '${HomeScreenState.formatCalories(calories)} ${AppStrings.kal}' : '- ${AppStrings.kal}',
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
