import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/training/domain/entities/exercise_sequence.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/screens/exercise_detail_screen.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/exercise_thumbnail.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    super.key,
    required this.exercise,
    this.sequence,
  });

  final WorkoutExercise exercise;
  final ExerciseSequence? sequence;

  void _openExerciseDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    final sequence = this.sequence;
    Navigator.of(context).push(
      sequence != null
          ? ExerciseDetailScreen.route(sequence)
          : MaterialPageRoute<void>(
              settings:
                  const RouteSettings(name: ExerciseDetailScreen.routeName),
              builder: (_) => ExerciseDetailScreen(exercise: exercise),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: () => _openExerciseDetail(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ExerciseThumbnail(visualPath: exercise.exercise.visualPath),
                const SizedBox(width: 16),
                Expanded(
                  child: _ExerciseInfo(exercise: exercise),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.cardBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseInfo extends StatelessWidget {
  const _ExerciseInfo({
    required this.exercise,
  });

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          exercise.exercise.name.localized(context, fallback: 'Exercise name'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.softGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _volumeLabel(l10n, exercise),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ),
      ],
    );
  }

  String _volumeLabel(AppLocalizations l10n, WorkoutExercise e) {
    final setLabel = l10n.exerciseSetCount(e.sets);
    final reps = e.reps;
    final duration = e.duration;

    if (reps != null) {
      return l10n.exerciseVolumeReps(setLabel, reps);
    } else if (duration != null) {
      return l10n.exerciseVolumeDuration(setLabel, duration);
    }
    return setLabel;
  }
}
