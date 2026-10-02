import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/domain/services/active_break_builder.dart';
import 'package:muevete/features/training/domain/entities/exercise.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_type.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';

void main() {
  test('rejects an unknown exercise type with context', () {
    expect(
      () => Exercise.fromJson(_exerciseJson(type: 'mobilityy')),
      throwsA(isA<FormatException>().having(
        (error) => error.toString(),
        'message',
        contains('mobilityy'),
      )),
    );
  });

  test('rejects an unknown variant level with context', () {
    final json = _exerciseJson();
    (json['variants'] as List).first['requiredLevel'] = 'basic';

    expect(
      () => Exercise.fromJson(json),
      throwsA(isA<FormatException>().having(
        (error) => error.toString(),
        'message',
        contains('basic'),
      )),
    );
  });

  test('reports an Active Break variant reference mismatch', () async {
    final activeBreak = ActiveBreak(
      activeBreakId: 'break-1',
      name: const {'en': 'Break', 'es': 'Pausa'},
      durationMinutes: 1,
      description: const {'en': 'Description', 'es': 'Descripción'},
      templates: const [
        ActiveBreakTemplate(
          session: 1,
          name: {'en': 'Session', 'es': 'Sesión'},
          exercises: [
            ActiveBreakExerciseReference(
              exerciseId: 'exercise-1',
              variantId: 'missing-variant',
              type: 'mobility',
              durationSeconds: 30,
            ),
          ],
        ),
      ],
    );

    final builder = ActiveBreakBuilder(
      exerciseRepository: _FakeExerciseRepository(),
    );

    await expectLater(
      builder.buildWorkout(activeBreak),
      throwsA(isA<FormatException>().having(
        (error) => error.toString(),
        'message',
        allOf(contains('break-1'), contains('missing-variant')),
      )),
    );
  });
}

Map<String, dynamic> _exerciseJson({String type = 'mobility'}) {
  return {
    'exerciseId': 'exercise-1',
    'name': {'en': 'Exercise', 'es': 'Ejercicio'},
    'type': type,
    'targets': ['hip'],
    'variants': [
      {
        'variantId': 'variant-1',
        'name': {'en': 'Variant', 'es': 'Variante'},
        'description': {'en': 'Description', 'es': 'Descripción'},
        'visualPath': 'url',
        'requiredLevel': 'beginner',
      },
    ],
  };
}

class _FakeExerciseRepository implements ExerciseRepository {
  @override
  Future<Exercise> getExercise(String id) async {
    return Exercise(
      exerciseId: id,
      name: const {'en': 'Exercise', 'es': 'Ejercicio'},
      type: ExerciseType.mobility,
      targets: const ['hip'],
      variants: const [
        ExerciseVariant(
          variantId: 'variant-1',
          name: {'en': 'Variant', 'es': 'Variante'},
          description: {'en': 'Description', 'es': 'Descripción'},
          visualPath: 'url',
          requiredLevel: ExerciseLevel.beginner,
        ),
      ],
    );
  }
}
