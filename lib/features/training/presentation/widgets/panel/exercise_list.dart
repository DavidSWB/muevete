import 'package:flutter/material.dart';
import 'package:muevete/features/training/domain/entities/exercise_sequence.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/widgets/panel/exercise_tile.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';

class ExerciseList extends StatelessWidget {
  const ExerciseList({super.key, required this.exercises, this.firstAnchorId});

  final List<WorkoutExercise> exercises;

  /// Walkthrough anchor id for the first exercise, if the tour points at it.
  final String? firstAnchorId;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      sliver: SliverList.builder(
        itemCount: exercises.length,
        itemBuilder: (_, index) {
          final tile = ExerciseTile(
            exercise: exercises[index],
            sequence: ExerciseSequence(exercises, index),
          );
          final anchorId = firstAnchorId;
          return index == 0 && anchorId != null
              ? WalkthroughAnchor(id: anchorId, child: tile)
              : tile;
        },
      ),
    );
  }
}
