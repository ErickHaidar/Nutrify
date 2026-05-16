import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/services/progress_api_service.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'body_data_goals_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  final ProgressApiService _apiService = getIt<ProgressApiService>();
  
  List<WeightProgress> _weightData = [];
  bool _isLoading = true;
  String? _error;

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
      if (!mounted) return;
      setState(() {
        // Sort weight data by date descending for the list
        _weightData = weight..sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
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
          "Riwayat Berat Badan",
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
              _buildWeightChartCard(),
              const SizedBox(height: 25),
              _buildAddWeightButton(),
              const SizedBox(height: 35),
              Text(
                "Riwayat Berat Badan",
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

  Widget _buildWeightChartCard() {
    // Sort data for chart (ascending)
    final chartData = List<WeightProgress>.from(_weightData)..sort((a, b) => a.date.compareTo(b.date));
    
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: chartData.length < 2 
        ? Center(child: Text(AppStrings.needMoreData, textAlign: TextAlign.center))
        : LineChart(
            LineChartData(
              gridData: FlGridData(
                show: false,
              ),
              titlesData: _buildTitlesData(chartData.map((e) => e.date).toList()),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: AppColors.navy.withOpacity(0.15), width: 2),
                  left: BorderSide(color: AppColors.navy.withOpacity(0.15), width: 2),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                  isCurved: false,
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
                      colors: [AppColors.navy.withOpacity(0.15), AppColors.navy.withOpacity(0.0)],
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
                      final date = chartData[spot.x.toInt()].date;
                      final dayStr = AppStrings.dayNamesShort[date.weekday - 1];
                      final monthStr = AppStrings.monthNamesShort[date.month - 1];
                      final dateStr = "$dayStr, ${date.day.toString().padLeft(2, '0')} $monthStr ${date.year}";

                      return LineTooltipItem(
                        "${spot.y.toStringAsFixed(1)} kg\n",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        children: [
                          TextSpan(
                            text: dateStr,
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.normal, fontSize: 10),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
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
    if (_weightData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text("Belum ada riwayat berat badan"),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _weightData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _weightData[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatFluidDate(item.date),
                style: GoogleFonts.inter(
                  color: AppColors.navy.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${item.weight.toStringAsFixed(1)} kg",
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

  FlTitlesData _buildTitlesData(List<DateTime> dates) {
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
                  style: GoogleFonts.notoSansMono(fontSize: 12, color: AppColors.navy.withOpacity(0.8)),
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
          reservedSize: 40,
          interval: 2,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                value.toInt().toString(),
                style: GoogleFonts.notoSansMono(fontSize: 12, color: AppColors.navy.withOpacity(0.8)),
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
