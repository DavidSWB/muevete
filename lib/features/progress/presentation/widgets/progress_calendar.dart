import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muevete/features/progress/presentation/widgets/calendar_grid.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

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

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final materialL10n = MaterialLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.textPrimary,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              tooltip: materialL10n.previousMonthTooltip,
            ),
            // Long month names, longer still in Spanish, shrink instead of
            // pushing the arrows off a narrow screen.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  materialL10n.formatMonthYear(displayedMonth),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppColors.textPrimary,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              tooltip: materialL10n.nextMonthTooltip,
            ),
          ],
        ),
        const SizedBox(height: 8),
        CalendarGrid(
          month: displayedMonth,
          completedWorkouts: widget.completedWorkouts,
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CalendarLegendDot(
              color: AppColors.primaryDark,
              label: l10n.progressCalendarToday,
            ),
            const SizedBox(width: 20),
            _CalendarLegendDot(
              color: AppColors.success,
              label: l10n.progressCalendarCompleted,
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
