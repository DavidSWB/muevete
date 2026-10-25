import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/services/streak_calculator.dart';

void main() {
  const calculator = StreakCalculator();
  final today = DateTime(2026, 10, 25, 12);

  UserStreak streakOf(List<DateTime> completions) => calculator.fromHistory(
    completions,
    today: today,
    timeZone: 'America/Bogota',
  );

  test('no history gives an empty streak', () {
    final streak = streakOf([]);
    expect(streak.current, 0);
    expect(streak.longest, 0);
    expect(streak.lastActiveDate, isNull);
    expect(streak.timeZone, 'America/Bogota');
  });

  test('first completion counts today right away', () {
    final streak = streakOf([DateTime(2026, 10, 25, 9)]);
    expect(streak.current, 1);
    expect(streak.lastActiveDate, DateTime(2026, 10, 25));
  });

  test('several completions on one day count once', () {
    final streak = streakOf([
      DateTime(2026, 10, 25, 8),
      DateTime(2026, 10, 25, 8),
      DateTime(2026, 10, 25, 17),
    ]);
    expect(streak.current, 1);
    expect(streak.longest, 1);
  });

  test('consecutive days add up, in any order', () {
    final streak = streakOf([
      DateTime(2026, 10, 25, 7),
      DateTime(2026, 10, 23, 20),
      DateTime(2026, 10, 24, 6),
    ]);
    expect(streak.current, 3);
    expect(streak.longest, 3);
  });

  test('a missed day restarts the run and keeps the longest', () {
    final streak = streakOf([
      DateTime(2026, 10, 18),
      DateTime(2026, 10, 19),
      DateTime(2026, 10, 20),
      DateTime(2026, 10, 22),
      DateTime(2026, 10, 23),
    ]);
    expect(streak.current, 2);
    expect(streak.longest, 3);
    expect(streak.lastActiveDate, DateTime(2026, 10, 23));
  });

  test('returning after a long break starts at 1', () {
    final streak = streakOf([DateTime(2026, 9, 1), DateTime(2026, 10, 25)]);
    expect(streak.current, 1);
    expect(streak.longest, 1);
  });

  test('future-dated entries are ignored', () {
    final streak = streakOf([DateTime(2026, 10, 25), DateTime(2026, 10, 26)]);
    expect(streak.current, 1);
    expect(streak.lastActiveDate, DateTime(2026, 10, 25));
  });

  test('runs cross month and year boundaries', () {
    final streak = calculator.fromHistory([
      DateTime(2026, 12, 30),
      DateTime(2026, 12, 31),
      DateTime(2027, 1, 1),
    ], today: DateTime(2027, 1, 1));
    expect(streak.current, 3);
  });

  test('late evening and early morning fall on different days', () {
    final streak = streakOf([
      DateTime(2026, 10, 24, 23, 59),
      DateTime(2026, 10, 25, 0, 1),
    ]);
    expect(streak.current, 2);
  });

  group('liveCurrent', () {
    final streak = UserStreak(
      current: 4,
      longest: 6,
      lastActiveDate: DateTime(2026, 10, 24),
    );

    test('is the stored value when the last day was today or yesterday', () {
      expect(calculator.liveCurrent(streak, DateTime(2026, 10, 24, 22)), 4);
      expect(calculator.liveCurrent(streak, DateTime(2026, 10, 25, 9)), 4);
    });

    test('is 0 once a whole day has been missed', () {
      expect(calculator.liveCurrent(streak, DateTime(2026, 10, 26)), 0);
      expect(calculator.liveCurrent(UserStreak.empty, today), 0);
    });
  });
}
