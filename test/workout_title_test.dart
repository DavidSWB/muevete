import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';
import 'package:muevete/features/training/domain/repositories/progression_repository.dart';
import 'package:muevete/features/training/domain/services/variantSelector.dart';
import 'package:muevete/features/training/domain/services/workout_builder.dart';

void main() {
  test('a built workout is named after its session, not the plan', () async {
    final builder = WorkoutBuilder(
      exerciseRepository: _NoExercises(),
      progressionRepository: _NoProgression(),
      variantSelector: _NoVariants(),
    );

    const plan = TrainingPlan(
      planId: 'plan_2d_fullbody',
      name: {'es': 'Full Body 2 días', 'en': '2-Day Full Body'},
      description: {'es': '', 'en': ''},
      daysPerWeek: 2,
      template: [
        PlanDay(
          day: 1,
          name: {'es': 'Full Body A', 'en': 'Full Body A'},
          exercises: [],
        ),
        PlanDay(
          day: 2,
          name: {'es': 'Full Body B', 'en': 'Full Body B'},
          exercises: [],
        ),
      ],
    );

    final workout = await builder.buildWorkout(
      plan: plan,
      day: 2,
      week: 1,
      stats: const UserStats(knee: 2, hip: 2, ankle: 2, shoulder: 2),
    );

    expect(workout.name, {'es': 'Full Body B', 'en': 'Full Body B'});
    expect(workout.day, 2);
  });
}

class _NoExercises extends Fake implements ExerciseRepository {}

class _NoProgression extends Fake implements ProgressionRepository {}

class _NoVariants extends Fake implements Variantselector {}
