import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/gamification/domain/reward_rules.dart';

/// Movement XP and joint points for completions. XP is motivational only:
/// nothing here changes the stats that choose exercise variants.
class RewardCalculator {
  const RewardCalculator(this.rules);

  final RewardRules rules;

  /// XP for the sets actually completed, up to [RewardRules.workoutXpMax],
  /// and points for each target joint. Only the first
  /// [RewardRules.workoutRewardsPerDay] workouts of a local day count.
  ActivityReward forWorkout({
    required CompletedWorkout workout,
    required DateTime completedAt,
    required List<DateTime> earlierWorkouts,
  }) {
    if (_sameDay(earlierWorkouts, completedAt) >= rules.workoutRewardsPerDay) {
      return ActivityReward.none;
    }

    final xp = (workout.completedSets * rules.workoutXpPerSet).clamp(
      0,
      rules.workoutXpMax,
    );
    final points = <String, int>{};
    for (final exercise in workout.exercises) {
      final sets = exercise.completedSets.clamp(0, exercise.prescribedSets);
      if (sets == 0) continue;
      for (final joint in exercise.targets.toSet()) {
        if (!progressionJoints.contains(joint)) continue;
        points[joint] = (points[joint] ?? 0) + sets * rules.jointPointsPerSet;
      }
    }
    points.removeWhere((_, value) => value == 0);
    return ActivityReward(xp: xp, jointPoints: points);
  }

  /// Flat XP, no joint points: a break's exercises are not checked one by
  /// one, so they cannot be credited to joints reliably.
  ActivityReward forActiveBreak({
    required DateTime completedAt,
    required List<DateTime> earlierActiveBreaks,
  }) {
    if (_sameDay(earlierActiveBreaks, completedAt) >=
        rules.activeBreakRewardsPerDay) {
      return ActivityReward.none;
    }
    return ActivityReward(xp: rules.activeBreakXp);
  }

  static int _sameDay(List<DateTime> history, DateTime day) => history
      .where(
        (date) =>
            date.year == day.year &&
            date.month == day.month &&
            date.day == day.day,
      )
      .length;
}
