import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_setup_provider.g.dart';

@riverpod
class ProgramSetup extends _$ProgramSetup {
  @override
  Future<List<TrainingPlan>> build() {
    return ref.watch(trainingRepositoryProvider).getPlans();
  }

  Future<void> savePlan(String planId, UserSchedule? schedule) async {
    final plans = state.asData?.value;
    TrainingPlan? plan;
    if (plans != null) {
      for (final candidate in plans) {
        if (candidate.planId == planId) {
          plan = candidate;
          break;
        }
      }
    }

    if (plan == null) {
      throw StateError('Select a valid training plan.');
    }

    if (schedule != null && schedule.days.length != plan.daysPerWeek) {
      throw ArgumentError(
        'Schedule must contain exactly ${plan.daysPerWeek} training days.',
      );
    }

    UserSchedule? canonicalSchedule = schedule;
    if (schedule != null) {
      final sortedWeekdays = schedule.days.keys.toList()..sort();
      final canonicalDays = <int, int>{};
      for (int i = 0; i < sortedWeekdays.length; i++) {
        canonicalDays[sortedWeekdays[i]] = i + 1;
      }
      canonicalSchedule = schedule.copyWith(days: canonicalDays);
    }

    try {
      final user = await ref.read(profileProvider.future);
      final existingTraining = user.training;

      final updatedTraining = existingTraining != null && existingTraining.activePlanId == plan.planId
          ? existingTraining.copyWith(
              schedule: canonicalSchedule,
            )
          : UserTraining(
              activePlanId: plan.planId,
              planStartDate: DateTime.now(),
              schedule: canonicalSchedule,
              extraFields: existingTraining?.extraFields ?? const {},
            );

      final updatedUser = user.copyWith(training: updatedTraining);

      await ref.read(profileProvider.notifier).saveProfile(updatedUser);
      
      try {
        await NotificationScheduler.rescheduleAll(updatedUser);
      } catch (e) {
        // Notification scheduling failed, but profile saved successfully
      }

      ref.invalidate(profileProvider);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
