import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/repositories/training_repository.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/features/training/presentation/providers/program_setup_provider.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUp(() => NotificationScheduler.setAdapterForTesting(_SilentAdapter()));
  tearDown(NotificationScheduler.resetForTesting);

  test(
    'savePlan completes when the screen goes away while the plan is saving',
    () async {
      final profileRepository = _ControlledProfileRepository();
      final container = ProviderContainer(
        overrides: [
          trainingRepositoryProvider.overrideWithValue(_FixedPlans()),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          profileProvider.overrideWith(_FakeProfile.new),
        ],
      );
      addTearDown(container.dispose);

      // Stands in for ProgramSetupScreen, the provider's only listener.
      final screen = container.listen(programSetupProvider, (_, _) {});
      await container.read(programSetupProvider.future);

      final saving = container
          .read(programSetupProvider.notifier)
          .savePlan('plan-1', const UserSchedule(days: {1: 1, 3: 1}));
      await Future<void>.delayed(Duration.zero);
      expect(profileRepository.saved, hasLength(1));

      // Saving the plan makes the onboarding gate swap ProgramSetupScreen for
      // MainScreen before the write returns.
      screen.close();
      await container.pump();

      profileRepository.completeSave();

      await expectLater(saving, completes);
      expect(profileRepository.saved.single.training?.activePlanId, 'plan-1');
    },
  );
}

const _plan = TrainingPlan(
  planId: 'plan-1',
  name: {'en': 'Plan'},
  description: {'en': 'Plan'},
  daysPerWeek: 2,
  template: [],
);

class _FixedPlans implements TrainingRepository {
  @override
  Future<TrainingPlan> getPlan(String id) async => _plan;

  @override
  Future<List<TrainingPlan>> getPlans() async => [_plan];
}

class _FakeProfile extends Profile {
  @override
  Future<UserModel> build() async =>
      const UserModel(id: 'user-1', email: 'user@example.com', username: 'user');
}

class _ControlledProfileRepository implements ProfileRepository {
  final List<UserModel> saved = [];
  final Completer<void> _save = Completer<void>();

  void completeSave() => _save.complete();

  @override
  Future<void> saveProfile(UserModel user) {
    saved.add(user);
    return _save.future;
  }

  @override
  Future<UserModel> getProfile() async => saved.last;

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {}

  @override
  Future<void> createProfile(UserModel user, {int? acceptedPolicyVersion}) async {}

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
