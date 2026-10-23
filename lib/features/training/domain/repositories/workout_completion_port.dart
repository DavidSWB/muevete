/// What happens when the user presses Finish Workout on the Training screen.
abstract interface class WorkoutCompletionPort {
  Future<void> complete();
}
