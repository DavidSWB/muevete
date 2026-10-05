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
  }) {
    final schedule = user.training?.schedule;
    if (schedule == null || schedule.days.isEmpty) {
      final completed = user.completedWorkouts
          .where(
            (date) =>
                !date.isBefore(user.training!.planStartDate),
          )
          .length;

      final dayNumber = (completed % plan.daysPerWeek) + 1;

      return plan.template.firstWhere(
        (day) => day.day == dayNumber,
      );
    }

    final now = DateTime.now();
    int currentWeekday = now.weekday;

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

  int _completedThisWeek({
    required List<DateTime> workouts,
  }) {
    final now = DateTime.now();

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(days: now.weekday - 1),
    );

    final sunday = monday.add(const Duration(days: 7));

    return workouts.where((date) {
      return !date.isBefore(monday) && date.isBefore(sunday);
    }).length;
  }
}
