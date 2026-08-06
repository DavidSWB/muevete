import 'package:muevete/features/profile/domain/entities/user_model.dart';
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

  int calculateTrainingDay({
    required UserModel user,
    required TrainingPlan plan,
  }) {
    final completed = _completedThisWeek(
      workouts: user.completedWorkouts,
    );

    if (completed >= plan.daysPerWeek) {
      return plan.daysPerWeek;
    }

    return completed + 1;
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