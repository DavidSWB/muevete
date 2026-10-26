import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/training/domain/services/training_schedule_service.dart';

void main() {
  const service = TrainingScheduleService();

  // 2026-10-12 is a Monday.
  final monday = DateTime(2026, 10, 12, 9);
  final tuesday = DateTime(2026, 10, 13, 9);
  final wednesday = DateTime(2026, 10, 14, 9);
  final friday = DateTime(2026, 10, 16, 9);
  final saturday = DateTime(2026, 10, 17, 9);
  final nextMonday = DateTime(2026, 10, 19, 9);

  UserModel user({
    Map<int, int>? days = const {1: 1, 3: 2, 5: 3},
    List<DateTime> completedWorkouts = const [],
    DateTime? trackedSince,
    bool withTraining = true,
  }) {
    return UserModel(
      id: 'u',
      email: 'u@example.com',
      username: 'u',
      training: withTraining
          ? UserTraining(
              activePlanId: 'plan',
              planStartDate: DateTime(2026, 10, 1),
              schedule: days == null ? null : UserSchedule(days: days),
            )
          : null,
      completedWorkouts: completedWorkouts,
      consistencyTrackedSince: trackedSince,
    );
  }

  group('isRestDay', () {
    test('a scheduled weekday is not a rest day', () {
      expect(service.isRestDay(user: user(), now: monday), isFalse);
      expect(service.isRestDay(user: user(), now: friday), isFalse);
    });

    test('an unscheduled weekday is a rest day', () {
      expect(service.isRestDay(user: user(), now: tuesday), isTrue);
      expect(service.isRestDay(user: user(), now: saturday), isTrue);
    });

    test('missing training or schedule is never a rest day', () {
      expect(
        service.isRestDay(user: user(withTraining: false), now: tuesday),
        isFalse,
      );
      expect(service.isRestDay(user: user(days: null), now: tuesday), isFalse);
      expect(
        service.isRestDay(
          user: user(days: {}),
          now: tuesday,
        ),
        isFalse,
      );
    });
  });

  group('wasDoneEarly', () {
    test('a workout on the rest day before marks today as done early', () {
      final u = user(completedWorkouts: [DateTime(2026, 10, 13, 18)]);
      expect(service.wasDoneEarly(user: u, now: wednesday), isTrue);
    });

    test('a workout on the previous training day does not count', () {
      final u = user(completedWorkouts: [DateTime(2026, 10, 12, 18)]);
      expect(service.wasDoneEarly(user: u, now: wednesday), isFalse);
    });

    test('a workout done today does not count as early', () {
      final u = user(completedWorkouts: [DateTime(2026, 10, 14, 7)]);
      expect(service.wasDoneEarly(user: u, now: wednesday), isFalse);
    });

    test('is false on a rest day', () {
      final u = user(completedWorkouts: [DateTime(2026, 10, 13, 8)]);
      expect(service.wasDoneEarly(user: u, now: tuesday), isFalse);
    });

    test('looks back across the weekend to the previous week', () {
      final u = user(completedWorkouts: [DateTime(2026, 10, 18, 11)]);
      expect(service.wasDoneEarly(user: u, now: nextMonday), isTrue);
    });

    test('a single training day looks back a full week', () {
      final u = user(
        days: {1: 1},
        completedWorkouts: [DateTime(2026, 10, 14, 11)],
      );
      expect(service.wasDoneEarly(user: u, now: nextMonday), isTrue);

      final lastMonday = user(
        days: {1: 1},
        completedWorkouts: [DateTime(2026, 10, 12, 11)],
      );
      expect(service.wasDoneEarly(user: lastMonday, now: nextMonday), isFalse);
    });

    test('ignores entries from before separate tracking began', () {
      final u = user(
        completedWorkouts: [DateTime(2026, 10, 13, 18)],
        trackedSince: DateTime(2026, 10, 14),
      );
      expect(service.wasDoneEarly(user: u, now: wednesday), isFalse);
    });

    test('is false without a schedule', () {
      final u = user(
        days: null,
        completedWorkouts: [DateTime(2026, 10, 13, 18)],
      );
      expect(service.wasDoneEarly(user: u, now: wednesday), isFalse);
    });
  });
}
