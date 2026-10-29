import 'package:muevete/features/training/domain/entities/exercise_variant.dart';

class WorkoutExercise {
  final ExerciseVariant exercise;
  final int sets;
  final int? reps;
  final int rest;
  final int? duration;

  /// The joints the exercise works, from its definition.
  final List<String> targets;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.reps,
    required this.rest,
    this.duration,
    this.targets = const [],
  });

}