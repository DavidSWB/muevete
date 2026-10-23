import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// A single locally tracked set in an exercise prescription.
/// Applies `/fitness-ui` Glanceability (tabular figures), 60fps transitions,
/// and 48x48px Thumb Zone targets.
class ExerciseSetRow extends StatelessWidget {
  const ExerciseSetRow({
    super.key,
    required this.setNumber,
    required this.isHold,
    required this.isCompleted,
    required this.isRunning,
    required this.value,
    this.onToggleCompleted,
    this.onToggleTimer,
  });

  final int setNumber;
  final bool isHold;
  final bool isCompleted;
  final bool isRunning;
  final String value;
  final VoidCallback? onToggleCompleted;
  final VoidCallback? onToggleTimer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isRunning
        ? AppColors.cardBlue
        : isCompleted
            ? AppColors.successSoft.withValues(alpha: 0.5)
            : AppColors.surface;

    final borderColor = isRunning
        ? AppColors.primaryDark
        : isCompleted
            ? AppColors.success.withValues(alpha: 0.45)
            : AppColors.border;

    final badgeColor = isCompleted
        ? AppColors.success
        : isRunning
            ? AppColors.primaryDark
            : AppColors.softGrey;

    final badgeTextColor =
        (isCompleted || isRunning) ? Colors.white : AppColors.textMuted;

    final valueColor = isCompleted
        ? AppColors.textMuted
        : isRunning
            ? AppColors.primaryDark
            : AppColors.textPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isRunning ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$setNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: badgeTextColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHold ? l10n.exerciseDuration : l10n.exerciseReps,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          if (isHold)
            IconButton(
              onPressed: isCompleted ? null : onToggleTimer,
              tooltip: isRunning
                  ? l10n.exercisePauseTimer
                  : l10n.exerciseStartTimer,
              icon: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isCompleted
                    ? AppColors.textDisabled
                    : AppColors.primaryDark,
              ),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          Semantics(
            button: true,
            checked: isCompleted,
            label: l10n.exerciseSetCompleted(setNumber),
            child: IconButton(
              onPressed: onToggleCompleted,
              tooltip: isCompleted
                  ? l10n.exerciseMarkSetIncomplete
                  : l10n.exerciseMarkSetComplete,
              icon: Icon(
                isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: isCompleted ? AppColors.success : AppColors.textMuted,
                size: 26,
              ),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ],
      ),
    );
  }
}
