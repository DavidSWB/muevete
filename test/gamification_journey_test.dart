import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/active_breaks/presentation/providers/active_break_providers.dart';
import 'package:muevete/features/gamification/data/firebase_achievement_repository.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/gamification/domain/reward_rules.dart';
import 'package:muevete/features/gamification/presentation/badge_sync.dart';
import 'package:muevete/features/gamification/presentation/gamification_providers.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/domain/services/weekly_activity.dart';
import 'package:muevete/features/profile/presentation/activity_recorder.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_completion_provider.dart';

/// The journey from the brief, end to end against an in-memory profile that
/// behaves like the Firestore one: a completion already in the history
/// writes nothing, and badges are add-only.
void main() {
  late _MemoryProfileRepository repository;

  ProviderContainer makeContainer({bool rehearsal = false}) {
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repository),
        profileProvider.overrideWith(() => _MemoryProfile(repository)),
        deviceTimeZoneProvider.overrideWithValue(() async => 'America/Bogota'),
        rewardRulesProvider.overrideWith((ref) async => RewardRules.defaults),
        achievementsProvider.overrideWith((ref) async => _catalogue),
        workoutCompletionIsRehearsalProvider.overrideWithValue(rehearsal),
      ],
    );
    addTearDown(container.dispose);
    container.listen(profileProvider, (_, _) {});
    return container;
  }

  Future<Set<String>> checkBadges(
    ProviderContainer container, {
    bool tourCompleted = false,
  }) async => container
      .read(badgeSyncProvider)
      .sync(
        await container.read(profileProvider.future),
        walkthroughCompleted: tourCompleted,
      );

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime at(int hour, [int minute = 0]) =>
      DateTime(today.year, today.month, today.day, hour, minute);

  setUp(() {
    // A new account, as createProfile writes it.
    repository = _MemoryProfileRepository(
      UserModel(
        id: 'u',
        email: 'e',
        username: 'n',
        consistencyTrackedSince: today.subtract(const Duration(days: 1)),
      ),
    );
  });

  test('a new account starts with nothing earned', () async {
    final container = makeContainer();
    expect(await checkBadges(container), isEmpty);
    final user = repository.user;
    expect(user.movementXp, 0);
    expect(user.jointProgress, isEmpty);
    expect(countThisWeek(user.completedActiveBreaks, now), 0);
  });

  test('the tour rehearsal records and rewards nothing', () async {
    final container = makeContainer(rehearsal: true);

    await container.read(workoutCompletionProvider).complete(_partialWorkout);
    await container.read(activeBreakCompletionProvider).complete(at(10));

    expect(repository.writes, 0);
    expect(repository.user.movementXp, 0);
  });

  test('finishing the tour gives the guide badge once', () async {
    final container = makeContainer();
    expect(await checkBadges(container, tourCompleted: true), {
      'guide-completed',
    });
    expect(await checkBadges(container, tourCompleted: true), isEmpty);
    expect(repository.user.unlockedBadgeIds, ['guide-completed']);
  });

  test('workouts, retries and breaks add up without double rewards', () async {
    final container = makeContainer();
    final recorder = container.read(activityRecorderProvider);

    // A workout with 2 of 6 sets ticked.
    await recorder.record(
      ActivityKind.workout,
      at(7),
      workout: _partialWorkout,
    );
    expect(repository.user.movementXp, 10);
    expect(repository.user.jointProgress, {'knee': 2, 'hip': 2, 'shoulder': 2});
    expect(await checkBadges(container), {'first-workout'});

    // The same completion again (a retry or a double tap) changes nothing.
    await recorder.record(
      ActivityKind.workout,
      at(7),
      workout: _partialWorkout,
    );
    expect(repository.user.completedWorkouts, hasLength(1));
    expect(repository.user.movementXp, 10);

    // A second workout today is saved but not rewarded.
    await recorder.record(
      ActivityKind.workout,
      at(8),
      workout: _partialWorkout,
    );
    expect(repository.user.completedWorkouts, hasLength(2));
    expect(repository.user.movementXp, 10);

    // Routine and timer breaks share one history.
    final breaks = container.read(activeBreakCompletionProvider);
    await breaks.complete(at(10));
    expect(await checkBadges(container), {'first-active-break'});
    await breaks.complete(at(11));
    await breaks.complete(at(11)); // retried
    await breaks.complete(at(12));

    expect(repository.user.completedActiveBreaks, hasLength(3));
    expect(repository.user.movementXp, 10 + 3 * 15);
    expect(countThisWeek(repository.user.completedActiveBreaks, now), 3);
    expect(await checkBadges(container), {'on-the-move'});
    expect(await checkBadges(container), isEmpty);

    // A fifth break today still counts toward the week, without XP.
    await breaks.complete(at(13));
    await breaks.complete(at(14));
    expect(repository.user.movementXp, 10 + 4 * 15);
    expect(countThisWeek(repository.user.completedActiveBreaks, now), 5);
  });
}

final _partialWorkout = CompletedWorkout([
  const CompletedExercise(
    targets: ['knee', 'hip'],
    completedSets: 1,
    prescribedSets: 3,
  ),
  const CompletedExercise(
    targets: ['shoulder'],
    completedSets: 1,
    prescribedSets: 3,
  ),
]);

final _catalogue = [
  for (final (id, order, condition) in [
    ('first-active-break', 1, {'type': 'activeBreaks', 'count': 1}),
    ('first-workout', 2, {'type': 'workouts', 'count': 1}),
    ('guide-completed', 3, {'type': 'walkthroughCompleted'}),
    ('on-the-move', 4, {'type': 'activeBreaks', 'count': 3}),
  ])
    FirebaseAchievementRepository.parse(id, {
      'order': order,
      'name': {'es': id, 'en': id},
      'description': {'es': id, 'en': id},
      'condition': condition,
    }),
];

class _MemoryProfile extends Profile {
  _MemoryProfile(this._repository);

  final _MemoryProfileRepository _repository;

  @override
  Future<UserModel> build() async => _repository.user;
}

class _MemoryProfileRepository implements ProfileRepository {
  _MemoryProfileRepository(this.user);

  UserModel user;
  int writes = 0;

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) async {
    final isWorkout = kind == ActivityKind.workout;
    final history = isWorkout
        ? user.completedWorkouts
        : user.completedActiveBreaks;
    if (history.contains(completedAt)) return;

    writes++;
    final earned = reward?.call(history) ?? ActivityReward.none;
    final points = {...user.jointProgress};
    earned.jointPoints.forEach(
      (joint, value) => points[joint] = (points[joint] ?? 0) + value,
    );
    user = user.copyWith(
      completedWorkouts: isWorkout ? [...history, completedAt] : null,
      completedActiveBreaks: isWorkout ? null : [...history, completedAt],
      movementXp: user.movementXp + earned.xp,
      jointProgress: points,
      streak: streak,
    );
  }

  @override
  Future<void> unlockBadges(Set<String> badgeIds) async {
    writes++;
    user = user.copyWith(
      unlockedBadgeIds: {...user.unlockedBadgeIds, ...badgeIds}.toList(),
    );
  }

  @override
  Future<UserModel> getProfile() async => user;

  @override
  Future<void> saveProfile(UserModel user) async {}

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {}

  @override
  Future<void> createProfile(UserModel user, {String? privacyPolicyVersion}) async {}
}
