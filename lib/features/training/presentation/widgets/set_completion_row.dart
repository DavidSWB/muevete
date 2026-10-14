import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// A single locally tracked set in an exercise prescription.
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
    final textTheme = Theme.of(context).textTheme;
    final valueColor = isCompleted ? AppColors.textMuted : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHold ? 'Duration' : 'Reps',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      color: valueColor,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (isHold)
              IconButton(
                onPressed: isCompleted ? null : onToggleTimer,
                tooltip: isRunning ? 'Pause timer' : 'Start timer',
                icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            Semantics(
              button: true,
              checked: isCompleted,
              label: 'Set $setNumber completed',
              child: IconButton(
                onPressed: onToggleCompleted,
                tooltip: isCompleted ? 'Mark set incomplete' : 'Mark set complete',
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? AppColors.primaryDark : AppColors.textMuted,
                ),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
