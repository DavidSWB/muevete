import 'dart:async';

import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/services/training_schedule_service.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_builder_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workout_controller.g.dart';

@riverpod
class WorkoutController extends _$WorkoutController {

  @override
  Future<Workout> build() {
    return _loadWorkout();
  }

  Future<Workout> _loadWorkout() async {

    final user = await ref.read(profileProvider.future);

    final repository =
        ref.read(trainingRepositoryProvider);

    final builder =
        ref.read(workoutBuilderProvider);

    final schedule =
        const TrainingScheduleService();

    final plan = await repository.getPlan(
      user.training!.activePlanId,
    );
    
    final week = schedule.calculateCurrentWeek(
      user: user,
    );

    final day = schedule.calculateTrainingDay(
      user: user,
      plan: plan,
    );

    return builder.buildWorkout(
      plan: plan,
      week: week,
      day: day,
      stats: user.stats!,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

}