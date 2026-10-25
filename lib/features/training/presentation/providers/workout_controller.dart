import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/presentation/activity_recorder.dart';
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
    debugPrint('Workout: user loaded; training=${user.training}, stats=${user.stats}');

  final training = user.training;
  final stats = user.stats;

  if (training == null || stats == null) {
    throw StateError(
      'Workout needs training and stats; '
      'training=${training != null}, stats=${stats != null}',
    );
  }

  debugPrint('Workout: activePlanId=${training.activePlanId}');



    final repository =
        ref.read(trainingRepositoryProvider);

    final builder =
        ref.read(workoutBuilderProvider);

    final schedule =
        const TrainingScheduleService();

    final plan = await repository.getPlan(training.activePlanId);
    debugPrint('Workout: plan loaded; days=${plan.template.length}');
        
        final week = schedule.calculateCurrentWeek(
          user: user,
    );

    final planDay = schedule.getNextTrainingDay(
      user: user,
      plan: plan,
    );

    return builder.buildWorkout(
      plan: plan,
      week: week,
      day: planDay.day,
      stats: user.stats!,
    );
  }

  /// Set on the first Finish press and kept until it is saved, so a retry
  /// after an error records the same completion instead of a second one.
  DateTime? _pendingCompletion;

  Future<void> finishWorkout() async {
    final completedAt = _pendingCompletion ??= DateTime.now();
    await ref
        .read(activityRecorderProvider)
        .record(ActivityKind.workout, completedAt);
    _pendingCompletion = null;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

}