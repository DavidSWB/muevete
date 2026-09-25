import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/features/progress/presentation/widgets/calendar_grid.dart';

class ProgressCalendar extends StatefulWidget {
  const ProgressCalendar({
    super.key,
    required this.completedWorkouts,
  });

  final List<DateTime> completedWorkouts;

  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  late DateTime displayedMonth;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    displayedMonth = DateTime(today.year, today.month);
  }

  String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left),
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 16),
            Text(
              '${getMonthName(displayedMonth.month)} ${displayedMonth.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right),
              color: AppColors.textMuted,
            ),
          ],
        ),
        CalendarGrid(
          month: displayedMonth,
          completedWorkouts: widget.completedWorkouts,
        ),
      ],
    );
  }
}