import 'package:flutter/material.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';

class WorkoutOverview extends StatelessWidget {
  final Workout workout;

  const WorkoutOverview({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.name.localized(context, fallback: 'Workout name'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
   
          const SizedBox(height: 24),
          
          Text("${workout.exercises.length} exercises"),
        ],
      ),
    );
  }
}