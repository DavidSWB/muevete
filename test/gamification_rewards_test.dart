import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/gamification/domain/joint_level.dart';
import 'package:muevete/features/gamification/domain/reward_calculator.dart';
import 'package:muevete/features/gamification/domain/reward_rules.dart';
import 'package:muevete/features/gamification/presentation/gamification_providers.dart';
import 'package:muevete/features/gamification/presentation/movement_progress_section.dart';
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
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/providers/workout_set_progress_provider.dart';
import 'package:muevete/l10n/app_localizations.dart';

void main() {
  const calculator = RewardCalculator(RewardRules.defaults);
  final noon = DateTime(2026, 10, 29, 12);

  CompletedExercise exercise(
    List<String> targets, {
    required int done,
    int of = 3,
  }) => CompletedExercise(
    targets: targets,
    completedSets: done,
    prescribedSets: of,
  );

  group('RewardRules.fromJson', () {
    test('reads every value of the stored document', () {
      final rules = RewardRules.fromJson({
        'xp': {
          'workoutPerSet': 6,
          'workoutMax': 90,
          'workoutRewardsPerDay': 2,
          'activeBreak': 10,
          'activeBreakRewardsPerDay': 3,
        },
        'joints': {
          'pointsPerSet': 4,
          'levelThresholds': [0, 20, 60],
        },
      });

      expect(rules.workoutXpPerSet, 6);
      expect(rules.workoutXpMax, 90);
      expect(rules.workoutRewardsPerDay, 2);
      expect(rules.activeBreakXp, 10);
      expect(rules.activeBreakRewardsPerDay, 3);
      expect(rules.jointPointsPerSet, 4);
      expect(rules.levelThresholds, [0, 20, 60]);
    });

    test('keeps the default for each missing or invalid value', () {
      final rules = RewardRules.fromJson({
        'xp': {'workoutPerSet': 'five', 'workoutMax': -1, 'activeBreak': 20},
        'joints': 'not a map',
      });

      expect(rules.workoutXpPerSet, 5);
      expect(rules.workoutXpMax, 100);
      expect(rules.activeBreakXp, 20);
      expect(rules.jointPointsPerSet, 2);
      expect(rules.levelThresholds, [0, 30, 80, 150, 250]);
    });

    test('an empty document gives the defaults', () {
      final rules = RewardRules.fromJson({});
      expect(rules.workoutRewardsPerDay, 1);
      expect(rules.activeBreakRewardsPerDay, 4);
      expect(rules.levelThresholds, RewardRules.defaults.levelThresholds);
    });

    for (final bad in [
      <Object>[],
      [10, 30],
      [0, 30, 30],
      [0, 50, 40],
      [0, 'x'],
    ]) {
      test('ignores level thresholds $bad', () {
        final rules = RewardRules.fromJson({
          'joints': {'levelThresholds': bad},
        });
        expect(rules.levelThresholds, RewardRules.defaults.levelThresholds);
      });
    }
  });

  group('RewardCalculator.forWorkout', () {
    test('gives XP per completed set and points per target joint', () {
      final reward = calculator.forWorkout(
        workout: CompletedWorkout([
          exercise(['knee', 'hip'], done: 3),
          exercise(['shoulder'], done: 2),
        ]),
        completedAt: noon,
        earlierWorkouts: const [],
      );

      expect(
        reward,
        const ActivityReward(
          xp: 25,
          jointPoints: {'knee': 6, 'hip': 6, 'shoulder': 4},
        ),
      );
    });

    test('never counts more sets than were prescribed', () {
      final reward = calculator.forWorkout(
        workout: CompletedWorkout([
          exercise(['ankle'], done: 9, of: 2),
        ]),
        completedAt: noon,
        earlierWorkouts: const [],
      );

      expect(reward, const ActivityReward(xp: 10, jointPoints: {'ankle': 4}));
    });

    test('caps one workout at the maximum XP', () {
      final reward = calculator.forWorkout(
        workout: CompletedWorkout([
          for (var i = 0; i < 8; i++) exercise(['hip'], done: 3),
        ]),
        completedAt: noon,
        earlierWorkouts: const [],
      );

      expect(reward.xp, 100);
      expect(reward.jointPoints, {'hip': 48});
    });

    test('no completed sets gives nothing', () {
      final reward = calculator.forWorkout(
        workout: CompletedWorkout([
          exercise(['knee'], done: 0),
        ]),
        completedAt: noon,
        earlierWorkouts: const [],
      );

      expect(reward.isEmpty, isTrue);
      expect(
        calculator
            .forWorkout(
              workout: CompletedWorkout.empty,
              completedAt: noon,
              earlierWorkouts: const [],
            )
            .isEmpty,
        isTrue,
      );
    });

    test('ignores unknown joints and repeated targets', () {
      final reward = calculator.forWorkout(
        workout: CompletedWorkout([
          exercise(['wrist', 'knee', 'knee'], done: 1),
        ]),
        completedAt: noon,
        earlierWorkouts: const [],
      );

      expect(reward, const ActivityReward(xp: 5, jointPoints: {'knee': 2}));
    });

    test('only the first workout of a day gives a reward', () {
      final workout = CompletedWorkout([
        exercise(['knee'], done: 3),
      ]);

      final secondToday = calculator.forWorkout(
        workout: workout,
        completedAt: noon,
        earlierWorkouts: [DateTime(2026, 10, 29, 7)],
      );
      final firstToday = calculator.forWorkout(
        workout: workout,
        completedAt: noon,
        earlierWorkouts: [DateTime(2026, 10, 28, 23, 59)],
      );

      expect(secondToday, ActivityReward.none);
      expect(firstToday.xp, 15);
    });
  });

  group('RewardCalculator.forActiveBreak', () {
    test('gives flat XP and no joint points', () {
      expect(
        calculator.forActiveBreak(
          completedAt: noon,
          earlierActiveBreaks: const [],
        ),
        const ActivityReward(xp: 15),
      );
    });

    test('stops after four breaks in a day', () {
      final today = [for (var h = 8; h < 12; h++) DateTime(2026, 10, 29, h)];

      expect(
        calculator.forActiveBreak(
          completedAt: noon,
          earlierActiveBreaks: today.take(3).toList(),
        ),
        const ActivityReward(xp: 15),
      );
      expect(
        calculator.forActiveBreak(
          completedAt: noon,
          earlierActiveBreaks: today,
        ),
        ActivityReward.none,
      );
    });
  });

  group('JointLevel', () {
    const thresholds = [0, 30, 80, 150, 250];

    test('starts at level 1', () {
      final level = JointLevel.fromPoints(0, thresholds);
      expect(level.level, 1);
      expect(level.nextLevelAt, 30);
      expect(level.progress, 0);
      expect(level.pointsToNext, 30);
    });

    test('moves up exactly at a threshold', () {
      expect(JointLevel.fromPoints(29, thresholds).level, 1);
      final level = JointLevel.fromPoints(30, thresholds);
      expect(level.level, 2);
      expect(level.levelStart, 30);
      expect(level.nextLevelAt, 80);
    });

    test('measures progress within the level', () {
      final level = JointLevel.fromPoints(55, thresholds);
      expect(level.level, 2);
      expect(level.progress, closeTo(0.5, 0.001));
      expect(level.pointsToNext, 25);
    });

    test('stops at the top level', () {
      final level = JointLevel.fromPoints(400, thresholds);
      expect(level.level, 5);
      expect(level.isMaxLevel, isTrue);
      expect(level.progress, 1);
      expect(level.pointsToNext, 0);
    });

    test('treats negative points as zero', () {
      final level = JointLevel.fromPoints(-5, thresholds);
      expect(level.level, 1);
      expect(level.points, 0);
    });
  });

  group('WorkoutSetProgress', () {
    test('keeps ticks per exercise and sums them up for Finish', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = workoutSetProgressProvider(_exercises);
      container.listen(provider, (_, _) {});

      container.read(provider.notifier).setCompleted(0, {0, 2});
      container.read(provider.notifier).setCompleted(1, {1});

      expect(container.read(provider.notifier).completedSets(0), {0, 2});
      expect(container.read(provider.notifier).completedSets(2), isEmpty);

      final summary = container.read(provider.notifier).summary();
      expect(summary.completedSets, 3);
      expect(summary.exercises.first.targets, ['knee', 'hip']);
      expect(
        calculator.forWorkout(
          workout: summary,
          completedAt: noon,
          earlierWorkouts: const [],
        ),
        const ActivityReward(
          xp: 15,
          jointPoints: {'knee': 4, 'hip': 4, 'shoulder': 2},
        ),
      );
    });

    test('a newly built workout starts with nothing ticked', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final first = workoutSetProgressProvider(_exercises);
      container.listen(first, (_, _) {});
      container.read(first.notifier).setCompleted(0, {0});

      final rebuilt = workoutSetProgressProvider(List.of(_exercises));
      container.listen(rebuilt, (_, _) {});
      expect(container.read(rebuilt.notifier).summary().completedSets, 0);
    });
  });

  group('ActivityRecorder rewards', () {
    late _RewardingProfileRepository repository;

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          deviceTimeZoneProvider.overrideWithValue(
            () async => 'America/Bogota',
          ),
          profileProvider.overrideWith(() => _FakeProfile(repository)),
          rewardRulesProvider.overrideWith(
            (ref) async => RewardRules.defaults,
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    setUp(() => repository = _RewardingProfileRepository());

    final workout = CompletedWorkout([
      exercise(['knee', 'hip'], done: 2),
      exercise(['shoulder'], done: 3),
    ]);

    test('adds the workout XP and joint points', () async {
      final container = makeContainer();

      await container
          .read(activityRecorderProvider)
          .record(ActivityKind.workout, noon, workout: workout);

      expect(repository.user.movementXp, 25);
      expect(repository.user.jointProgress, {
        'knee': 4,
        'hip': 4,
        'shoulder': 6,
      });
      expect(repository.user.completedWorkouts, [noon]);
    });

    test('recording the same completion twice rewards it once', () async {
      final container = makeContainer();
      final recorder = container.read(activityRecorderProvider);

      await recorder.record(ActivityKind.workout, noon, workout: workout);
      await recorder.record(ActivityKind.workout, noon, workout: workout);

      expect(repository.user.completedWorkouts, hasLength(1));
      expect(repository.user.movementXp, 25);
    });

    test('a second workout the same day is saved without a reward', () async {
      final container = makeContainer();
      final recorder = container.read(activityRecorderProvider);

      await recorder.record(ActivityKind.workout, noon, workout: workout);
      await recorder.record(
        ActivityKind.workout,
        noon.add(const Duration(hours: 3)),
        workout: workout,
      );

      expect(repository.user.completedWorkouts, hasLength(2));
      expect(repository.user.movementXp, 25);
    });

    test('an active break adds flat XP and no joint points', () async {
      final container = makeContainer();

      await container
          .read(activityRecorderProvider)
          .record(ActivityKind.activeBreak, noon, workout: workout);

      expect(repository.user.movementXp, 15);
      expect(repository.user.jointProgress, isEmpty);
    });

    test('falls back to the default rules when they cannot be read', () async {
      final container = ProviderContainer(
        overrides: [
          rewardRulesRepositoryProvider.overrideWithValue(_FailingRules()),
        ],
      );
      addTearDown(container.dispose);

      final rules = await container.read(rewardRulesProvider.future);
      expect(rules.workoutXpPerSet, RewardRules.defaults.workoutXpPerSet);
    });
  });

  group('UserModel', () {
    test('reads movement XP and joint progress', () {
      final user = UserModel.fromJson(
        id: 'u',
        json: {
          'movementXp': 40,
          'jointProgress': {'knee': 12, 'hip': 3.0, 'bad': 'x'},
        },
      );

      expect(user.movementXp, 40);
      expect(user.jointProgress, {'knee': 12, 'hip': 3});
    });

    test('older profiles start at zero', () {
      final user = UserModel.fromJson(id: 'u', json: {});
      expect(user.movementXp, 0);
      expect(user.jointProgress, isEmpty);
    });

    test('never writes rewards from a profile save', () {
      const user = UserModel(
        id: 'u',
        email: 'e',
        username: 'n',
        movementXp: 10,
        jointProgress: {'knee': 2},
      );
      expect(user.toJson().containsKey('movementXp'), isFalse);
      expect(user.toJson().containsKey('jointProgress'), isFalse);
    });
  });

  group('MovementProgressSection', () {
    Future<void> pump(WidgetTester tester, Locale locale) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rewardRulesProvider.overrideWith(
              (ref) async => RewardRules.defaults,
            ),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: MovementProgressSection(
                  user: UserModel(
                    id: 'u',
                    email: 'e',
                    username: 'n',
                    movementXp: 120,
                    jointProgress: {'knee': 55, 'shoulder': 300},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows XP and each joint level in Spanish', (tester) async {
      await pump(tester, const Locale('es'));

      expect(find.text('Tu progreso de movimiento'), findsOneWidget);
      expect(find.text('120 XP'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Rodilla: nivel 2, 55 de 80 puntos'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Hombro: nivel 5, nivel máximo'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Tobillo: nivel 1, 0 de 30 puntos'),
        findsOneWidget,
      );
    });

    testWidgets('shows XP and each joint level in English', (tester) async {
      await pump(tester, const Locale('en'));

      expect(find.text('Your movement progress'), findsOneWidget);
      expect(find.text('120 XP'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Knee: level 2, 55 of 80 points'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Hip: level 1, 0 of 30 points'),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
    });
  });
}

ExerciseVariant _variant(String id) => ExerciseVariant(
  variantId: id,
  name: {'en': id},
  description: {'en': id},
  visualPath: 'assets/images/workoutPicture.jpg',
  requiredLevel: ExerciseLevel.beginner,
);

final _exercises = [
  WorkoutExercise(
    exercise: _variant('squat'),
    sets: 3,
    reps: 10,
    rest: 30,
    targets: const ['knee', 'hip'],
  ),
  WorkoutExercise(
    exercise: _variant('press'),
    sets: 2,
    reps: 10,
    rest: 30,
    targets: const ['shoulder'],
  ),
  WorkoutExercise(
    exercise: _variant('calf'),
    sets: 2,
    reps: 10,
    rest: 30,
    targets: const ['ankle'],
  ),
];

class _FailingRules implements RewardRulesRepository {
  @override
  Future<RewardRules> getRules() async => throw StateError('offline');
}

class _FakeProfile extends Profile {
  _FakeProfile(this._repository);

  final _RewardingProfileRepository _repository;

  @override
  Future<UserModel> build() async => _repository.user;
}

/// Mirrors the Firestore transaction: an entry already in the history
/// changes nothing; otherwise the reward is worked out from what was there.
class _RewardingProfileRepository implements ProfileRepository {
  UserModel user = const UserModel(id: 'u', email: 'e', username: 'n');
  final List<Set<String>> unlockCalls = [];

  @override
  Future<UserModel> getProfile() async => user;

  @override
  Future<void> saveProfile(UserModel user) async {}

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {}

  @override
  Future<void> createProfile(UserModel user, {int? acceptedPolicyVersion}) async {}

  @override

  Future<void> unlockBadges(Set<String> badgeIds) async {

    unlockCalls.add(badgeIds);

    user = user.copyWith(

      unlockedBadgeIds: {...user.unlockedBadgeIds, ...badgeIds}.toList(),

    );

  }


  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) async {
    final history = kind == ActivityKind.workout
        ? user.completedWorkouts
        : user.completedActiveBreaks;
    if (history.contains(completedAt)) return;

    final earned = reward?.call(history) ?? ActivityReward.none;
    final points = {...user.jointProgress};
    earned.jointPoints.forEach(
      (joint, value) => points[joint] = (points[joint] ?? 0) + value,
    );
    user = user.copyWith(
      completedWorkouts: kind == ActivityKind.workout
          ? [...history, completedAt]
          : null,
      completedActiveBreaks: kind == ActivityKind.activeBreak
          ? [...history, completedAt]
          : null,
      movementXp: user.movementXp + earned.xp,
      jointProgress: points,
      streak: streak,
    );
  }
}
