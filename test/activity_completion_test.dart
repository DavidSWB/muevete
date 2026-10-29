import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/presentation/providers/active_break_providers.dart';
import 'package:muevete/features/active_breaks/presentation/screens/active_break_workout_screen.dart';
import 'package:muevete/features/active_breaks/presentation/screens/active_break_timer_screen.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/activity_recorder.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/providers/workout_completion_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';

void main() {
  late _RecordingProfileRepository repository;
  late int profileBuilds;

  ProviderContainer makeContainer({bool rehearsal = false}) {
    profileBuilds = 0;
    final container = ProviderContainer(
      overrides: _overrides(repository, () => profileBuilds++, rehearsal),
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => repository = _RecordingProfileRepository());

  group('ActivityRecorder', () {
    test(
      'records an active break as an active break, never a workout',
      () async {
        final container = makeContainer();
        await container.read(profileProvider.future);

        await container
            .read(activityRecorderProvider)
            .record(ActivityKind.activeBreak, DateTime(2026, 10, 25, 10));

        expect(repository.completions, hasLength(1));
        final completion = repository.completions.single;
        expect(completion.kind, ActivityKind.activeBreak);
        expect(completion.completedAt, DateTime(2026, 10, 25, 10));
        expect(repository.savedProfiles, isEmpty);
      },
    );

    test(
      'builds the streak from both histories plus the new completion',
      () async {
        final container = makeContainer();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day, 12);
        await container
            .read(activityRecorderProvider)
            .record(ActivityKind.workout, today);

        // _user has a workout two days ago and an active break yesterday.
        final streak = repository.completions.single.streak;
        expect(streak.current, 3);
        expect(streak.longest, 3);
        expect(streak.lastActiveDate, DateTime(now.year, now.month, now.day));
        expect(streak.timeZone, 'America/Bogota');
      },
    );

    test('reloads the profile after saving', () async {
      final container = makeContainer();
      container.listen(profileProvider, (_, _) {});
      await container.read(profileProvider.future);
      expect(profileBuilds, 1);

      await container
          .read(activityRecorderProvider)
          .record(ActivityKind.workout, DateTime.now());
      await container.read(profileProvider.future);

      expect(profileBuilds, 2);
    });
  });

  group('activeBreakCompletionProvider', () {
    test('persists by default', () {
      final container = makeContainer();
      expect(
        container.read(activeBreakCompletionProvider),
        isA<PersistingActiveBreakCompletion>(),
      );
    });

    test('records nothing during a rehearsal', () async {
      final container = makeContainer(rehearsal: true);
      final port = container.read(activeBreakCompletionProvider);
      expect(port, isA<TutorialActiveBreakCompletion>());

      await port.complete(DateTime.now());
      expect(repository.completions, isEmpty);
    });
  });

  test(
    'Finish Workout retried after an error keeps the same completion',
    () async {
      final container = makeContainer();
      container.listen(workoutControllerProvider, (_, _) {});
      final controller = container.read(workoutControllerProvider.notifier);

      repository.failNext = true;
      await expectLater(controller.finishWorkout(), throwsA(isA<StateError>()));
      await controller.finishWorkout();

      expect(repository.attempts, hasLength(2));
      expect(repository.attempts.first, repository.attempts.last);
      expect(repository.completions.single.kind, ActivityKind.workout);

      // The next finish is a new completion.
      await Future<void>.delayed(const Duration(milliseconds: 2));
      await controller.finishWorkout();
      expect(repository.completions, hasLength(2));
      expect(
        repository.completions.last.completedAt,
        isNot(repository.completions.first.completedAt),
      );
    },
  );

  group('Active-break routine', () {
    Future<void> finishRoutine(
      WidgetTester tester, {
      bool rehearsal = false,
    }) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: '/routine',
        routes: [
          GoRoute(
            path: '/routine',
            builder: (_, _) =>
                const ActiveBreakWorkoutScreen(activeBreak: _activeBreak),
          ),
          GoRoute(path: '/home', builder: (_, _) => const Text('home')),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._overrides(repository, () {}, rehearsal),
            activeBreakWorkoutProvider.overrideWith((ref, _) async => _routine),
          ],
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final finish = find.text('Mark active break as completed');
      await tester.ensureVisible(finish);
      await tester.pumpAndSettle();
      await tester.tap(finish);
      await tester.pumpAndSettle();
    }

    testWidgets('records one active break and goes Home', (tester) async {
      await finishRoutine(tester);

      expect(repository.completions, hasLength(1));
      expect(repository.completions.single.kind, ActivityKind.activeBreak);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('during the tour records nothing but still goes Home', (
      tester,
    ) async {
      await finishRoutine(tester, rehearsal: true);

      expect(repository.completions, isEmpty);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('a failed save stays on the routine and says so', (
      tester,
    ) async {
      repository.failNext = true;
      await finishRoutine(tester);

      expect(repository.completions, isEmpty);
      expect(find.text('Could not save. Please try again.'), findsOneWidget);
      expect(find.text('home'), findsNothing);
    });
  });

  group('Personal timer', () {
    Future<void> runTimerToTheEnd(
      WidgetTester tester, {
      bool rehearsal = false,
    }) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repository, () {}, rehearsal),
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ActiveBreakTimerScreen(),
          ),
        ),
      );
      await tester.tap(find.text('Start'));
      for (var i = 0; i < 181; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.tap(find.text('Mark active break as completed'));
      await tester.pumpAndSettle();
    }

    testWidgets('a finished timer counts as one active break', (tester) async {
      await runTimerToTheEnd(tester);

      expect(repository.completions, hasLength(1));
      expect(repository.completions.single.kind, ActivityKind.activeBreak);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('during the tour the timer records nothing', (tester) async {
      await runTimerToTheEnd(tester, rehearsal: true);

      expect(repository.completions, isEmpty);
      expect(find.text('Completed'), findsOneWidget);
    });
  });
}

List<Override> _overrides(
  _RecordingProfileRepository repository,
  void Function() onProfileBuild,
  bool rehearsal,
) => [
  profileRepositoryProvider.overrideWithValue(repository),
  deviceTimeZoneProvider.overrideWithValue(() async => 'America/Bogota'),
  profileProvider.overrideWith(() => _FakeProfile(onProfileBuild)),
  workoutControllerProvider.overrideWith(_FixedWorkoutController.new),
  workoutCompletionIsRehearsalProvider.overrideWithValue(rehearsal),
];

const _activeBreak = ActiveBreak(
  activeBreakId: 'ab-1',
  name: {'en': 'Desk stretch'},
  durationMinutes: 3,
  description: {'en': 'A quick stretch'},
  templates: [
    ActiveBreakTemplate(session: 1, name: {'en': 'Session 1'}, exercises: []),
  ],
);

const _routine = Workout(
  day: 1,
  name: {'en': 'Desk stretch'},
  exercises: [
    WorkoutExercise(
      exercise: ExerciseVariant(
        variantId: 'test',
        name: {'en': 'Test exercise'},
        description: {'en': 'Description'},
        visualPath: 'assets/images/workoutPicture.jpg',
        requiredLevel: ExerciseLevel.beginner,
      ),
      sets: 1,
      reps: null,
      rest: 0,
      duration: 30,
    ),
  ],
);

UserModel get _user {
  final now = DateTime.now();
  return UserModel(
    id: 'user-1',
    email: 'user@example.com',
    username: 'user',
    completedWorkouts: [DateTime(now.year, now.month, now.day - 2, 18)],
    completedActiveBreaks: [DateTime(now.year, now.month, now.day - 1, 9)],
  );
}

class _FakeProfile extends Profile {
  _FakeProfile(this._onBuild);

  final void Function() _onBuild;

  @override
  Future<UserModel> build() async {
    _onBuild();
    return _user;
  }
}

class _FixedWorkoutController extends WorkoutController {
  @override
  Future<Workout> build() async =>
      const Workout(exercises: [], day: 1, name: {'en': 'Day 1'});
}

class _RecordingProfileRepository implements ProfileRepository {
  final List<UserModel> savedProfiles = [];
  final List<DateTime> attempts = [];
  final List<({ActivityKind kind, DateTime completedAt, UserStreak streak})>
  completions = [];
  bool failNext = false;

  @override
  Future<UserModel> getProfile() async => _user;

  @override
  Future<void> saveProfile(UserModel user) async => savedProfiles.add(user);

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {}

  @override
  Future<void> createProfile(UserModel user) async => savedProfiles.add(user);

  @override

  Future<void> unlockBadges(Set<String> badgeIds) async {}


  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) async {
    attempts.add(completedAt);
    if (failNext) {
      failNext = false;
      throw StateError('offline');
    }
    completions.add((kind: kind, completedAt: completedAt, streak: streak));
  }
}
