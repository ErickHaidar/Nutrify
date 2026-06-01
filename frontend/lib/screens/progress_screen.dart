import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/services/progress_api_service.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_weight_screen.dart';
import 'package:dio/dio.dart';
import 'package:nutrify/utils/dio/dio_error_util.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  final ProgressApiService _apiService = getIt<ProgressApiService>();

  List<WeightProgress> _weightData = [];
  List<CalorieProgress> _calorieData = [];
  int? _calorieTarget;
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final weight = await _apiService.getWeightProgress();
      final calorieResult = await _apiService.getCalorieProgress();
      if (!mounted) return;
      setState(() {
        _weightData = weight..sort((a, b) => b.date.compareTo(a.date));
        _calorieData = calorieResult.data..sort((a, b) => b.date.compareTo(a.date));
        _calorieTarget = calorieResult.targetCalories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      String friendlyMessage = "Terjadi kesalahan. Silakan coba lagi nanti.";
      if (e is DioException) {
        friendlyMessage = DioExceptionUtil.handleError(e);
      } else {
        friendlyMessage = e.toString();
      }
      setState(() {
        _isLoading = false;
        _error = friendlyMessage;
      });
    }
  }

  void refreshData() {
    _loadData();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Hari ini';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Kemarin';
    final dayStr = AppStrings.dayNamesShort[date.weekday - 1];
    final monthStr = AppStrings.monthNamesShort[date.month - 1];
    return "$dayStr ${date.day.toString().padLeft(2, '0')} $monthStr";
  }

  // ── Weight metrics ─────────────────────────────────────────────────────────

  double? get _weightLatest => _weightData.isNotEmpty ? _weightData.first.weight : null;
  double? get _weightStart => _weightData.isNotEmpty ? _weightData.last.weight : null;

  double? get _weightChange {
    if (_weightLatest == null || _weightStart == null) return null;
    return _weightLatest! - _weightStart!;
  }

  String _weightTrendLabel() {
    if (_weightChange == null) return '-';
    final diff = _weightChange!;
    if (diff > 0) return '+${diff.toStringAsFixed(1)} kg';
    if (diff < 0) return '${diff.toStringAsFixed(1)} kg';
    return 'Tetap';
  }

  bool get _weightIsUp => _weightChange != null && _weightChange! > 0;
  bool get _weightIsDown => _weightChange != null && _weightChange! < 0;

  // ── Calorie metrics ────────────────────────────────────────────────────────

  double get _avgCalories {
    if (_calorieData.isEmpty) return 0;
    return _calorieData.fold(0.0, (s, e) => s + e.calories) / _calorieData.length;
  }

  bool get _calorieOverTarget => _calorieTarget != null && _avgCalories > _calorieTarget!;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const Color creamBackground = Color(0xFFF8EFE4);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: creamBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.navy)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: creamBackground,
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.navy)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
                  child: Text(AppStrings.resend, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.navy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabSelector(),
              const SizedBox(height: 20),
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildChartCard(),
              const SizedBox(height: 25),
              if (_selectedTab == 1) ...[
                _buildAddWeightButton(),
                const SizedBox(height: 30),
              ],
              _buildHistoryHeader(),
              const SizedBox(height: 12),
              _buildHistoryList(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.navy),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Grafik Progres',
        style: GoogleFonts.inter(
          color: AppColors.navy,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  // ── Tab selector ───────────────────────────────────────────────────────────

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Kalori',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0 ? Colors.white : AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Berat Badan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1 ? Colors.white : AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary card ───────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    final bool isCalorie = _selectedTab == 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.peach.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: isCalorie ? _buildCalorieSummary() : _buildWeightSummary(),
    );
  }

  Widget _buildCalorieSummary() {
    final avgStr = _calorieData.isEmpty ? '-' : '${_avgCalories.toStringAsFixed(0)} kcal';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _summaryMetric('Rata-rata Kalori', avgStr),
        Container(width: 1, height: 40, color: AppColors.navy.withValues(alpha: 0.2)),
        _summaryMetric(
          'Target Harian',
          _calorieTarget != null ? '${_calorieTarget!} kcal' : '-',
        ),
        Container(width: 1, height: 40, color: AppColors.navy.withValues(alpha: 0.2)),
        _summaryMetric(
          'Status',
          _calorieData.isEmpty ? '-' : (_calorieOverTarget ? 'Di atas' : 'Di bawah'),
          valueColor: _calorieOverTarget ? Colors.redAccent : Colors.green.shade700,
        ),
      ],
    );
  }

  Widget _buildWeightSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _summaryMetric('Berat Saat Ini', _weightLatest != null ? '${_weightLatest!.toStringAsFixed(1)} kg' : '-'),
        Container(width: 1, height: 40, color: AppColors.navy.withValues(alpha: 0.2)),
        _summaryMetric(
          'Perubahan',
          _weightTrendLabel(),
          valueColor: _weightIsUp ? Colors.redAccent : (_weightIsDown ? Colors.green.shade700 : AppColors.navy),
        ),
        Container(width: 1, height: 40, color: AppColors.navy.withValues(alpha: 0.2)),
        _summaryMetric('Total Data', '${_weightData.length} hari'),
      ],
    );
  }

  Widget _summaryMetric(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Chart ──────────────────────────────────────────────────────────────────

  Widget _buildChartCard() {
    final bool isCalorie = _selectedTab == 0;

    final weightChartData = List<WeightProgress>.from(_weightData)..sort((a, b) => a.date.compareTo(b.date));
    final calorieChartData = List<CalorieProgress>.from(_calorieData)..sort((a, b) => a.date.compareTo(b.date));

    final int dataCount = isCalorie ? calorieChartData.length : weightChartData.length;
    final List<DateTime> dates = isCalorie
        ? calorieChartData.map((e) => e.date).toList()
        : weightChartData.map((e) => e.date).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: dataCount < 2
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart, size: 40, color: AppColors.navy.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      isCalorie
                          ? 'Butuh minimal 2 hari data kalori untuk grafik'
                          : 'Butuh minimal 2 hari data berat badan untuk grafik',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            )
          : LineChart(
              _buildChartData(dates, calorieChartData, weightChartData, isCalorie),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
    );
  }

  LineChartData _buildChartData(
    List<DateTime> dates,
    List<CalorieProgress> calorieChartData,
    List<WeightProgress> weightChartData,
    bool isCalorie,
  ) {
    final spots = isCalorie
        ? calorieChartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.calories)).toList()
        : weightChartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList();

    final yValues = spots.map((s) => s.y).toList();
    final yMin = yValues.reduce((a, b) => a < b ? a : b);
    final yMax = yValues.reduce((a, b) => a > b ? a : b);
    final yRange = yMax - yMin;

    // Padding 15% dari range agar grafik tidak mentok
    final double padding = yRange == 0 ? (isCalorie ? 100 : 1) : yRange * 0.15;
    final double minY = (yMin - padding).clamp(0, double.infinity);
    final double maxY = yMax + padding;

    final List<LineChartBarData> lineBars = [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.25,
        color: AppColors.navy,
        barWidth: 3.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: dates.length <= 14,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2.5,
            strokeColor: AppColors.navy,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [AppColors.navy.withValues(alpha: 0.12), AppColors.navy.withValues(alpha: 0.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];

    // Garis target kalori
    if (isCalorie && _calorieTarget != null) {
      lineBars.add(
        LineChartBarData(
          spots: [
            FlSpot(0, _calorieTarget!.toDouble()),
            FlSpot((dates.length - 1).toDouble(), _calorieTarget!.toDouble()),
          ],
          isCurved: false,
          color: Colors.orange.withValues(alpha: 0.6),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [8, 5],
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: isCalorie ? ((maxY - minY) / 4) : ((maxY - minY) / 4),
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.navy.withValues(alpha: 0.06),
          strokeWidth: 1,
        ),
      ),
      titlesData: _buildTitlesData(dates, isCalorie, minY, maxY),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: AppColors.navy.withValues(alpha: 0.15), width: 2),
          left: BorderSide(color: AppColors.navy.withValues(alpha: 0.15), width: 2),
          right: BorderSide.none,
          top: BorderSide.none,
        ),
      ),
      lineBarsData: lineBars,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.navy,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= dates.length) return null;
              final date = dates[index];
              final dayStr = AppStrings.dayNamesShort[date.weekday - 1];
              final monthStr = AppStrings.monthNamesShort[date.month - 1];
              final dateStr = '$dayStr, ${date.day.toString().padLeft(2, '0')} $monthStr ${date.year}';

              // Skip target line in tooltip
              if (spot.barIndex == 1) return null;

              final valueStr = isCalorie
                  ? '${spot.y.toStringAsFixed(0)} kcal'
                  : '${spot.y.toStringAsFixed(1)} kg';

              return LineTooltipItem(
                '$valueStr\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                children: [
                  TextSpan(
                    text: dateStr,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.normal, fontSize: 10),
                  ),
                ],
              );
            }).whereType<LineTooltipItem>().toList();
          },
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<DateTime> dates, bool isCalorie, double minY, double maxY) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= dates.length) return const SizedBox.shrink();
            if (dates.length > 10 && index % 2 != 0) return const SizedBox.shrink();
            // For 30-day view, show every 3rd day
            if (dates.length > 14 && index % 3 != 0 && index != dates.length - 1) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${dates[index].day}/${dates[index].month}',
                style: GoogleFonts.notoSansMono(fontSize: 10, color: AppColors.navy.withValues(alpha: 0.7)),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: isCalorie ? 50 : 40,
          getTitlesWidget: (value, meta) {
            if (value < minY || value > maxY) return const SizedBox.shrink();
            String text;
            if (isCalorie) {
              text = value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : value.toInt().toString();
            } else {
              text = value.toStringAsFixed(1);
            }
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                text,
                style: GoogleFonts.notoSansMono(fontSize: 11, color: AppColors.navy.withValues(alpha: 0.7)),
                textAlign: TextAlign.right,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // ── Add weight button ──────────────────────────────────────────────────────

  Widget _buildAddWeightButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWeightScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Tambah Berat Badan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── History ────────────────────────────────────────────────────────────────

  Widget _buildHistoryHeader() {
    final bool isCalorie = _selectedTab == 0;
    final int count = isCalorie ? _calorieData.length : _weightData.length;

    return Row(
      children: [
        Text(
          isCalorie ? 'Riwayat Kalori' : 'Riwayat Berat Badan',
          style: GoogleFonts.inter(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count hari',
              style: GoogleFonts.inter(
                color: AppColors.navy.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryList() {
    final bool isCalorie = _selectedTab == 0;
    final int itemCount = isCalorie ? _calorieData.length : _weightData.length;

    if (itemCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: AppColors.navy.withValues(alpha: 0.25)),
              const SizedBox(height: 12),
              Text(
                isCalorie
                    ? 'Belum ada riwayat kalori.\nData akan muncul setelah kamu mencatat makanan.'
                    : 'Belum ada riwayat berat badan.\nTap "Tambah Berat Badan" untuk mulai.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final DateTime date = isCalorie ? _calorieData[index].date : _weightData[index].date;
        final String valueStr = isCalorie
            ? '${_calorieData[index].calories.toStringAsFixed(0)} kcal'
            : '${_weightData[index].weight.toStringAsFixed(1)} kg';

        final isToday = _isSameDay(date, DateTime.now());

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isToday ? AppColors.peach.withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: isToday
                ? Border.all(color: AppColors.peach, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isToday)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.navy,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    _formatRelativeDate(date),
                    style: GoogleFonts.inter(
                      color: isToday ? AppColors.navy : AppColors.navy.withValues(alpha: 0.7),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                valueStr,
                style: GoogleFonts.inter(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
