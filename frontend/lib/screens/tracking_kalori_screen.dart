import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../services/food_log_api_service.dart';
import '../services/profile_api_service.dart';

class TrackingKaloriScreen extends StatefulWidget {
  const TrackingKaloriScreen({super.key});

  @override
  State<TrackingKaloriScreen> createState() => _TrackingKaloriScreenState();
}

class _TrackingKaloriScreenState extends State<TrackingKaloriScreen> {
  final FoodLogApiService _foodLogApi = FoodLogApiService();
  final ProfileApiService _profileApi = ProfileApiService();

  int _totalCalories = 0;
  int _targetCalories = 0;
  double _totalProtein = 0;
  double _totalCarbohydrates = 0;
  double _totalFat = 0;
  DailySummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    try {
      final summary = await _foodLogApi.getSummary(now);
      final profile = await _profileApi.getProfile();
      if (mounted) {
        setState(() {
          _summary = summary;
          _totalCalories = summary.totalCaloriesInt;
          _targetCalories = (summary.targetCalories > 0)
              ? summary.targetCalories
              : (profile?.targetCalories ?? 0);
          _totalProtein = summary.totals.protein;
          _totalCarbohydrates = summary.totals.carbohydrates;
          _totalFat = summary.totals.fat;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCalories(int calories) {
    return calories.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = math.max(0, _targetCalories - _totalCalories);
    final progress = _targetCalories > 0
        ? (_totalCalories / _targetCalories).clamp(0.0, 1.0)
        : 0.0;

    // Macro targets from calorie goal (standard distribution)
    final int targetCarbs = ((_targetCalories * 0.5) / 4).round();
    final int targetProtein = ((_targetCalories * 0.2) / 4).round();
    final int targetFat = ((_targetCalories * 0.3) / 9).round();

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF433D67),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF433D67),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tracking Kalori Harian',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFCC80),
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFFFCC80),
        backgroundColor: const Color(0xFF2D2A4A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Circular Progress ────────────────────────────────────────
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: GradientCircularPainter(
                        progress: progress,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFFFFDDBE),
                            progress >= 1.0
                                ? Colors.redAccent
                                : const Color(0xFFFF5722),
                            progress >= 1.0
                                ? Colors.redAccent
                                : const Color(0xFFFF5722),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          startAngle: -math.pi / 2,
                          endAngle: 3 * math.pi / 2,
                        ),
                        backgroundColor:
                            const Color(0xFFFFDDBE).withOpacity(0.15),
                        strokeWidth: 14,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Kalori',
                          style: GoogleFonts.montserrat(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatCalories(_totalCalories),
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'kkal',
                          style: GoogleFonts.montserrat(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Sisa & Target ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Sisa',
                      value: '${_formatCalories(remaining)} kkal',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: remaining == 0
                          ? Colors.redAccent
                          : const Color(0xFF69F0AE),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Target Kalori Harian',
                      value: '${_formatCalories(_targetCalories)} kkal',
                      icon: Icons.flag_rounded,
                      iconColor: const Color(0xFFFFCC80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Makronutrien ─────────────────────────────────────────────
              Text(
                'Makronutrien',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildMacroBar(
                label: 'Karbohidrat',
                icon: Icons.grain_rounded,
                color: const Color(0xFF64B5F6),
                current: _totalCarbohydrates,
                target: targetCarbs.toDouble(),
                unit: 'g',
              ),
              const SizedBox(height: 10),
              _buildMacroBar(
                label: 'Protein',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFEF9A9A),
                current: _totalProtein,
                target: targetProtein.toDouble(),
                unit: 'g',
              ),
              const SizedBox(height: 10),
              _buildMacroBar(
                label: 'Lemak',
                icon: Icons.water_drop_rounded,
                color: const Color(0xFFFFE082),
                current: _totalFat,
                target: targetFat.toDouble(),
                unit: 'g',
              ),
              const SizedBox(height: 24),

              // ── Per Waktu Makan ──────────────────────────────────────────
              Text(
                'Riwayat per Waktu Makan',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildMealRows(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2A4A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar({
    required String label,
    required IconData icon,
    required Color color,
    required double current,
    required double target,
    required String unit,
  }) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final over = target > 0 && current > target;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2A4A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
                style: TextStyle(
                  color: over ? Colors.redAccent : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                over ? Colors.redAccent : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMealRows() {
    const meals = [
      ('Breakfast', 'Makan Pagi', Icons.wb_sunny_rounded),
      ('Lunch', 'Makan Siang', Icons.light_mode_rounded),
      ('Dinner', 'Makan Malam', Icons.nights_stay_rounded),
      ('Snack', 'Cemilan', Icons.cookie_rounded),
    ];

    return meals.map<Widget>((m) {
      final (key, label, icon) = m;
      final meal = _summary?.byMeal[key];
      final kcal = meal?.calories.round() ?? 0;
      final hasData = kcal > 0;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A4A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasData
                    ? const Color(0xFFFFCC80).withOpacity(0.18)
                    : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: hasData ? const Color(0xFFFFCC80) : Colors.white30,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasData ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (hasData) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$kcal kkal',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFFFFCC80),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'P ${meal!.protein.toStringAsFixed(0)}g  C ${meal.carbohydrates.toStringAsFixed(0)}g  L ${meal.fat.toStringAsFixed(0)}g',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ] else
              const Text(
                'Belum ada catatan',
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
          ],
        ),
      );
    }).toList();
  }
}

class GradientCircularPainter extends CustomPainter {
  final double progress;
  final SweepGradient gradient;
  final Color backgroundColor;
  final double strokeWidth;

  GradientCircularPainter({
    required this.progress,
    required this.gradient,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GradientCircularPainter old) =>
      old.progress != progress;
}


