import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/training/domain/repositories/workout_completion_port.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';

/// Whether finishing a workout is only a rehearsal, such as during the in-app
/// tour, and must not be recorded.
final workoutCompletionIsRehearsalProvider = Provider<bool>(
  (ref) => ref.watch(walkthroughControllerProvider.select((s) => s.isActive)),
);

/// Read when Finish Workout is pressed, so the choice holds for that press.
final workoutCompletionProvider =
    Provider.autoDispose<WorkoutCompletionPort>((ref) {
  if (ref.watch(workoutCompletionIsRehearsalProvider)) {
    return const TutorialWorkoutCompletion();
  }
  return PersistingWorkoutCompletion(
    ref.read(workoutControllerProvider.notifier),
  );
});

/// Records the workout in the user's history, as Finish Workout always has.
class PersistingWorkoutCompletion implements WorkoutCompletionPort {
  const PersistingWorkoutCompletion(this._controller);

  final WorkoutController _controller;

  @override
  Future<void> complete(CompletedWorkout workout) =>
      _controller.finishWorkout(workout);
}

/// Lets the tour rehearse Finish Workout without recording anything.
class TutorialWorkoutCompletion implements WorkoutCompletionPort {
  const TutorialWorkoutCompletion();

  @override
  Future<void> complete(CompletedWorkout workout) async {}
}
