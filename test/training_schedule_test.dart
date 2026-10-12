import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/services/training_schedule_service.dart';

void main() {
  const scheduleService = TrainingScheduleService();

  final testPlan = TrainingPlan(
    planId: 'plan_3d_test',
    name: const {'en': '3-Day Test Plan', 'es': 'Plan 3 Días'},
    description: const {'en': 'Test Description', 'es': 'Descripción Test'},
    daysPerWeek: 3,
    template: const [
      PlanDay(
        day: 1,
        name: {'en': 'Lower Body', 'es': 'Pierna'},
        exercises: [],
      ),
      PlanDay(
        day: 2,
        name: {'en': 'Upper Body', 'es': 'Torso'},
        exercises: [],
      ),
      PlanDay(
        day: 3,
        name: {'en': 'Full Body', 'es': 'Cuerpo Completo'},
        exercises: [],
      ),
    ],
  );

  // Helper date generators for deterministic weekdays:
  // 2026-10-12 is Monday (weekday 1)
  // 2026-10-13 is Tuesday (weekday 2)
  // 2026-10-14 is Wednesday (weekday 3)
  // 2026-10-15 is Thursday (weekday 4)
  // 2026-10-16 is Friday (weekday 5)
  // 2026-10-17 is Saturday (weekday 6)
  // 2026-10-18 is Sunday (weekday 7)
  final mondayDate = DateTime(2026, 10, 12, 10, 0);
  final tuesdayDate = DateTime(2026, 10, 13, 10, 0);
  final wednesdayDate = DateTime(2026, 10, 14, 10, 0);
  final thursdayDate = DateTime(2026, 10, 15, 10, 0);
  final fridayDate = DateTime(2026, 10, 16, 10, 0);
  final saturdayDate = DateTime(2026, 10, 17, 10, 0);
  final sundayDate = DateTime(2026, 10, 18, 10, 0);

  group('UserSchedule Parsing and Serialization', () {
    test('1. A schedule stored using canonical weekday-name keys loads correctly', () {
      final json = {
        'monday': 1,
        'tuesday': null,
        'wednesday': 2,
        'thursday': null,
        'friday': 3,
        'saturday': null,
        'sunday': null,
        'preferredTime': '18:00',
      };

      final schedule = UserSchedule.fromJson(json);

      expect(schedule.days, {1: 1, 3: 2, 5: 3});
      expect(schedule.preferredTime, '18:00');
    });

    test('2. A legacy numeric-key schedule loads correctly', () {
      final json = {
        '1': 1,
        '3': 2,
        '5': 3,
        'preferredTime': '18:00',
      };

      final schedule = UserSchedule.fromJson(json);

      expect(schedule.days, {1: 1, 3: 2, 5: 3});
      expect(schedule.preferredTime, '18:00');
    });

    test('3. Serialization preserves the canonical Firestore-compatible structure', () {
      const schedule = UserSchedule(
        days: {1: 1, 3: 2, 5: 3},
        preferredTime: '18:00',
      );

      final json = schedule.toJson();

      expect(json, {
        'monday': 1,
        'tuesday': null,
        'wednesday': 2,
        'thursday': null,
        'friday': 3,
        'saturday': null,
        'sunday': null,
        'preferredTime': '18:00',
      });

      // Round-trip verification
      final restored = UserSchedule.fromJson(json);
      expect(restored, schedule);

      // Verify null preferredTime is omitted or handled properly
      const scheduleNoTime = UserSchedule(days: {1: 1});
      final jsonNoTime = scheduleNoTime.toJson();
      expect(jsonNoTime.containsKey('preferredTime'), isFalse);
      expect(UserSchedule.fromJson(jsonNoTime).preferredTime, isNull);
    });
  });

  group('Next Workout Selection and Schedule Rules', () {
    // Schedule from prompt example:
    // Monday (1) -> Upper Body (plan day 2)
    // Wednesday (3) -> Lower Body (plan day 1)
    // Friday (5) -> Full Body (plan day 3)
    const schedule = UserSchedule(
      days: {1: 2, 3: 1, 5: 3},
      preferredTime: '18:00',
    );

    UserModel createUser({List<DateTime> completedWorkouts = const []}) {
      return UserModel(
        id: 'user-1',
        email: 'test@example.com',
        username: 'tester',
        completedWorkouts: completedWorkouts,
        training: UserTraining(
          activePlanId: testPlan.planId,
          planStartDate: DateTime(2026, 10, 1),
          schedule: schedule,
        ),
      );
    }

    test('4. A scheduled weekday resolves to the correct plan session', () {
      final user = createUser();

      final mondayWorkout = scheduleService.getNextTrainingDay(
        user: user,
        plan: testPlan,
        now: mondayDate,
      );
      expect(mondayWorkout.day, 2);
      expect(mondayWorkout.name['en'], 'Upper Body');

      final wednesdayWorkout = scheduleService.getNextTrainingDay(
        user: user,
        plan: testPlan,
        now: wednesdayDate,
      );
      expect(wednesdayWorkout.day, 1);
      expect(wednesdayWorkout.name['en'], 'Lower Body');

      final fridayWorkout = scheduleService.getNextTrainingDay(
        user: user,
        plan: testPlan,
        now: fridayDate,
      );
      expect(fridayWorkout.day, 3);
      expect(fridayWorkout.name['en'], 'Full Body');
    });

    test('5. Completing a workout does not advance the assigned session for the current day', () {
      final userBefore = createUser(completedWorkouts: []);
      final nextBefore = scheduleService.getNextTrainingDay(
        user: userBefore,
        plan: testPlan,
        now: mondayDate,
      );
      expect(nextBefore.name['en'], 'Upper Body');

      // User finishes the Upper Body workout today
      final userAfter = createUser(completedWorkouts: [mondayDate]);
      final nextAfter = scheduleService.getNextTrainingDay(
        user: userAfter,
        plan: testPlan,
        now: mondayDate,
      );
      expect(nextAfter.name['en'], 'Upper Body');
    });

    test('6. Completing an active break increments Home Completed count but does not change Next Workout', () {
      final userBefore = createUser(completedWorkouts: [mondayDate]);
      final nextBefore = scheduleService.getNextTrainingDay(
        user: userBefore,
        plan: testPlan,
        now: mondayDate,
      );
      expect(userBefore.completedWorkouts.length, 1);
      expect(nextBefore.name['en'], 'Upper Body');

      // Finish an active break
      final userAfterActiveBreak = userBefore.copyWith(
        completedWorkouts: [...userBefore.completedWorkouts, mondayDate.add(const Duration(hours: 2))],
      );
      final nextAfter = scheduleService.getNextTrainingDay(
        user: userAfterActiveBreak,
        plan: testPlan,
        now: mondayDate,
      );

      // Completed activity count must increment
      expect(userAfterActiveBreak.completedWorkouts.length, 2);
      // Next workout must remain the scheduled session
      expect(nextAfter.name['en'], 'Upper Body');
    });

    test('7. A non-training day resolves to the next upcoming scheduled session', () {
      final user = createUser();

      // Tuesday (day 2) is a rest day; next scheduled day is Wednesday (Lower Body)
      final tuesdayWorkout = scheduleService.getNextTrainingDay(
        user: user,
        plan: testPlan,
        now: tuesdayDate,
      );
      expect(tuesdayWorkout.day, 1);
      expect(tuesdayWorkout.name['en'], 'Lower Body');

      // Thursday (day 4) is a rest day; next scheduled day is Friday (Full Body)
      final thursdayWorkout = scheduleService.getNextTrainingDay(
        user: user,
        plan: testPlan,
        now: thursdayDate,
      );
      expect(thursdayWorkout.day, 3);
      expect(thursdayWorkout.name['en'], 'Full Body');
    });

    test('8. The schedule wraps correctly from Sunday to Monday', () {
      final user = createUser();

      // Saturday (day 6) wraps around to Monday (Upper Body)
      final saturdayWorkout = scheduleService.getNextTrainingDay(
        user: user,
        plan: testPlan,
        now: saturdayDate,
      );
      expect(saturdayWorkout.day, 2);
      expect(saturdayWorkout.name['en'], 'Upper Body');

      // Sunday (day 7) wraps around to Monday (Upper Body)
      final sundayWorkout = scheduleService.getNextTrainingDay(
        user: user,
        plan: testPlan,
        now: sundayDate,
      );
      expect(sundayWorkout.day, 2);
      expect(sundayWorkout.name['en'], 'Upper Body');
    });

    test('9. Weekday selection order does not change the session assignment', () {
      // Simulate user tapping Friday (5) first, then Monday (1), then Wednesday (3)
      final tappedOrder = [5, 1, 3];
      final sortedWeekdays = tappedOrder.toList()..sort();
      final scheduleMap = <int, int>{};
      for (int i = 0; i < sortedWeekdays.length; i++) {
        scheduleMap[sortedWeekdays[i]] = i + 1;
      }

      expect(scheduleMap, {
        1: 1, // Monday -> session 1
        3: 2, // Wednesday -> session 2
        5: 3, // Friday -> session 3
      });

      // Two-day plan selection: Thursday (4) first, then Monday (1)
      final twoDayTappedOrder = [4, 1];
      final twoDaySorted = twoDayTappedOrder.toList()..sort();
      final twoDaySchedule = <int, int>{};
      for (int i = 0; i < twoDaySorted.length; i++) {
        twoDaySchedule[twoDaySorted[i]] = i + 1;
      }

      expect(twoDaySchedule, {
        1: 1, // Monday -> plan day 1
        4: 2, // Thursday -> plan day 2
      });
    });

    test('10. Missing or incomplete schedule data is handled safely without crashes', () {
      // User without training
      final userNoTraining = const UserModel(
        id: 'no-training',
        email: 'none@example.com',
        username: 'none',
      );
      final workoutNoTraining = scheduleService.getNextTrainingDay(
        user: userNoTraining,
        plan: testPlan,
        now: mondayDate,
      );
      expect(workoutNoTraining.day, testPlan.template.first.day);

      // User with null schedule
      final userNullSchedule = UserModel(
        id: 'null-schedule',
        email: 'none@example.com',
        username: 'none',
        training: UserTraining(
          activePlanId: testPlan.planId,
          planStartDate: DateTime(2026, 10, 1),
          schedule: null,
        ),
      );
      final workoutNullSchedule = scheduleService.getNextTrainingDay(
        user: userNullSchedule,
        plan: testPlan,
        now: mondayDate,
      );
      expect(workoutNullSchedule.day, testPlan.template.first.day);

      // User with empty schedule days
      final userEmptySchedule = UserModel(
        id: 'empty-schedule',
        email: 'none@example.com',
        username: 'none',
        training: UserTraining(
          activePlanId: testPlan.planId,
          planStartDate: DateTime(2026, 10, 1),
          schedule: const UserSchedule(days: {}),
        ),
      );
      final workoutEmptySchedule = scheduleService.getNextTrainingDay(
        user: userEmptySchedule,
        plan: testPlan,
        now: mondayDate,
      );
      expect(workoutEmptySchedule.day, testPlan.template.first.day);

      // Parsing empty or incomplete json
      final emptySchedule = UserSchedule.fromJson({});
      expect(emptySchedule.days, isEmpty);
      expect(emptySchedule.preferredTime, isNull);

      final nullDaysJson = {
        'monday': null,
        'tuesday': null,
        'wednesday': null,
        'thursday': null,
        'friday': null,
        'saturday': null,
        'sunday': null,
      };
      final nullDaysSchedule = UserSchedule.fromJson(nullDaysJson);
      expect(nullDaysSchedule.days, isEmpty);
    });
  });
}
