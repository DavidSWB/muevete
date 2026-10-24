import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/screens/exercise_detail_screen.dart';
import 'package:muevete/features/training/presentation/widgets/panel/exercise_tile.dart';
import 'package:muevete/features/training/presentation/widgets/panel/workout_sliding_panel.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';import 'package:muevete/l10n/app_localizations.dart';

Map<String, dynamic> _readArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  group('ARB files', () {
    final es = _readArb('lib/l10n/app_es.arb');
    final en = _readArb('lib/l10n/app_en.arb');

    test('Spanish and English define the same message keys', () {
      expect(_messageKeys(es).difference(_messageKeys(en)), isEmpty);
      expect(_messageKeys(en).difference(_messageKeys(es)), isEmpty);
    });

    test('no message value is empty', () {
      for (final arb in [es, en]) {
        for (final key in _messageKeys(arb)) {
          final value = arb[key];
          if (value is String) {
            expect(value.trim(), isNotEmpty, reason: key);
          }
        }
      }
    });
  });

  group('required labels', () {
    test('Spanish', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      expect(l10n.exerciseDone, '¡Hecho!');
      expect(l10n.workoutFinish, 'Finalizar entrenamiento');
      expect(l10n.exerciseNext, 'Siguiente');
      expect(l10n.progressMobilityStats, 'Estadísticas por articulación');
      expect(l10n.tourPrevious, 'Anterior');
      expect(l10n.tourNext, 'Siguiente');
    });

    test('English', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.exerciseDone, 'Done!');
      expect(l10n.workoutFinish, 'Finish Workout');
      expect(l10n.exerciseNext, 'Next');
      expect(l10n.progressMobilityStats, 'Joint stats');
      expect(l10n.tourPrevious, 'Previous');
      expect(l10n.tourNext, 'Next');
    });

    test('set count pluralizes in both languages', () async {
      final es = await AppLocalizations.delegate.load(const Locale('es'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(es.exerciseSetCount(1), '1 serie');
      expect(es.exerciseSetCount(3), '3 series');
      expect(en.exerciseSetCount(1), '1 set');
      expect(en.exerciseSetCount(3), '3 sets');
    });
  });

  group('screens use the localized labels', () {
    testWidgets('exercise details in Spanish', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app('es', ExerciseDetailScreen(exercise: _exercise(reps: 8, sets: 2))),
      );

      expect(find.text('¡Hecho!'), findsOneWidget);
      expect(find.text('Series'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(find.text('Descanso'), findsOneWidget);
      expect(find.text('Done!'), findsNothing);
    });

    testWidgets('exercise tile summary in Spanish', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app('es', Scaffold(body: ExerciseTile(exercise: _exercise(reps: 8, sets: 3)))),
      );
      expect(find.text('3 series × 8 reps'), findsOneWidget);
    });

    testWidgets('finish button defaults to the localized label',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final entry in {'es': 'Finalizar entrenamiento', 'en': 'Finish Workout'}.entries) {
        await tester.pumpWidget(
          _app(
            entry.key,
            Scaffold(
              body: WorkoutSlidingPanel(
                workout: Workout(
                  exercises: [_exercise(reps: 8, sets: 1)],
                  day: 1,
                  name: const {'en': 'Workout', 'es': 'Entrenamiento'},
                ),
                onWorkoutFinished: () async {},
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text(entry.value), findsOneWidget, reason: entry.key);
      }
    });

    testWidgets('an explicit finish label still wins', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(
          'en',
          Scaffold(
            body: WorkoutSlidingPanel(
              workout: Workout(
                exercises: [_exercise(reps: 8, sets: 1)],
                day: 1,
                name: const {'en': 'Workout'},
              ),
              finishButtonLabel: 'Custom label',
              onWorkoutFinished: () async {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Custom label'), findsOneWidget);
      expect(find.text('Finish Workout'), findsNothing);
    });
  });
}

Widget _app(String languageCode, Widget home) {
  return ProviderScope(
    overrides: [walkthroughUserIdProvider.overrideWithValue(null)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(languageCode),
      home: home,
    ),
  );
}

WorkoutExercise _exercise({int? reps, int? duration, required int sets}) {
  return WorkoutExercise(
    exercise: const ExerciseVariant(
      variantId: 'test',
      name: {'en': 'Test exercise', 'es': 'Ejercicio de prueba'},
      description: {'en': 'Description', 'es': 'Descripción'},
      visualPath: 'assets/images/workoutPicture.jpg',
      requiredLevel: ExerciseLevel.beginner,
    ),
    sets: sets,
    reps: reps,
    rest: 30,
    duration: duration,
  );
}
