import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/services/training_schedule_service.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'next_training_provider.g.dart';

@riverpod
Future<PlanDay> nextTraining(Ref ref) async {
  final user = await ref.watch(profileProvider.future);

  final repository = ref.watch(trainingRepositoryProvider);

  final plan = await repository.getPlan(
    user.training!.activePlanId,
  );

  return const TrainingScheduleService().getNextTrainingDay(
    user: user,
    plan: plan,
  );
}