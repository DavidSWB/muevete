import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_sequence.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/screens/exercise_detail_screen.dart';
import 'package:muevete/features/training/presentation/widgets/panel/exercise_list.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';import 'package:muevete/l10n/app_localizations.dart';

const _nextKey = ValueKey('exercise-next-button');
const _doneKey = ValueKey('exercise-done-button');

void main() {
  group('ExerciseSequence', () {
    final exercises = [_exercise('A'), _exercise('B'), _exercise('C')];

    test('exposes the current exercise and whether another follows', () {
      final first = ExerciseSequence(exercises, 0);
      expect(first.current, same(exercises[0]));
      expect(first.hasNext, isTrue);

      final last = ExerciseSequence(exercises, 2);
      expect(last.current, same(exercises[2]));
      expect(last.hasNext, isFalse);
    });

    test('next() moves one position forward', () {
      final second = ExerciseSequence(exercises, 0).next();
      expect(second.index, 1);
      expect(second.current, same(exercises[1]));
    });

    test('next() on the last exercise throws', () {
      expect(() => ExerciseSequence(exercises, 2).next(), throwsStateError);
    });

    test('a single-exercise workout has no next', () {
      expect(ExerciseSequence([_exercise('A')], 0).hasNext, isFalse);
    });
  });

  group('Next button', () {
    testWidgets('is absent when the screen gets no sequence', (tester) async {
      _setSurface(tester);
      await tester.pumpWidget(
        _app(home: ExerciseDetailScreen(exercise: _exercise('A'))),
      );

      expect(find.byKey(_nextKey), findsNothing);
      expect(find.byKey(_doneKey), findsOneWidget);
    });

    testWidgets('is hidden on the last exercise', (tester) async {
      _setSurface(tester);
      final exercises = [_exercise('A'), _exercise('B')];
      await tester.pumpWidget(
        _app(
          home: ExerciseDetailScreen(
            exercise: exercises[1],
            sequence: ExerciseSequence(exercises, 1),
          ),
        ),
      );

      expect(find.byKey(_nextKey), findsNothing);
      expect(find.byKey(_doneKey), findsOneWidget);
    });

    testWidgets('is labelled in Spanish and English', (tester) async {
      _setSurface(tester);
      final exercises = [_exercise('A'), _exercise('B')];
      final screen = ExerciseDetailScreen(
        exercise: exercises[0],
        sequence: ExerciseSequence(exercises, 0),
      );

      await tester.pumpWidget(_app(home: screen, locale: 'es'));
      expect(
        find.descendant(
          of: find.byKey(_nextKey),
          matching: find.text('Siguiente'),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(_app(home: screen, locale: 'en'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byKey(_nextKey), matching: find.text('Next')),
        findsOneWidget,
      );
    });

    testWidgets(
        'replaces the exercise route, keeps the stack depth and lets Done '
        'return to the list', (tester) async {
      _setSurface(tester);
      final observer = _RouteCounter();
      await tester.pumpWidget(_listApp(['A', 'B', 'C'], observer));

      await tester.tap(find.text('Exercise A'));
      await tester.pumpAndSettle();
      expect(observer.depth, 2);
      expect(observer.lastName, ExerciseDetailScreen.routeName);
      expect(find.byKey(_nextKey), findsOneWidget);

      await tester.tap(find.byKey(_nextKey));
      await tester.pumpAndSettle();
      expect(find.text('Exercise B'), findsOneWidget);
      expect(observer.depth, 2);
      expect(observer.replacements, 1);
      expect(observer.lastName, ExerciseDetailScreen.routeName);

      await tester.tap(find.byKey(_nextKey));
      await tester.pumpAndSettle();
      expect(find.text('Exercise C'), findsOneWidget);
      expect(observer.depth, 2);
      expect(find.byKey(_nextKey), findsNothing);

      await tester.tap(find.byKey(_doneKey));
      await tester.pumpAndSettle();
      expect(observer.depth, 1);
      expect(find.byKey(_doneKey), findsNothing);
      expect(find.text('Exercise A'), findsOneWidget);
    });

    testWidgets('the next exercise starts with no completed sets',
        (tester) async {
      _setSurface(tester);
      await tester.pumpWidget(_listApp(['A', 'B'], _RouteCounter()));

      await tester.tap(find.text('Exercise A'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mark set complete'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.tap(find.byKey(_nextKey));
      await tester.pumpAndSettle();
      expect(find.text('Exercise B'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('stops a running hold timer when moving on', (tester) async {
      _setSurface(tester);
      final exercises = [
        _exercise('A', duration: 30),
        _exercise('B', duration: 30),
      ];
      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context)
                  .push(ExerciseDetailScreen.route(
                ExerciseSequence(exercises, 0),
              )),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Start timer'));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byKey(_nextKey));
      await tester.pumpAndSettle();
      expect(find.text('Exercise B'), findsOneWidget);
      expect(find.byTooltip('Pause timer'), findsNothing);
      // A periodic timer left running would fail the test at teardown.
    });
  });
}

void _setSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app({
  required Widget home,
  String locale = 'en',
  List<NavigatorObserver> observers = const [],
}) {
  return ProviderScope(
    overrides: [walkthroughUserIdProvider.overrideWithValue(null)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(locale),
      navigatorObservers: observers,
      home: home,
    ),
  );
}

Widget _listApp(List<String> names, NavigatorObserver observer) {
  return _app(
    observers: [observer],
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          ExerciseList(
            exercises: [for (final name in names) _exercise(name)],
          ),
        ],
      ),
    ),
  );
}

WorkoutExercise _exercise(String name, {int? duration}) {
  return WorkoutExercise(
    exercise: ExerciseVariant(
      variantId: 'test-$name',
      name: {'en': 'Exercise $name', 'es': 'Ejercicio $name'},
      description: const {'en': 'Description', 'es': 'Descripción'},
      visualPath: 'assets/images/workoutPicture.jpg',
      requiredLevel: ExerciseLevel.beginner,
    ),
    sets: 1,
    reps: duration == null ? 8 : null,
    rest: 30,
    duration: duration,
  );
}

class _RouteCounter extends NavigatorObserver {
  int depth = 0;
  int replacements = 0;
  String? lastName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    depth++;
    lastName = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    depth--;
    lastName = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacements++;
    lastName = newRoute?.settings.name;
  }
}
