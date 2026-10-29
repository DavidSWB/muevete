import 'package:muevete/features/gamification/domain/activity_reward.dart';

/// What happens when the user presses Finish Workout on the Training screen.
abstract interface class WorkoutCompletionPort {
  /// [workout] holds the sets the user marked as completed.
  Future<void> complete(CompletedWorkout workout);
}
