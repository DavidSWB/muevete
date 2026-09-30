import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_setup_provider.g.dart';

@riverpod
class ProgramSetup extends _$ProgramSetup {
  @override
  Future<List<TrainingPlan>> build() {
    return ref.watch(trainingRepositoryProvider).getPlans();
  }

  Future<void> savePlan(String planId) async {
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
        ),
      );

      await ref.read(profileRepositoryProvider).saveProfile(updatedUser);
      ref.invalidate(profileProvider);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
