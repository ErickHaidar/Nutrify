import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';

enum _SelectionMode { day, month, year }

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
  _SelectionMode _mode = _SelectionMode.year; // Always start from Year
  late int _startYear;

  static const _monthNames = [
    'Januari', 'Februari', 'Maret', 'April',
    'Mei', 'Juni', 'Juli', 'Agustus',
    'September', 'Oktober', 'November', 'Desember'
  ];

  static const _dayLabels = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
    _startYear = (_displayedMonth.year ~/ 12) * 12;
  }

  void _previous() {
    setState(() {
      if (_mode == _SelectionMode.day) {
        _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
      } else if (_mode == _SelectionMode.year) {
        _startYear -= 12;
      }
    });
  }

  void _next() {
    setState(() {
      if (_mode == _SelectionMode.day) {
        _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
      } else if (_mode == _SelectionMode.year) {
        _startYear += 12;
      }
    });
  }

  String get _headerLabel {
    if (_mode == _SelectionMode.day) {
      return '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';
    } else if (_mode == _SelectionMode.month) {
      return '${_displayedMonth.year}';
    } else {
      return '$_startYear \u2013 ${_startYear + 11}';
    }
  }

  String get _modeLabel {
    switch (_mode) {
      case _SelectionMode.year:
        return 'PILIH TAHUN';
      case _SelectionMode.month:
        return 'PILIH BULAN';
      case _SelectionMode.day:
        return 'PILIH HARI';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF1E8),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _modeLabel,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Header: label + nav arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_mode == _SelectionMode.day) {
                        _mode = _SelectionMode.month;
                      } else if (_mode == _SelectionMode.month) {
                        _mode = _SelectionMode.year;
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _headerLabel,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_mode != _SelectionMode.year) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.navy.withOpacity(0.6),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    _NavButton(
                      onTap: _mode == _SelectionMode.month ? null : _previous,
                      icon: Icons.chevron_left,
                    ),
                    const SizedBox(width: 4),
                    _NavButton(
                      onTap: _mode == _SelectionMode.month ? null : _next,
                      icon: Icons.chevron_right,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content grid
            if (_mode == _SelectionMode.day) ...[
              _buildWeekdayHeader(),
              const SizedBox(height: 4),
              _buildDateGrid(),
            ] else if (_mode == _SelectionMode.month) ...[
              _buildMonthGrid(),
            ] else ...[
              _buildYearGrid(),
            ],

            const SizedBox(height: 20),

            // Confirm button - only enabled when a date is selected in day mode
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedDate != null && _mode == _SelectionMode.day)
                    ? () => Navigator.pop(context, _selectedDate)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  disabledBackgroundColor: AppColors.navy.withOpacity(0.25),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  'Pilih',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _dayLabels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateGrid() {
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday=0
    final daysInMonth = lastDayOfMonth.day;

    final List<DateTime?> calendarDays = [];
    for (int i = 0; i < startWeekday; i++) calendarDays.add(null);
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(_displayedMonth.year, _displayedMonth.month, i));
    }
    while (calendarDays.length % 7 != 0) calendarDays.add(null);

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: calendarDays.map((date) {
        if (date == null) return const SizedBox.shrink();

        final isSelected = _selectedDate != null &&
            date.year == _selectedDate!.year &&
            date.month == _selectedDate!.month &&
            date.day == _selectedDate!.day;

        final isOutOfRange = date.isBefore(widget.firstDate) ||
            date.isAfter(widget.lastDate);

        return GestureDetector(
          onTap: isOutOfRange
              ? null
              : () => setState(() => _selectedDate = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF1C28E)
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF1C28E).withOpacity(0.5),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isOutOfRange
                      ? AppColors.navy.withOpacity(0.2)
                      : AppColors.navy,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(12, (index) {
        final isSelected = _displayedMonth.month == index + 1;
        return GestureDetector(
          onTap: () => setState(() {
            _displayedMonth = DateTime(_displayedMonth.year, index + 1);
            _mode = _SelectionMode.day;
          }),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF1C28E)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _monthNames[index],
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildYearGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(12, (index) {
        final year = _startYear + index;
        final isSelected = _displayedMonth.year == year;
        final isOutOfRange = year < widget.firstDate.year ||
            year > widget.lastDate.year;

        return GestureDetector(
          onTap: isOutOfRange
              ? null
              : () => setState(() {
                    _displayedMonth = DateTime(year, _displayedMonth.month);
                    _mode = _SelectionMode.month;
                  }),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF1C28E)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$year',
                style: TextStyle(
                  color: isOutOfRange
                      ? AppColors.navy.withOpacity(0.2)
                      : AppColors.navy,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Small navigation button ───────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const _NavButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.navy.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? AppColors.navy.withOpacity(0.2)
              : AppColors.navy,
          size: 22,
        ),
      ),
    );
  }
}

// ─── Helper function ───────────────────────────────────────────────────────────

/// Shows the Nutrify date picker as a centered Dialog.
/// Flow: Year → Month → Day
Future<DateTime?> showNutrifyDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) => NutrifyCalendarPicker(
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      onDateSelected: (date) {},
    ),
  );
}
