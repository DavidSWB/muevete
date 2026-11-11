import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/repositories/training_repository.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/features/training/domain/services/workout_builder.dart';
import 'package:muevete/features/training/presentation/providers/program_setup_provider.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_builder_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:timezone/timezone.dart' as tz;

/// A new account saves its program and onboarding completes as soon as
/// Firestore reports the local write, so the home screen can load the workout
/// while the profile still holds no training. Once the save is done the
/// workout must load, instead of keeping that error until Retry.
void main() {
  setUp(() => NotificationScheduler.setAdapterForTesting(_SilentAdapter()));
  tearDown(NotificationScheduler.resetForTesting);

  test('the workout loads once a new account has saved its program', () async {
    final profileRepository = _NewAccountProfileRepository();
    final container = ProviderContainer(
      overrides: [
        trainingRepositoryProvider.overrideWithValue(_FixedPlans()),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        workoutBuilderProvider.overrideWithValue(_FakeWorkoutBuilder()),
      ],
    );
    addTearDown(container.dispose);

    // The diagnosis already loaded the profile: stats, but no training yet.
    final setupScreen = container.listen(programSetupProvider, (_, _) {});
    await container.read(programSetupProvider.future);
    final profile = container.listen(profileProvider, (_, _) {});
    expect((await container.read(profileProvider.future)).training, isNull);

    final saving = container
        .read(programSetupProvider.notifier)
        .savePlan('plan-1', const UserSchedule(days: {1: 1, 3: 1}));
    await Future<void>.delayed(Duration.zero);
    expect(profileRepository.saved, hasLength(1));

    // Onboarding completes before the write returns: MainScreen replaces the
    // setup screen and the home screen starts loading the workout.
    setupScreen.close();
    final home = container.listen(workoutControllerProvider, (_, _) {});
    addTearDown(home.close);
    await expectLater(
      container.read(workoutControllerProvider.future),
      throwsA(isA<StateError>()),
    );

    profileRepository.completeSave();
    await saving;
    profile.close();

    final workout = await container.read(workoutControllerProvider.future);
    // Which day comes next depends on today's weekday; either is from the plan.
    expect(workout.day, isIn([1, 2]));
    expect(container.read(workoutControllerProvider).hasError, isFalse);
  });
}

const _plan = TrainingPlan(
  planId: 'plan-1',
  name: {'en': 'Plan'},
  description: {'en': 'Plan'},
  daysPerWeek: 2,
  template: [
    PlanDay(day: 1, name: {'en': 'Day 1'}, exercises: []),
    PlanDay(day: 2, name: {'en': 'Day 2'}, exercises: []),
  ],
);

class _FixedPlans implements TrainingRepository {
  @override
  Future<TrainingPlan> getPlan(String id) async => _plan;

  @override
  Future<List<TrainingPlan>> getPlans() async => [_plan];
}

class _FakeWorkoutBuilder implements WorkoutBuilder {
  @override
  Future<Workout> buildWorkout({
    required TrainingPlan plan,
    required int day,
    required int week,
    required UserStats stats,
  }) async => Workout(exercises: const [], day: day, name: const {'en': 'W'});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Reads return the saved profile, like Firestore after a local write; the
/// save itself returns only when [completeSave] is called.
class _NewAccountProfileRepository implements ProfileRepository {
  final List<UserModel> saved = [];
  final Completer<void> _save = Completer<void>();

  UserModel _current = const UserModel(
    id: 'user-1',
    email: 'user@example.com',
    username: 'user',
    stats: UserStats(knee: 2, hip: 2, ankle: 2, shoulder: 2),
  );

  void completeSave() => _save.complete();

  @override
  Future<void> saveProfile(UserModel user) {
    saved.add(user);
    _current = user;
    return _save.future;
  }

  @override
  Future<UserModel> getProfile() async => _current;

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {}

  @override
  Future<void> createProfile(UserModel user, {String? privacyPolicyVersion}) async {}

  @override
  Future<void> unlockBadges(Set<String> badgeIds) async {}

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) async {}
}

class _SilentAdapter extends NotificationPluginAdapter {
  @override
  Future<void> initialize({
    void Function(NotificationResponse)? onTap,
  }) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> checkPermissionStatus() async => true;

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}
