import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';

/// The sets marked as completed in one workout, by exercise index, so they
/// survive moving between exercises. Keyed by the workout's exercise list:
/// a newly built workout starts with nothing ticked.
final workoutSetProgressProvider = NotifierProvider.autoDispose
    .family<WorkoutSetProgress, Map<int, Set<int>>, List<WorkoutExercise>>(
      WorkoutSetProgress.new,
    );

class WorkoutSetProgress extends Notifier<Map<int, Set<int>>> {
  WorkoutSetProgress(this.exercises);

  final List<WorkoutExercise> exercises;

  @override
  Map<int, Set<int>> build() => const {};

  Set<int> completedSets(int exerciseIndex) =>
      state[exerciseIndex] ?? const <int>{};

  void setCompleted(int exerciseIndex, Set<int> setIndexes) {
    state = {...state, exerciseIndex: Set.unmodifiable(setIndexes)};
  }

  /// What Finish Workout reports for rewards.
  CompletedWorkout summary() => CompletedWorkout([
    for (var i = 0; i < exercises.length; i++)
      CompletedExercise(
        targets: exercises[i].targets,
        completedSets: completedSets(i).length,
        prescribedSets: exercises[i].sets,
      ),
  ]);
}
