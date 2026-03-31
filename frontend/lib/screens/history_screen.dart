// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../services/food_log_api_service.dart';
import '../services/profile_api_service.dart';
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

  void _showCalendarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _CalendarPickerModal(
          initialDate: _selectedDate,
          onDateSelected: _onDateChanged,
        );
      },
    );
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
                              color: Color(0xFFFFDDBE),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'History Nutrisi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Color(0xFFFFCC80)),
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
                      color: NutrifyTheme.accentOrange,
                      backgroundColor: NutrifyTheme.darkCard,
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
        color: NutrifyTheme.darkCard,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: NutrifyTheme.accentOrange),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$totalKcal kcal',
                style: const TextStyle(
                  color: NutrifyTheme.accentOrange,
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
                style: TextStyle(color: Colors.white30, fontSize: 13),
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
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.foodName,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${entry.calories.round()} kcal',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
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
        color: NutrifyTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Calendar Picker (kept from original, no changes needed) ──────────────

class _CalendarPickerModal extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const _CalendarPickerModal({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_CalendarPickerModal> createState() => _CalendarPickerModalState();
}

class _CalendarPickerModalState extends State<_CalendarPickerModal> {
  late DateTime _tempSelectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _tempSelectedDate = widget.initialDate;
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF38345F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month - 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildWeekdayHeader(),
          Expanded(child: _buildDateGrid()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays
            .map((day) => Text(
                  day,
                  style: const TextStyle(
                      color: Colors.white54, fontWeight: FontWeight.bold),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDateGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: daysInMonth + firstWeekday,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox.shrink();
        }
        final day = index - firstWeekday + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isSelected = date.year == _tempSelectedDate.year &&
            date.month == _tempSelectedDate.month &&
            date.day == _tempSelectedDate.day;
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _tempSelectedDate = date;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isSelected ? NutrifyTheme.accentOrange : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: NutrifyTheme.accentOrange, width: 1)
                  : null,
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2B52),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELECTED DAY',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy').format(_tempSelectedDate),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDateSelected(_tempSelectedDate);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38345F),
              side: const BorderSide(color: NutrifyTheme.accentOrange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text('Select Date',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
