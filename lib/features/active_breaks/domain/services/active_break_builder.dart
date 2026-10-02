import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';

class ActiveBreakBuilder {
  const ActiveBreakBuilder({required this.exerciseRepository});

  final ExerciseRepository exerciseRepository;

  Future<Workout> buildWorkout(ActiveBreak activeBreak) async {
    final template = activeBreak.firstTemplate;
    final exercises = <WorkoutExercise>[];

    for (final reference in template.exercises) {
      try {
        final exercise = await exerciseRepository.getExercise(reference.exerciseId);
        final variant = exercise.variants.firstWhere(
          (candidate) => candidate.variantId == reference.variantId,
          orElse: () => throw FormatException(
            'Variant "${reference.variantId}" not found in exercise '
            '"${reference.exerciseId}" for Active Break '
            '"${activeBreak.activeBreakId}".',
          ),
        );

        if (exercise.type.name != reference.type) {
          throw FormatException(
            'Exercise "${reference.exerciseId}" has type '
            '"${exercise.type.name}", but Active Break '
            '"${activeBreak.activeBreakId}" references "${reference.type}".',
          );
        }

        exercises.add(WorkoutExercise(
          exercise: variant,
          sets: 1,
          reps: null,
          rest: 0,
          duration: reference.durationSeconds,
        ));
      } catch (error, stackTrace) {
        Error.throwWithStackTrace(
          FormatException(
            'Could not build Active Break "${activeBreak.activeBreakId}" '
            'using exercise "${reference.exerciseId}" and variant '
            '"${reference.variantId}": $error',
          ),
          stackTrace,
        );
      }
    }

    return Workout(
      exercises: exercises,
      day: template.session,
      name: activeBreak.name,
    );
  }
}
