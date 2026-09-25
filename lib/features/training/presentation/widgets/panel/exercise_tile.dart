import 'package:flutter/material.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/screens/exercise_detail_screen.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    super.key,
    required this.exercise,
  });

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exercise: exercise,
        ),
      ),
    );  
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _Thumbnail(exercisePicture: exercise.exercise.visualPath),
            const SizedBox(width: 16),
            Expanded(
              child: _ExerciseInfo(exercise: exercise),
            ),
            const SizedBox(width: 16),
            const _Chevron(),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.exercisePicture,
  });

  final String exercisePicture;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(exercisePicture),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ExerciseInfo extends StatelessWidget {
  const _ExerciseInfo({
    required this.exercise,
  });

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          exercise.exercise.name['en'] ?? 'Exercise name',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${exercise.reps} reps',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(height: 8),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.chevron_right);
  }
}