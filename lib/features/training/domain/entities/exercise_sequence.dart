import 'package:muevete/features/training/domain/entities/workout_exercise.dart';

/// The exercises of one workout and the position of the one being shown,
/// so the exercise screen can offer the next exercise in order.
class ExerciseSequence {
  ExerciseSequence(this.exercises, this.index)
      : assert(index >= 0 && index < exercises.length);

  final List<WorkoutExercise> exercises;
  final int index;

  WorkoutExercise get current => exercises[index];

  bool get hasNext => index < exercises.length - 1;

  ExerciseSequence next() {
    if (!hasNext) {
      throw StateError('No exercise after index $index');
    }
    return ExerciseSequence(exercises, index + 1);
  }
}
