import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/providers/workout_completion_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:muevete/features/training/presentation/screens/training_screen.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';

void main() {
  group('workoutCompletionProvider', () {
    test('persists by default', () {
      final container = ProviderContainer(
        overrides: [
          workoutControllerProvider.overrideWith(_FixedWorkoutController.new),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(workoutCompletionProvider),
        isA<PersistingWorkoutCompletion>(),
      );
    });

    test('uses the tutorial adapter during a rehearsal', () {
      final container = ProviderContainer(
        overrides: [
          workoutCompletionIsRehearsalProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(workoutCompletionProvider),
        isA<TutorialWorkoutCompletion>(),
      );
    });
  });

  group('Finish Workout on the Training screen', () {
    testWidgets('records one workout day and reloads the profile',
        (tester) async {
      final harness = await _pumpTrainingScreen(tester, rehearsal: false);

      await _pressFinish(tester);

      expect(harness.repository.savedProfiles, hasLength(1));
      expect(
        harness.repository.savedProfiles.single.completedWorkouts,
        hasLength(_user.completedWorkouts.length + 1),
      );
      expect(harness.profileBuilds, 2);
      expect(harness.container.read(mainNavIndexProvider), 0);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('during a rehearsal writes nothing but still goes Home',
        (tester) async {
      final harness = await _pumpTrainingScreen(tester, rehearsal: true);

      await _pressFinish(tester);

      expect(harness.repository.savedProfiles, isEmpty);
      expect(harness.profileBuilds, 1);
      expect(harness.container.read(mainNavIndexProvider), 0);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('while the tour runs writes nothing but still goes Home',
        (tester) async {
      final harness = await _pumpTrainingScreen(tester, tourActive: true);
      expect(harness.container.read(walkthroughControllerProvider).isActive,
          isTrue);

      await _pressFinish(tester);

      expect(harness.repository.savedProfiles, isEmpty);
      expect(harness.profileBuilds, 1);
      expect(harness.container.read(mainNavIndexProvider), 0);
      expect(find.text('home'), findsOneWidget);
    });
  });
}

final _user = UserModel(
  id: 'user-1',
  email: 'user@example.com',
  username: 'user',
  completedWorkouts: [DateTime(2026, 10, 20)],
);

const _workout = Workout(
  day: 1,
  name: {'en': 'Day 1', 'es': 'Día 1'},
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
      reps: 8,
      rest: 30,
    ),
  ],
);

class _Harness {
  _Harness(this.container, this.repository);

  final ProviderContainer container;
  final _CountingProfileRepository repository;
  int profileBuilds = 0;
}

/// With [tourActive], the real walkthrough decides whether finishing is a
/// rehearsal; otherwise [rehearsal] is forced.
Future<_Harness> _pumpTrainingScreen(
  WidgetTester tester, {
  bool rehearsal = false,
  bool tourActive = false,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final repository = _CountingProfileRepository();
  late final _Harness harness;
  final container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repository),
      profileProvider.overrideWith(
        () => _FakeProfile(() => harness.profileBuilds++),
      ),
      workoutControllerProvider.overrideWith(_FixedWorkoutController.new),
      if (tourActive) ...[
        walkthroughStoreProvider.overrideWithValue(_MemoryWalkthroughStore()),
        walkthroughUserIdProvider.overrideWithValue('user-1'),
      ] else
        workoutCompletionIsRehearsalProvider.overrideWithValue(rehearsal),
    ],
  );
  addTearDown(container.dispose);
  harness = _Harness(container, repository);

  if (tourActive) {
    container.listen(walkthroughControllerProvider, (_, _) {});
    final tour = container.read(walkthroughControllerProvider.notifier);
    await tour.loaded;
    tour.start();
  }

  // Keeps the profile alive, so an invalidation shows up as a second build.
  container.listen(profileProvider, (_, _) {});
  await container.read(profileProvider.future);
  container.read(mainNavIndexProvider.notifier).setIndex(1);

  final router = GoRouter(
    initialLocation: '/training',
    routes: [
      GoRoute(
        path: '/training',
        builder: (_, _) => const TrainingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return harness;
}

Future<void> _pressFinish(WidgetTester tester) async {
  final finish = find.text('Finish Workout');
  await tester.ensureVisible(finish);
  await tester.pumpAndSettle();
  await tester.tap(finish);
  await tester.pumpAndSettle();
}

class _FixedWorkoutController extends WorkoutController {
  @override
  Future<Workout> build() async => _workout;
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

class _MemoryWalkthroughStore implements WalkthroughStore {
  final Map<String, WalkthroughProgress> data = {};

  @override
  Future<WalkthroughProgress?> load(String uid) async => data[uid];

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async =>
      data[uid] = progress;

  @override
  Future<void> clear(String uid) async => data.remove(uid);
}

class _CountingProfileRepository implements ProfileRepository {
  final List<UserModel> savedProfiles = [];

  @override
  Future<UserModel> getProfile() async => _user;

  @override
  Future<void> saveProfile(UserModel user) async => savedProfiles.add(user);
}
