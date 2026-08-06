import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:muevete/features/training/presentation/widgets/hero/workout_hero.dart';
import 'package:muevete/features/training/presentation/widgets/panel/workout_sliding_panel.dart';
import 'package:muevete/shared/screens/loading_screen.dart';

class TrainingScreen extends ConsumerWidget {

  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final workoutAsync =
        ref.watch(workoutControllerProvider);

    return workoutAsync.when(

      data: (workout) {

        return Scaffold(

          body: Stack(

            children: [

              WorkoutHero(workout: workout),
              
              WorkoutSlidingPanel(workout: workout),

            ],

          ),

        );

      },

      loading: () =>
          const LoadingScreen(),

      error: (error, stack) {
        print("ERROR: " );
        print(error);
        print(stack);

        return Scaffold(
          body: Center(
            child: Text(error.toString()),
          ),
        );
      }
    );

  }

}