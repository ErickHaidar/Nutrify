import 'package:flutter/material.dart';
import 'package:nutrify/constants/assets.dart';
import 'add_meal_screen.dart';
import 'body_data_goals_screen.dart';
import 'tracking_kalori_screen.dart';
import '../services/food_log_api_service.dart';
import '../services/profile_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int totalCalories = 0;
  int targetCalories = 0;
  bool _isLoadingData = false;
  final FoodLogApiService _foodLogApi = FoodLogApiService();
  final ProfileApiService _profileApi = ProfileApiService();
  ApiProfileData? _profile;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;
  Map<String, int> caloriesByType = {
    'Makan Pagi': 0,
    'Makan Siang': 0,
    'Makan Malam': 0,
    'Cemilan': 0,
  };

  @override
  void initState() {
    super.initState();
    loadDailyData();
  }

  void loadDailyData() async {
    if (_isLoadingData) return;
    _isLoadingData = true;
    final now = DateTime.now();
    try {
      final summary = await _foodLogApi.getSummary(now);
      final profile = await _profileApi.getProfile();
      if (mounted) {
        setState(() {
          totalCalories = summary.totalCaloriesInt;
          totalProtein = summary.totals.protein;
          totalCarbs = summary.totals.carbohydrates;
          totalFat = summary.totals.fat;
          _profile = profile;
          targetCalories = (summary.targetCalories > 0)
              ? summary.targetCalories
              : (profile?.targetCalories ?? 0);
          caloriesByType = {
            'Makan Pagi': summary.caloriesForMeal('Breakfast'),
            'Makan Siang': summary.caloriesForMeal('Lunch'),
            'Makan Malam': summary.caloriesForMeal('Dinner'),
            'Cemilan': summary.caloriesForMeal('Snack'),
          };
        });
      }
    } catch (_) {
      // Keep existing values on error
    } finally {
      _isLoadingData = false;
    }
  }

  Widget _buildSetupProfileBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D2A4A), Color(0xFF433D67)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFFFCC80).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC80).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFFFCC80), size: 24),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'Halo! Perjalanan sehatmu baru dimulai.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Lengkapi data profilmu sekarang untuk mendapatkan target nutrisi yang presisi dan personal.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BodyDataGoalsScreen()),
                );
                if (result == true) {
                  loadDailyData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC80),
                foregroundColor: const Color(0xFF2D2A4A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                'Lengkapi Profil Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
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
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF433D67),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => loadDailyData(),
          color: const Color(0xFFFFCC80),
          backgroundColor: const Color(0xFF2D2A4A),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
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
                            Text(
                              'Nutrify',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.orange[200],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _getFormattedDate(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Suggestion for new users
                if (_profile == null) _buildSetupProfileBanner(),
  
                // Banner Utama (Tracking Kalori)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=500',
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.3,
                    ),
                    color: const Color(0xFFFFDDBE),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.restaurant, color: Color(0xFF2D2A4A)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Tracking Kalori Harian',
                                style: TextStyle(color: Color(0xFF2D2A4A)),
                              ),
                              Text(
                                '${_formatCalories(totalCalories)} KAL',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2A4A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                          backgroundColor: const Color(0xFF433D67),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Rincian',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
  
                // Target Kalori Row
                InkWell(
                  onTap: () async {
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
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2A4A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Kalori Harian',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${_formatCalories(totalCalories)} / ${_formatCalories(targetCalories)} kCal',
                              style: const TextStyle(
                                color: Color(0xFFFFCC80),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, color: Color(0xFFFFCC80)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
  
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
                      title: 'Makan Pagi',
                      imagePath: Assets.iconPagi,
                      color: Colors.amber,
                      calories: caloriesByType['Makan Pagi'] ?? 0,
                      onTap: () => _navigateToAddMeal('Makan Pagi'),
                    ),
                    MealTile(
                      title: 'Makan Siang',
                      imagePath: Assets.iconSiang,
                      color: Colors.orange,
                      calories: caloriesByType['Makan Siang'] ?? 0,
                      onTap: () => _navigateToAddMeal('Makan Siang'),
                    ),
                    MealTile(
                      title: 'Makan Malam',
                      imagePath: Assets.iconMalam,
                      color: Colors.indigoAccent,
                      calories: caloriesByType['Makan Malam'] ?? 0,
                      onTap: () => _navigateToAddMeal('Makan Malam'),
                    ),
                    MealTile(
                      title: 'Cemilan',
                      imagePath: Assets.iconCemilan,
                      color: Colors.brown,
                      calories: caloriesByType['Cemilan'] ?? 0,
                      onTap: () => _navigateToAddMeal('Cemilan'),
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
  }
}

// Komponen Kecil untuk Kotak Makan
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A4A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle, size: 16, color: Colors.white54),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Image.asset(
                imagePath,
                height: 48,
                width: 48,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                calories > 0
                    ? '${HomeScreenState.formatCalories(calories)} Kal'
                    : '- Kal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
