import 'package:muevete/features/profile/domain/entities/user_streak.dart';

/// Streak rules: a day counts when it holds at least one completion, today
/// counts as soon as it does, and a calendar day without one ends the run.
///
/// The streak is always rebuilt from the full history instead of being
/// incremented, so repeated, retried or out-of-order completions cannot
/// inflate it.
class StreakCalculator {
  const StreakCalculator();

  UserStreak fromHistory(
    Iterable<DateTime> completions, {
    required DateTime today,
    String? timeZone,
  }) {
    final todayKey = _dayKey(today);
    final days =
        completions
            .map(_dayKey)
            .where((day) => day <= todayKey) // ignore future-dated entries
            .toSet()
            .toList()
          ..sort();

    if (days.isEmpty) {
      return UserStreak(current: 0, longest: 0, timeZone: timeZone);
    }

    var run = 1;
    var longest = 1;
    for (var i = 1; i < days.length; i++) {
      run = days[i] - days[i - 1] == 1 ? run + 1 : 1;
      if (run > longest) longest = run;
    }

    return UserStreak(
      current: run,
      longest: longest,
      lastActiveDate: _dateOf(days.last),
      timeZone: timeZone,
    );
  }

  /// The streak as of [today]: alive while the last active day is today or
  /// yesterday, otherwise 0.
  int liveCurrent(UserStreak streak, DateTime today) {
    final last = streak.lastActiveDate;
    if (last == null) return 0;
    final gap = _dayKey(today) - _dayKey(last);
    return gap == 0 || gap == 1 ? streak.current : 0;
  }

  /// Days since the epoch for the local calendar date of [moment], counted
  /// in UTC so daylight-saving shifts never change the difference.
  static int _dayKey(DateTime moment) {
    final local = moment.isUtc ? moment.toLocal() : moment;
    return DateTime.utc(
          local.year,
          local.month,
          local.day,
        ).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  static DateTime _dateOf(int dayKey) {
    final utc = DateTime.fromMillisecondsSinceEpoch(
      dayKey * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return DateTime(utc.year, utc.month, utc.day);
  }
}
