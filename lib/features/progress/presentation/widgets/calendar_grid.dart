import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.month,
    required this.completedWorkouts,
  });

  final DateTime month;
  final List<DateTime> completedWorkouts;

  /// Monday first, matching [DateTime.weekday] and the grid's columns.
  static List<String> _weekDays(AppLocalizations l10n) => [
    l10n.dayMonShort,
    l10n.dayTueShort,
    l10n.dayWedShort,
    l10n.dayThuShort,
    l10n.dayFriShort,
    l10n.daySatShort,
    l10n.daySunShort,
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final leadingDays = firstDay.weekday - 1;
    final totalCells = leadingDays + daysInMonth;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: _weekDays(AppLocalizations.of(context)!).map((dayLabel) {
              return Expanded(
                child: Center(
                  child: Text(
                    dayLabel,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
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
              return const SizedBox.shrink();
            }

            final day = index - leadingDays + 1;
            final date = DateTime(month.year, month.month, day);

            final isToday = _isSameDay(date, today);
            final isCompleted = completedWorkouts.any(
              (workoutDate) => _isSameDay(workoutDate, date),
            );

            final Color? highlightColor = isCompleted
                ? AppColors.success
                : isToday
                    ? AppColors.primaryDark
                    : null;

            return Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.circle,
                  border: isToday && isCompleted
                      ? Border.all(color: AppColors.primaryDark, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: highlightColor == null
                        ? AppColors.textPrimary
                        : AppColors.surface,
                    fontWeight: highlightColor == null
                        ? FontWeight.w600
                        : FontWeight.w800,
                    fontSize: 13,
                    fontFeatures: const [FontFeature.tabularFigures()],
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
