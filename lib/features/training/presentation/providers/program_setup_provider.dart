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

    state = const AsyncLoading();
    try {
      final user = await ref.read(profileProvider.future);
      final updatedUser = user.copyWith(
        training: UserTraining(
          activePlanId: plan.planId,
          planStartDate: DateTime.now(),
          schedule: schedule,
        ),
      );

      await ref.read(profileRepositoryProvider).saveProfile(updatedUser);
      
      try {
        await NotificationScheduler.rescheduleAll(updatedUser);
      } catch (e) {
        // Notification scheduling failed, but profile saved successfully
      }

      ref.invalidate(profileProvider);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
