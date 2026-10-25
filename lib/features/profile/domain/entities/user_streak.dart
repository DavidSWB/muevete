/// Consecutive local calendar days with at least one completed workout or
/// active break, as last written to the user's document.
///
/// [current] is the run that ends on [lastActiveDate]. It is not reset when
/// days pass without activity, so read it through
/// `StreakCalculator.liveCurrent`.
class UserStreak {
  final int current;
  final int longest;

  /// Local calendar date (midnight) of the latest completion.
  final DateTime? lastActiveDate;

  /// IANA time zone the dates were taken in, when known.
  final String? timeZone;

  const UserStreak({
    required this.current,
    required this.longest,
    this.lastActiveDate,
    this.timeZone,
  });

  static const empty = UserStreak(current: 0, longest: 0);

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    final rawDate = json["lastActiveDate"];
    return UserStreak(
      current: (json["current"] as num?)?.toInt() ?? 0,
      longest: (json["longest"] as num?)?.toInt() ?? 0,
      lastActiveDate: rawDate is String ? _parseDate(rawDate) : null,
      timeZone: json["timeZone"] as String?,
    );
  }

  static DateTime? _parseDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(value);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  Map<String, dynamic> toJson() => {
    "current": current,
    "longest": longest,
    "lastActiveDate": lastActiveDate == null
        ? null
        : _formatDate(lastActiveDate!),
    "timeZone": timeZone,
  };

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStreak &&
          current == other.current &&
          longest == other.longest &&
          lastActiveDate == other.lastActiveDate &&
          timeZone == other.timeZone;

  @override
  int get hashCode => Object.hash(current, longest, lastActiveDate, timeZone);

  @override
  String toString() =>
      'UserStreak(current: $current, longest: $longest, '
      'lastActiveDate: $lastActiveDate, timeZone: $timeZone)';
}
