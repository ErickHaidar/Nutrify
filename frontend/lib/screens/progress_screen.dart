import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/services/progress_api_service.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'body_data_goals_screen.dart';
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
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0; // 0 for Kalori, 1 for Berat Badan

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
      final calories = await _apiService.getCalorieProgress();
      if (!mounted) return;
      setState(() {
        _weightData = weight..sort((a, b) => b.date.compareTo(a.date));
        _calorieData = calories..sort((a, b) => b.date.compareTo(a.date));
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

  String _formatFluidDate(DateTime date) {
    final dayStr = AppStrings.dayNamesShort[date.weekday - 1];
    final monthStr = AppStrings.monthNamesShort[date.month - 1];
    return "$dayStr ${date.day.toString().padLeft(2, '0')} $monthStr";
  }

  String _getWeightTrend() {
    if (_weightData.length < 2) return "-";
    final latest = _weightData.first.weight;
    final oldest = _weightData.last.weight;
    final diff = latest - oldest;
    if (diff > 0) return "+${diff.toStringAsFixed(1)} kg";
    if (diff < 0) return "${diff.toStringAsFixed(1)} kg";
    return "Tetap";
  }

  String _getAverageCalories() {
    if (_calorieData.isEmpty) return "-";
    final sum = _calorieData.fold(0.0, (prev, e) => prev + e.calories);
    return "${(sum / _calorieData.length).toStringAsFixed(0)} kcal";
  }

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.navy),
            onPressed: () => Navigator.pop(context),
          ),
        ),
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
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Grafik Progres",
          style: GoogleFonts.inter(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
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
                const SizedBox(height: 35),
              ],
              Text(
                _selectedTab == 0 ? "Riwayat Kalori" : "Riwayat Berat Badan",
                style: GoogleFonts.inter(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Kalori",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0 ? Colors.white : AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Berat Badan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1 ? Colors.white : AppColors.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "Rata-rata Kalori",
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getAverageCalories(),
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: AppColors.navy.withValues(alpha: 0.2)),
          Column(
            children: [
              Text(
                "Trend BB",
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getWeightTrend(),
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    final bool isCalorie = _selectedTab == 0;
    
    // Sort data for chart (ascending)
    final weightChartData = List<WeightProgress>.from(_weightData)..sort((a, b) => a.date.compareTo(b.date));
    final calorieChartData = List<CalorieProgress>.from(_calorieData)..sort((a, b) => a.date.compareTo(b.date));
    
    final bool hasEnoughData = isCalorie ? calorieChartData.length >= 3 : weightChartData.length >= 3;
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
      child: !hasEnoughData 
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Butuh minimal 3 hari data untuk melihat grafik ${isCalorie ? 'kalori' : 'berat badan'}", 
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6)),
              ),
            ),
          )
        : LineChart(
            LineChartData(
              gridData: FlGridData(
                show: false,
              ),
              titlesData: _buildTitlesData(dates, isCalorie),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: AppColors.navy.withValues(alpha: 0.15), width: 2),
                  left: BorderSide(color: AppColors.navy.withValues(alpha: 0.15), width: 2),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: isCalorie 
                      ? calorieChartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.calories)).toList()
                      : weightChartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                  isCurved: true,
                  color: AppColors.navy,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: AppColors.navy,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [AppColors.navy.withValues(alpha: 0.15), AppColors.navy.withValues(alpha: 0.0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => AppColors.navy,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = dates[spot.x.toInt()];
                      final dayStr = AppStrings.dayNamesShort[date.weekday - 1];
                      final monthStr = AppStrings.monthNamesShort[date.month - 1];
                      final dateStr = "$dayStr, ${date.day.toString().padLeft(2, '0')} $monthStr ${date.year}";
                      final valueStr = isCalorie 
                          ? "${spot.y.toStringAsFixed(0)} kcal"
                          : "${spot.y.toStringAsFixed(1)} kg";

                      return LineTooltipItem(
                        "$valueStr\n",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        children: [
                          TextSpan(
                            text: dateStr,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.normal, fontSize: 10),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 500), // swapAnimationDuration
            curve: Curves.easeInOut,
          ),
    );
  }

  Widget _buildAddWeightButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BodyDataGoalsScreen()),
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
          "Tambah Berat Badan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final bool isCalorie = _selectedTab == 0;
    final int itemCount = isCalorie ? _calorieData.length : _weightData.length;

    if (itemCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text("Belum ada riwayat ${isCalorie ? 'kalori' : 'berat badan'}"),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final DateTime date = isCalorie ? _calorieData[index].date : _weightData[index].date;
        final String valueStr = isCalorie 
            ? "${_calorieData[index].calories.toStringAsFixed(0)} kcal"
            : "${_weightData[index].weight.toStringAsFixed(1)} kg";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
              Text(
                _formatFluidDate(date),
                style: GoogleFonts.inter(
                  color: AppColors.navy.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                valueStr,
                style: GoogleFonts.inter(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  FlTitlesData _buildTitlesData(List<DateTime> dates, bool isCalorie) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < dates.length) {
              if (dates.length > 7 && index % 2 != 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppStrings.dayNamesShort[dates[index].weekday - 1],
                  style: GoogleFonts.notoSansMono(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.8)),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: isCalorie ? 50 : 40,
          interval: isCalorie ? 500 : 2,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                isCalorie ? (value.toInt() >= 1000 ? "${(value / 1000).toStringAsFixed(1)}k" : value.toInt().toString()) : value.toInt().toString(),
                style: GoogleFonts.notoSansMono(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.8)),
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
}
