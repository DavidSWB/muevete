import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';
import 'package:muevete/features/training/domain/repositories/progression_repository.dart';
import 'package:muevete/features/training/domain/services/variantSelector.dart';

class WorkoutBuilder {
  final ExerciseRepository exerciseRepository;
  final ProgressionRepository progressionRepository;
  final Variantselector variantSelector;

  const WorkoutBuilder({
    required this.exerciseRepository,
    required this.progressionRepository,
    required this.variantSelector,
  });

  Future<Workout> buildWorkout({
    required TrainingPlan plan,
    required int day,
    required int week,
    required UserStats stats,
  }) async {
    try{

    final planDay = plan.template.firstWhere(
      (e) => e.day == day,
    );

    final exercises = <WorkoutExercise>[];

    for (final reference in planDay.exercises) {

      final exercise =
          await exerciseRepository.getExercise(
        reference.exerciseId,
      );

      final lowestStat =
          variantSelector.getLowestTargetStat(
        exercise,
        stats,
      );

      final level =
          variantSelector.calculateLevel(
        lowestStat,
      );

      final variant =
          variantSelector.findVariant(
        exercise,
        level,
      );

      final progression =
          await progressionRepository.getRules(
        exercise.type,
        level,
      );

      final cycle = progression.cycle.firstWhere(
        (c) => c.week == week,
        orElse: () => progression.cycle.last,
      );

      exercises.add(
        WorkoutExercise(
          exercise: variant,
          sets: cycle.sets,
          reps: cycle.reps,
          rest: cycle.rest ?? 90,
        ),
      );
    }

    return Workout(
      name: plan.name,
      day: day,
      exercises: exercises,
    );
    }catch (e, s) {
    print("WorkoutBuilder ERROR sadasfasfasdfasdsadasfasdfsafas");
    print(e);
    print(s);
    rethrow;
  }

  }
}