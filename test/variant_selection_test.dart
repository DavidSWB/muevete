import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/training/domain/entities/exercise.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_reference.dart';
import 'package:muevete/features/training/domain/entities/exercise_type.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/entities/progessionrules.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';
import 'package:muevete/features/training/domain/repositories/progression_repository.dart';
import 'package:muevete/features/training/domain/services/variantSelector.dart';
import 'package:muevete/features/training/domain/services/workout_builder.dart';

/// Variant selection against the `exercises` collection: each exercise offers
/// a beginner variant and either an intermediate or an advanced one.
void main() {
  final selector = Variantselector();

  UserStats all(double value) =>
      UserStats(knee: value, hip: value, ankle: value, shoulder: value);

  ExerciseVariant pick(String exerciseId, UserStats stats) {
    final exercise = _exercises[exerciseId]!;
    final level = selector.calculateLevel(
      selector.getLowestTargetStat(exercise, stats),
    );
    return selector.findVariant(exercise, level);
  }

  group('level thresholds stay as they were', () {
    test('above 4 is advanced, above 2 intermediate, else beginner', () {
      expect(selector.calculateLevel(5), ExerciseLevel.advanced);
      expect(selector.calculateLevel(4.01), ExerciseLevel.advanced);
      expect(selector.calculateLevel(4), ExerciseLevel.intermediate);
      expect(selector.calculateLevel(2.01), ExerciseLevel.intermediate);
      expect(selector.calculateLevel(2), ExerciseLevel.beginner);
      expect(selector.calculateLevel(1), ExerciseLevel.beginner);
    });
  });

  group('maximum stats', () {
    test('get the hardest variant each exercise offers', () {
      for (final exercise in _exercises.values) {
        final hardest = exercise.variants
            .map((v) => v.requiredLevel.index)
            .reduce((a, b) => a > b ? a : b);
        expect(
          pick(exercise.exerciseId, all(5)).requiredLevel.index,
          hardest,
          reason: exercise.exerciseId,
        );
      }
    });

    test('never fall back to a beginner variant', () {
      for (final id in _exercises.keys) {
        expect(
          pick(id, all(5)).requiredLevel,
          isNot(ExerciseLevel.beginner),
          reason: id,
        );
      }
    });

    test('shoulder exercises: push-ups intermediate, rows advanced', () {
      expect(pick('deep-push-ups', all(5)).variantId, 'push-reg-1');
      expect(pick('bw-rows', all(5)).variantId, 'row-prog');
    });
  });

  test('minimum stats get the beginner variant everywhere', () {
    for (final id in _exercises.keys) {
      expect(pick(id, all(1)).requiredLevel, ExerciseLevel.beginner, reason: id);
    }
  });

  group('intermediate stats', () {
    test('get the intermediate variant where it exists', () {
      expect(pick('deep-push-ups', all(3)).variantId, 'push-reg-1');
      expect(pick('ankle-rocks', all(3)).variantId, 'ankle-rocks-prog');
    });

    test('keep beginner where the only harder variant is advanced', () {
      expect(pick('bw-rows', all(3)).variantId, 'row-reg');
      expect(pick('single-leg-calf-raise', all(3)).variantId, 'calf-reg');
    });
  });

  test('exercises on the same joint are given the same level', () {
    final stats = UserStats(knee: 1, hip: 1, ankle: 1, shoulder: 5);
    final shoulderOnly = _exercises.values.where(
      (e) => e.targets.length == 1 && e.targets.single == 'shoulder',
    );
    expect(shoulderOnly.map((e) => e.exerciseId),
        containsAll(['bw-rows', 'deep-push-ups', 'dead-hang']));
    for (final exercise in shoulderOnly) {
      expect(
        selector.calculateLevel(selector.getLowestTargetStat(exercise, stats)),
        ExerciseLevel.advanced,
        reason: exercise.exerciseId,
      );
    }
  });

  test('multi-joint exercises follow their weakest joint', () {
    final weakAnkle = UserStats(knee: 5, hip: 5, ankle: 1, shoulder: 5);
    expect(pick('atg-split-squat', weakAnkle).variantId, 'atg-split-squat-reg');
    expect(pick('deep-squat', weakAnkle).variantId, 'deep-squat-reg');
    // Shoulder and hip only, so the weak ankle does not count.
    expect(pick('reverse-plank', weakAnkle).variantId, 'reverse-plank-prog');
  });

  group('invalid metadata', () {
    test('an exercise with no targets fails instead of picking advanced', () {
      final noTargets = _ex('no-targets', [], [
        ('a', ExerciseLevel.beginner),
        ('b', ExerciseLevel.advanced),
      ]);
      expect(
        () => selector.getLowestTargetStat(noTargets, all(1)),
        throwsStateError,
      );
    });

    test('an exercise with no variants fails', () {
      expect(
        () => selector.findVariant(
          _ex('none', ['hip'], []),
          ExerciseLevel.beginner,
        ),
        throwsStateError,
      );
    });

    test('with nothing at or below the level, the easiest variant is used', () {
      final noBeginner = _ex('x', ['hip'], [
        ('adv', ExerciseLevel.advanced),
        ('int', ExerciseLevel.intermediate),
      ]);
      expect(
        selector.findVariant(noBeginner, ExerciseLevel.beginner).variantId,
        'int',
      );
    });

    test('an unknown target still fails', () {
      expect(
        () => selector.getLowestTargetStat(
          _ex('bad', ['elbow'], [('a', ExerciseLevel.beginner)]),
          all(3),
        ),
        throwsException,
      );
    });
  });

  group('WorkoutBuilder', () {
    test('sets and reps keep following the user\'s level', () async {
      final progression = _RecordingProgression();
      final builder = WorkoutBuilder(
        exerciseRepository: _MapExercises(),
        progressionRepository: progression,
        variantSelector: selector,
      );
      const plan = TrainingPlan(
        planId: 'p',
        name: {'en': 'P'},
        description: {'en': 'P'},
        daysPerWeek: 1,
        template: [
          PlanDay(day: 1, name: {'en': 'Upper'}, exercises: [
            ExerciseReference(exerciseId: 'deep-push-ups'),
            ExerciseReference(exerciseId: 'bw-rows'),
          ]),
        ],
      );

      final workout = await builder.buildWorkout(
        plan: plan,
        day: 1,
        week: 1,
        stats: all(5),
      );

      expect(
        workout.exercises.map((e) => e.exercise.variantId),
        ['push-reg-1', 'row-prog'],
      );
      expect(progression.levels,
          [ExerciseLevel.advanced, ExerciseLevel.advanced]);
    });
  });
}

Exercise _ex(
  String id,
  List<String> targets,
  List<(String, ExerciseLevel)> variants,
) => Exercise(
  exerciseId: id,
  name: {'en': id},
  type: ExerciseType.compound,
  hold: false,
  targets: targets,
  variants: [
    for (final (variantId, level) in variants)
      ExerciseVariant(
        variantId: variantId,
        name: {'en': variantId},
        description: const {'en': ''},
        visualPath: '',
        requiredLevel: level,
      ),
  ],
);

/// Targets and variant levels of the `exercises` collection, in its order.
final Map<String, Exercise> _exercises = {
  for (final e in [
    _ex('ankle-rocks', ['ankle'], [('ankle-rocks-reg', ExerciseLevel.beginner), ('ankle-rocks-prog', ExerciseLevel.intermediate)]),
    _ex('atg-split-squat', ['knee', 'hip', 'ankle'], [('atg-split-squat-reg', ExerciseLevel.beginner), ('atg-split-squat-std', ExerciseLevel.intermediate)]),
    _ex('butcher-blocks', ['shoulder', 'hip'], [('butcher-blocks-reg', ExerciseLevel.beginner), ('butcher-blocks-prog', ExerciseLevel.advanced)]),
    _ex('bw-rows', ['shoulder'], [('row-reg', ExerciseLevel.beginner), ('row-prog', ExerciseLevel.advanced)]),
    _ex('dead-hang', ['shoulder'], [('dead-hang-reg', ExerciseLevel.beginner), ('dead-hang-prog', ExerciseLevel.intermediate)]),
    _ex('deep-push-ups', ['shoulder'], [('push-reg-2', ExerciseLevel.beginner), ('push-reg-1', ExerciseLevel.intermediate)]),
    _ex('deep-squat', ['hip', 'knee', 'ankle'], [('deep-squat-reg', ExerciseLevel.beginner), ('deep-squat-prog', ExerciseLevel.advanced)]),
    _ex('deep-squat-hold', ['hip', 'knee', 'ankle'], [('deep-squat-hold-reg', ExerciseLevel.beginner), ('deep-squat-hold-prog', ExerciseLevel.intermediate)]),
    _ex('elephant-walk', ['hip'], [('elephant-walk-reg', ExerciseLevel.beginner), ('elephant-walk-prog', ExerciseLevel.intermediate)]),
    _ex('frog-stretch', ['hip'], [('frog-stretch-reg', ExerciseLevel.beginner), ('frog-stretch-prog', ExerciseLevel.intermediate)]),
    _ex('jefferson-curl', ['hip'], [('jeff-reg-2', ExerciseLevel.beginner), ('jeff-reg-1', ExerciseLevel.intermediate)]),
    _ex('pigeon-push-up', ['shoulder', 'hip'], [('pigeon-push-up-reg', ExerciseLevel.beginner), ('pigeon-push-up-prog', ExerciseLevel.intermediate)]),
    _ex('reverse-plank', ['shoulder', 'hip'], [('reverse-plank-reg', ExerciseLevel.beginner), ('reverse-plank-prog', ExerciseLevel.advanced)]),
    _ex('single-leg-calf-raise', ['ankle'], [('calf-reg', ExerciseLevel.beginner), ('calf-prog', ExerciseLevel.advanced)]),
    _ex('squat-twist-stretch', ['hip', 'ankle', 'shoulder'], [('squat-twist-stretch-reg', ExerciseLevel.beginner), ('squat-twist-stretch-prog', ExerciseLevel.intermediate)]),
    _ex('standing-good-morning', ['hip'], [('standing-good-morning-reg', ExerciseLevel.beginner), ('standing-good-morning-prog', ExerciseLevel.intermediate)]),
    _ex('tib-raise', ['ankle'], [('tib-reg', ExerciseLevel.beginner), ('tib-prog', ExerciseLevel.intermediate)]),
    _ex('worlds-greatest-stretch', ['hip', 'ankle', 'shoulder'], [('worlds-greatest-stretch-reg', ExerciseLevel.beginner), ('worlds-greatest-stretch-prog', ExerciseLevel.intermediate)]),
  ])
    e.exerciseId: e,
};

class _MapExercises implements ExerciseRepository {
  @override
  Future<Exercise> getExercise(String id) async => _exercises[id]!;
}

class _RecordingProgression implements ProgressionRepository {
  final List<ExerciseLevel> levels = [];

  @override
  Future<ProgessionRules> getRules(
    ExerciseType type,
    ExerciseLevel level,
    bool hold,
  ) async {
    levels.add(level);
    return ProgessionRules(
      id: '${type.name}_${level.name}',
      cycle: const [ProgressionStep(week: 1, sets: 3, reps: 8)],
      level: level.name,
      reset: true,
      type: type.name,
    );
  }
}
