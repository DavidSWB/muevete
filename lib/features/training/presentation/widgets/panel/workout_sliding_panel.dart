import 'package:flutter/material.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/presentation/widgets/panel/exercise_list.dart';
import 'package:muevete/features/training/presentation/widgets/panel/workout_overview.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class WorkoutSlidingPanel extends StatelessWidget {
  const WorkoutSlidingPanel({
    super.key,
    required this.workout,
    required this.onWorkoutFinished,
    this.finishButtonLabel,
    this.panelAnchorId,
    this.firstExerciseAnchorId,
    this.finishAnchorId,
  });

  final Workout workout;
  final Future<void> Function() onWorkoutFinished;

  /// Overrides the default localized label (`workoutFinish`) when non-null.
  final String? finishButtonLabel;

  /// Walkthrough anchor ids for the panel, its first exercise and its finish
  /// button. Null on screens the tour does not point at.
  final String? panelAnchorId;
  final String? firstExerciseAnchorId;
  final String? finishAnchorId;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .64,
      minChildSize: .64,
      maxChildSize: .92,
      builder: (context, scrollController) {
        final panel = Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              const SliverToBoxAdapter(
                child: _DragHandle(),
              ),
              SliverToBoxAdapter(
                child: WorkoutOverview(
                  workout: workout,
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Divider(height: 1),
                ),
              ),
              ExerciseList(
                exercises: workout.exercises,
                firstAnchorId: firstExerciseAnchorId,
              ),
              SliverToBoxAdapter(
                child: _FinishWorkoutButton(
                  onWorkoutFinished: onWorkoutFinished,
                  label: finishButtonLabel,
                  anchorId: finishAnchorId,
                ),
              ),
            ],
          ),
        );
        final anchorId = panelAnchorId;
        return anchorId == null
            ? panel
            : WalkthroughAnchor(id: anchorId, child: panel);
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.textDisabled.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _FinishWorkoutButton extends StatefulWidget {
  const _FinishWorkoutButton({
    required this.onWorkoutFinished,
    this.label,
    this.anchorId,
  });

  final Future<void> Function() onWorkoutFinished;
  final String? label;

  /// Walkthrough anchor id for the button, if the tour points at it.
  final String? anchorId;

  @override
  State<_FinishWorkoutButton> createState() => _FinishWorkoutButtonState();
}

class _FinishWorkoutButtonState extends State<_FinishWorkoutButton> {
  bool _isSubmitting = false;

  Future<void> _handlePress() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onWorkoutFinished();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchorId = widget.anchorId;
    final button = SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _handlePress,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryDark,
                ),
              )
            : const Icon(Icons.check_circle_outline_rounded, size: 20),
        label: Text(
          widget.label ?? AppLocalizations.of(context)!.workoutFinish,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: anchorId == null
          ? button
          : WalkthroughAnchor(id: anchorId, child: button),
    );
  }
}
