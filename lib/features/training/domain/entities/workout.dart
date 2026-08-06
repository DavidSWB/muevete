import 'package:muevete/features/training/domain/entities/workout_exercise.dart';

class Workout {
  final List<WorkoutExercise> exercises;
  final int day;
  final Map<String, String> name;

  const Workout({
    required this.exercises,
    required this.day,
    required this.name,

  });
}