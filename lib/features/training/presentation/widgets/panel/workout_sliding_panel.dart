import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:muevete/features/training/presentation/widgets/panel/exercise_list.dart';
import 'package:muevete/features/training/presentation/widgets/panel/workout_overview.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class WorkoutSlidingPanel extends StatelessWidget {
  const WorkoutSlidingPanel({
    super.key,
    required this.workout,
    required this.onWorkoutFinished,
  });

  final Workout workout;
  final VoidCallback onWorkoutFinished;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .62,
      minChildSize: .62,
      maxChildSize: .92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.softGrey,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [

              const SliverToBoxAdapter(
                child: _DragHandle(),
              ),

              SliverToBoxAdapter(
                child: WorkoutOverview(
                  workout: workout,
                ),
              ),

              const SliverToBoxAdapter(
                child: Divider(height: 1),
              ),

              ExerciseList(
                exercises: workout.exercises,
              ),

            SliverToBoxAdapter(
              child: _FinishWorkoutButton(
                onWorkoutFinished: onWorkoutFinished,
              ),
            ),
              

            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(999)
          ),
        ),
      ),
    );
  }
}

class _FinishWorkoutButton extends ConsumerWidget {
  const _FinishWorkoutButton({
    required this.onWorkoutFinished,
  });

  final VoidCallback onWorkoutFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await ref
                .read(workoutControllerProvider.notifier)
                .finishWorkout();
            
            onWorkoutFinished();
          },
          child: const Text('Finish Workout'),
        ),
      ),
    );
  }
}