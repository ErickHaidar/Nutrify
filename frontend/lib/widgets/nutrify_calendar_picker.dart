import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';

class NutrifyCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const NutrifyCalendarPicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<NutrifyCalendarPicker> createState() => _NutrifyCalendarPickerState();
}

class _NutrifyCalendarPickerState extends State<NutrifyCalendarPicker> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;

  static const _monthNames = [
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
    'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  String get _monthYearLabel =>
      '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _displayedMonth,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      initialDatePickerMode: DatePickerMode.year,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.navy,
                              onPrimary: Colors.white,
                              surface: AppColors.cream,
                              onSurface: AppColors.navy,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _displayedMonth = DateTime(selectedDate.year, selectedDate.month, 1);
                        _selectedDate = selectedDate;
                      });
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'PILIH TAHUN & BULAN',
                            style: TextStyle(
                              color: AppColors.navy.withOpacity(0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: AppColors.navy.withOpacity(0.5), size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _monthYearLabel,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppColors.navy, size: 20),
                      onPressed: _previousMonth,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AppColors.navy, size: 20),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 2. Weekday Header Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB']
                    .map((label) => Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            // 3. Date Grid
            _buildDateGrid(),
            // 4. "Pilih" Button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDate != null
                      ? () => Navigator.pop(context, _selectedDate)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Pilih',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGrid() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    final daysInMonth = lastDayOfMonth.day;
    final List<DateTime?> calendarDays = [];

    // Pad start
    for (int i = 0; i < startWeekday; i++) {
      calendarDays.add(null);
    }

    // Fill days
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(_displayedMonth.year, _displayedMonth.month, i));
    }

    // Pad end to make it exactly 6 rows (42 cells)
    while (calendarDays.length < 42) {
      calendarDays.add(null);
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: calendarDays.map((date) {
        if (date == null) return const SizedBox.shrink();

        final isSelected = _selectedDate != null &&
            date.year == _selectedDate!.year &&
            date.month == _selectedDate!.month &&
            date.day == _selectedDate!.day;

        final now = DateTime.now();
        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        final isOutOfRange = date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

        return GestureDetector(
          onTap: isOutOfRange
              ? null
              : () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.amber : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isOutOfRange
                      ? AppColors.navy.withOpacity(0.25)
                      : AppColors.navy,
                  fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

Future<DateTime?> showNutrifyDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    builder: (context) => NutrifyCalendarPicker(
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      onDateSelected: (date) {
        // This is handled by Navigator.pop in the widget's button
      },
    ),
  );
}
