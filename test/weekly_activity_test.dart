import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/services/weekly_activity.dart';

void main() {
  // 2026-10-26 is a Monday.
  final monday = DateTime(2026, 10, 26);

  group('startOfWeek', () {
    test('is Monday 00:00 for every day of the week', () {
      for (var day = 0; day < 7; day++) {
        expect(
          startOfWeek(DateTime(2026, 10, 26 + day, 23, 59)),
          monday,
          reason: 'day $day',
        );
      }
    });

    test('Monday 00:00 starts a new week', () {
      expect(startOfWeek(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    });

    test('lands on midnight across a daylight-saving change', () {
      // In zones that observe it, this week contains a DST change; calendar
      // arithmetic still lands on a local midnight.
      final start = startOfWeek(DateTime(2026, 3, 13, 12));
      expect(start, DateTime(2026, 3, 9));
      expect((start.hour, start.minute), (0, 0));

      final autumn = startOfWeek(DateTime(2026, 11, 7, 12));
      expect(autumn, DateTime(2026, 11, 2));
    });
  });

  group('countThisWeek', () {
    test('an empty history counts zero', () {
      expect(countThisWeek(const [], monday), 0);
    });

    test('Sunday 23:59 belongs to the week before', () {
      final history = [
        DateTime(2026, 10, 25, 23, 59),
        DateTime(2026, 10, 26, 0, 0),
      ];
      expect(countThisWeek(history, DateTime(2026, 10, 26, 8)), 1);
      expect(
        countThisWeek(
          history.take(1).toList(),
          DateTime(2026, 10, 25, 23, 59, 30),
        ),
        1,
      );
    });

    test('keeps counting past the goal', () {
      final history = [
        for (var i = 0; i < 13; i++) DateTime(2026, 10, 27, 8 + i % 10, i),
      ];
      expect(countThisWeek(history, DateTime(2026, 10, 29)), 13);
      expect(weeklyActiveBreakGoal, 10);
    });

    test('a new week starts again from zero', () {
      final lastWeek = [
        for (var d = 26; d <= 31; d++) DateTime(2026, 10, d, 9),
      ];
      expect(countThisWeek(lastWeek, DateTime(2026, 11, 2, 7)), 0);
    });
  });
}
