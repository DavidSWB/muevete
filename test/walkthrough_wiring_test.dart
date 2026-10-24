import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/settings/presentation/screens/settings_screen.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_sequence.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/providers/workout_completion_provider.dart';
import 'package:muevete/features/training/presentation/screens/exercise_detail_screen.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_steps.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Finish Workout is a rehearsal only while the tour runs', () async {
    final tour = await _Tour.create();

    expect(tour.container.read(workoutCompletionIsRehearsalProvider), isFalse);

    tour.controller.start();
    expect(tour.container.read(workoutCompletionIsRehearsalProvider), isTrue);
    expect(
      tour.container.read(workoutCompletionProvider),
      isA<TutorialWorkoutCompletion>(),
    );

    tour.controller.dismiss();
    expect(tour.container.read(workoutCompletionIsRehearsalProvider), isFalse);
  });

  group('Exercise screen reports to the tour', () {
    testWidgets('completing a set moves on to Next', (tester) async {
      final tour = await _Tour.create();
      tour.goTo('exercise.completeSet');
      await _pumpExercise(tester, tour, ExerciseSequence(_twoExercises, 0));

      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      await tester.pump();

      expect(tour.stepId, 'exercise.next');
    });

    testWidgets('on the last exercise the Next step is skipped',
        (tester) async {
      final tour = await _Tour.create();
      tour.goTo('exercise.completeSet');
      await _pumpExercise(tester, tour, ExerciseSequence(_twoExercises, 1));

      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      await tester.pump();

      expect(tour.stepId, 'exercise.done');
    });

    testWidgets('Next is reported before the next exercise opens',
        (tester) async {
      final tour = await _Tour.create();
      tour.goTo('exercise.next');
      // A third exercise keeps the Next step from being skipped on the
      // second one, so only the receipt is checked here.
      await _pumpExercise(
        tester,
        tour,
        ExerciseSequence([..._twoExercises, _exercise('C')], 0),
      );

      await tester.tap(find.byKey(const ValueKey('exercise-next-button')));
      await tester.pumpAndSettle();

      expect(find.text('Exercise B'), findsOneWidget);
      expect(tour.state.receiptSeen, isTrue);
      // The app's route observer reports the new exercise screen.
      tour.controller.onSignal(
        const ScreenRevealed(WalkthroughScreen.exercise),
      );
      expect(tour.stepId, 'exercise.done');
    });
  });

  testWidgets('Take the tour again in Settings starts the tour',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tour = await _Tour.create(
      overrides: [profileProvider.overrideWith(_FakeProfile.new)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: tour.container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final replay = find.text('Take the tour again');
    expect(replay, findsOneWidget);
    expect(find.text('Walk through the app step by step'), findsOneWidget);

    await tester.tap(replay);
    await tester.pumpAndSettle();

    expect(tour.state.isActive, isTrue);
    expect(tour.stepId, 'home.welcome');
  });
}

final _twoExercises = [_exercise('A'), _exercise('B')];

WorkoutExercise _exercise(String name) {
  return WorkoutExercise(
    exercise: ExerciseVariant(
      variantId: 'test-$name',
      name: {'en': 'Exercise $name'},
      description: const {'en': 'Description'},
      visualPath: 'assets/images/workoutPicture.jpg',
      requiredLevel: ExerciseLevel.beginner,
    ),
    sets: 1,
    reps: 8,
    rest: 30,
  );
}

Future<void> _pumpExercise(
  WidgetTester tester,
  _Tour tour,
  ExerciseSequence sequence,
) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: tour.container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ExerciseDetailScreen(
          exercise: sequence.current,
          sequence: sequence,
        ),
      ),
    ),
  );
  // The screen reports whether a next exercise exists after its first frame.
  await tester.pump();
}

class _Tour {
  _Tour(this.container);

  final ProviderContainer container;

  WalkthroughController get controller =>
      container.read(walkthroughControllerProvider.notifier);
  WalkthroughState get state => container.read(walkthroughControllerProvider);
  String get stepId => state.step.id;

  static Future<_Tour> create({List<Override> overrides = const []}) async {
    final container = ProviderContainer(
      overrides: [
        walkthroughStoreProvider.overrideWithValue(_MemoryStore()),
        walkthroughUserIdProvider.overrideWithValue('u'),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    container.listen(walkthroughControllerProvider, (_, _) {});
    await container.read(walkthroughControllerProvider.notifier).loaded;
    return _Tour(container);
  }

  /// Walks the real controller to [id], as the app's signals would.
  void goTo(String id) {
    controller.start();
    final target = walkthroughStepIndex(id);
    while (state.stepIndex < target) {
      final step = state.step;
      if (!step.isGated) {
        controller.next();
        continue;
      }
      if (step.requiresFirst != null) controller.onSignal(step.requiresFirst!);
      controller.onSignal(step.completesOn!);
    }
    expect(stepId, id);
  }
}

class _FakeProfile extends Profile {
  @override
  Future<UserModel> build() async => UserModel(
        id: 'u',
        email: 'user@example.com',
        username: 'user',
        completedWorkouts: const [],
      );
}

class _MemoryStore implements WalkthroughStore {
  final Map<String, WalkthroughProgress> data = {};

  @override
  Future<WalkthroughProgress?> load(String uid) async => data[uid];

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async =>
      data[uid] = progress;

  @override
  Future<void> clear(String uid) async => data.remove(uid);
}
