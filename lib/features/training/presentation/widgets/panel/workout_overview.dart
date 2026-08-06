import 'package:flutter/material.dart';
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
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.name['en'] ?? 'Workout name',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
   
          SizedBox(height: 24,),
          
          Text("${workout.exercises.length} exercises"),
        ],
      ),
    );
  }
}