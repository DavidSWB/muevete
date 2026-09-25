import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.month,
    required this.completedWorkouts,
  });

  final DateTime month;
  final List<DateTime> completedWorkouts;

  final List<String> weekDays = const [
    'Mon', 'Tue', 'Wed',
    'Thu','Fri', 'Sat', 'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;

    final leadingDays = firstDay.weekday - 1;
    final totalCells = leadingDays + daysInMonth;

    return Column(
      children: [
        Row(
          children: weekDays.map((wD) {
            return Expanded(
              child: Center(
                child: Text(
                  wD,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < leadingDays) {
              return const SizedBox();
            }
        
            final day = index - leadingDays + 1;
            final date = DateTime(month.year, month.month, day);
        
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
        
            final isCompleted = completedWorkouts.any(
              (workoutDate) =>
                  workoutDate.year == date.year &&
                  workoutDate.month == date.month &&
                  workoutDate.day == date.day,
            );
        
            final highlightColor = isToday
                ? AppColors.primary
                : isCompleted
                    ? AppColors.success
                    : null;
        
            return Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: highlightColor == null
                        ? AppColors.textMuted
                        : AppColors.surface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}