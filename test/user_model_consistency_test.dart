import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';

void main() {
  test('a legacy document without the new fields still loads', () {
    final user = UserModel.fromJson(
      id: 'u1',
      json: {
        'email': 'user@example.com',
        'username': 'user',
        'completedWorkouts': ['2026-10-22T13:41:21.096405'],
      },
    );

    expect(user.completedWorkouts, [
      DateTime(2026, 10, 22, 13, 41, 21, 96, 405),
    ]);
    expect(user.completedActiveBreaks, isEmpty);
    expect(user.streak, isNull);
    expect(user.consistencyTrackedSince, isNull);
  });

  test('a document without any activity lists loads with empty lists', () {
    final user = UserModel.fromJson(
      id: 'u1',
      json: {'email': 'a', 'username': 'b'},
    );
    expect(user.completedWorkouts, isEmpty);
    expect(user.completedActiveBreaks, isEmpty);
  });

  test('reads the consistency fields', () {
    final user = UserModel.fromJson(
      id: 'u1',
      json: {
        'email': 'user@example.com',
        'username': 'user',
        'completedWorkouts': ['2026-10-22T13:41:21.096405'],
        'completedActiveBreaks': [
          '2026-10-24T10:05:12.481220',
          Timestamp.fromDate(DateTime(2026, 10, 25, 16)),
        ],
        'streak': {
          'current': 4,
          'longest': 4,
          'lastActiveDate': '2026-10-25',
          'timeZone': 'America/Bogota',
        },
        'consistencyTrackedSince': '2026-10-25T00:00:00.000',
      },
    );

    expect(user.completedActiveBreaks, hasLength(2));
    expect(
      user.streak,
      UserStreak(
        current: 4,
        longest: 4,
        lastActiveDate: DateTime(2026, 10, 25),
        timeZone: 'America/Bogota',
      ),
    );
    expect(user.consistencyTrackedSince, DateTime(2026, 10, 25));
  });

  test('skips unreadable entries instead of failing the whole profile', () {
    final user = UserModel.fromJson(
      id: 'u1',
      json: {
        'email': 'a',
        'username': 'b',
        'completedWorkouts': ['not a date', '2026-10-22T13:41:21', 42],
      },
    );
    expect(user.completedWorkouts, [DateTime(2026, 10, 22, 13, 41, 21)]);
  });

  test('profile saves never carry activity fields', () {
    final user = UserModel(
      id: 'u1',
      email: 'a',
      username: 'b',
      completedWorkouts: [DateTime(2026, 10, 22)],
      completedActiveBreaks: [DateTime(2026, 10, 23)],
      streak: const UserStreak(current: 1, longest: 1),
      consistencyTrackedSince: DateTime(2026, 10, 25),
    );

    final json = user.toJson();
    expect(json.containsKey('completedWorkouts'), isFalse);
    expect(json.containsKey('completedActiveBreaks'), isFalse);
    expect(json.containsKey('streak'), isFalse);
    expect(json.containsKey('consistencyTrackedSince'), isFalse);
    expect(json['email'], 'a');
  });

  test('streak round-trips through JSON', () {
    final streak = UserStreak(
      current: 2,
      longest: 5,
      lastActiveDate: DateTime(2026, 1, 9),
      timeZone: 'America/Bogota',
    );
    expect(streak.toJson()['lastActiveDate'], '2026-01-09');
    expect(UserStreak.fromJson(streak.toJson()), streak);
  });
}
