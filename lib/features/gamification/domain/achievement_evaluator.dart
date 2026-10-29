import 'package:muevete/features/gamification/domain/achievement.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';

/// Which badges a user has earned but not yet been given. Counts use only
/// history that is known to be right, so a badge is never given early.
class AchievementEvaluator {
  const AchievementEvaluator();

  /// Ids from [catalogue] that [user] has earned and that are not in
  /// [UserModel.unlockedBadgeIds]. [walkthroughCompleted] is whether the
  /// tour is completed for this user on this device.
  Set<String> newlyEarned({
    required List<Achievement> catalogue,
    required UserModel user,
    required bool walkthroughCompleted,
  }) {
    final owned = user.unlockedBadgeIds.toSet();
    return {
      for (final achievement in catalogue)
        if (!owned.contains(achievement.achievementId) &&
            _isMet(achievement.condition, user, walkthroughCompleted))
          achievement.achievementId,
    };
  }

  bool _isMet(
    AchievementCondition condition,
    UserModel user,
    bool walkthroughCompleted,
  ) => switch (condition) {
    CompletionCountCondition(:final kind, :final count) =>
      count > 0 && countCompletions(user, kind) >= count,
    WalkthroughCompletedCondition() => walkthroughCompleted,
    UnknownCondition() => false,
  };

  /// Active breaks always have their own history. Before
  /// [UserModel.consistencyTrackedSince], active breaks were also written to
  /// `completedWorkouts`, so only workouts from that moment on count; with
  /// no such moment, none do until the next one is recorded.
  static int countCompletions(UserModel user, CountedActivity kind) {
    switch (kind) {
      case CountedActivity.activeBreaks:
        return user.completedActiveBreaks.length;
      case CountedActivity.workouts:
        final since = user.consistencyTrackedSince;
        if (since == null) return 0;
        return user.completedWorkouts
            .where((date) => !date.isBefore(since))
            .length;
    }
  }
}
