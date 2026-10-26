import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';

class TrainingScheduleService {
  const TrainingScheduleService();

  int calculateCurrentWeek({
    required UserModel user,
  }) {
    final start = user.training!.planStartDate;
    final now = DateTime.now();

    final difference = now.difference(start).inDays;

    return (difference ~/ 7) + 1;
  }


  PlanDay getNextTrainingDay({
    required UserModel user,
    required TrainingPlan plan,
    DateTime? now,
  }) {
    final schedule = user.training?.schedule;
    if (schedule == null || schedule.days.isEmpty) {
      return plan.template.first;
    }

    final currentDateTime = now ?? DateTime.now();
    int currentWeekday = currentDateTime.weekday;

    for (int offset = 0; offset < 7; offset++) {
      int checkDay = currentWeekday + offset;
      if (checkDay > 7) checkDay -= 7;

      final planDayNum = schedule.days[checkDay];
      if (planDayNum != null) {
        return plan.template.firstWhere(
          (d) => d.day == planDayNum,
          orElse: () => plan.template.first,
        );
      }
    }

    return plan.template.first;
  }

  /// True only when the user has a schedule with at least one training day
  /// and [now]'s weekday is not one of them. A missing or empty schedule is
  /// never a rest day, so Home keeps showing the workout.
  bool isRestDay({
    required UserModel user,
    DateTime? now,
  }) {
    final schedule = user.training?.schedule;
    if (schedule == null || schedule.days.isEmpty) return false;

    final today = now ?? DateTime.now();
    return !schedule.days.containsKey(today.weekday);
  }

  /// True when today is a training day and its session was already done on
  /// a rest day since the previous training day.
  ///
  /// On a rest day the only workout offered is the next scheduled session
  /// (see [getNextTrainingDay]), so a workout completed between the previous
  /// training day and today was today's session, done early. Nothing is
  /// stored for this; it is derived from [UserModel.completedWorkouts].
  bool wasDoneEarly({
    required UserModel user,
    DateTime? now,
  }) {
    final schedule = user.training?.schedule;
    if (schedule == null || schedule.days.isEmpty) return false;

    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    if (!schedule.days.containsKey(today.weekday)) return false;

    // The previous training day, 1 to 7 days back (7 when today is the only
    // training day of the week).
    // Built from calendar fields, not Durations, so DST changes don't shift
    // the dates.
    var daysBack = 1;
    while (!schedule.days.containsKey(
      DateTime(today.year, today.month, today.day - daysBack).weekday,
    )) {
      daysBack++;
    }
    final afterPrevious =
        DateTime(today.year, today.month, today.day - daysBack + 1);

    // Older entries may also hold active breaks.
    final trackedSince = user.consistencyTrackedSince;

    return user.completedWorkouts.any((completedAt) {
      if (trackedSince != null && completedAt.isBefore(trackedSince)) {
        return false;
      }
      return !completedAt.isBefore(afterPrevious) &&
          completedAt.isBefore(today);
    });
  }

  List<int> getRecoveryConflicts(Map<int, int> scheduleDays, TrainingPlan plan) {
    final conflicts = <int>[];
    for (int weekday = 1; weekday <= 7; weekday++) {
      final currentPlanDayNum = scheduleDays[weekday];
      if (currentPlanDayNum == null) continue;

      final currentPlanDay = plan.template.firstWhere(
        (d) => d.day == currentPlanDayNum,
        orElse: () => plan.template.first,
      );
      if (currentPlanDay.recoveryGroups.isEmpty) continue;

      int prevWeekday = weekday - 1;
      if (prevWeekday == 0) prevWeekday = 7;

      final prevPlanDayNum = scheduleDays[prevWeekday];
      if (prevPlanDayNum != null) {
        final prevPlanDay = plan.template.firstWhere(
          (d) => d.day == prevPlanDayNum,
          orElse: () => plan.template.first,
        );
        final hasSharedGroup = currentPlanDay.recoveryGroups
            .any((g) => prevPlanDay.recoveryGroups.contains(g));
        if (hasSharedGroup) {
          conflicts.add(weekday);
        }
      }
    }
    return conflicts;
  }
}
