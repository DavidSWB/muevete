/// Active breaks a week that the weekly goal on Home asks for.
const int weeklyActiveBreakGoal = 10;

/// Local midnight on the Monday of [now]'s week. Built from calendar days,
/// not by subtracting hours, so a daylight-saving change in between cannot
/// move it.
DateTime startOfWeek(DateTime now) =>
    DateTime(now.year, now.month, now.day - (now.weekday - DateTime.monday));

/// Entries of [history] from Monday 00:00 of [now]'s week on. Each entry is
/// one recorded completion, so duplicates cannot occur, and nothing needs
/// resetting when a new week starts: the count is simply worked out again.
int countThisWeek(List<DateTime> history, DateTime now) {
  final start = startOfWeek(now);
  return history.where((date) => !date.isBefore(start)).length;
}
