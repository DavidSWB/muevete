import 'package:flutter/material.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/widgets/panel/exercise_tile.dart';

class ExerciseList extends StatelessWidget {
  const ExerciseList({
    super.key,
    required this.exercises,
  });

  final List<WorkoutExercise> exercises;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(

      padding: const EdgeInsets.fromLTRB(
        24,
        26,
        24,
        32,
      ),

      sliver: SliverList.builder(
        itemCount: exercises.length,
        itemBuilder: (_, index) {
        return ExerciseTile(
          exercise: exercises[index]
        );
      },
      ),



    );
  }
}