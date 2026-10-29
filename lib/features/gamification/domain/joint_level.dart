/// A joint's progression level from its cumulative points.
class JointLevel {
  const JointLevel({
    required this.level,
    required this.points,
    required this.levelStart,
    required this.nextLevelAt,
  });

  /// Level for [points] with [thresholds] (cumulative, starting at 0).
  factory JointLevel.fromPoints(int points, List<int> thresholds) {
    final safePoints = points < 0 ? 0 : points;
    var index = 0;
    for (var i = 0; i < thresholds.length; i++) {
      if (safePoints >= thresholds[i]) index = i;
    }
    return JointLevel(
      level: index + 1,
      points: safePoints,
      levelStart: thresholds.isEmpty ? 0 : thresholds[index],
      nextLevelAt: index + 1 < thresholds.length ? thresholds[index + 1] : null,
    );
  }

  /// 1-based.
  final int level;
  final int points;

  /// Points where [level] starts.
  final int levelStart;

  /// Points where the next level starts, or null at the top level.
  final int? nextLevelAt;

  bool get isMaxLevel => nextLevelAt == null;

  /// Progress through the current level, from 0 to 1; 1 at the top level.
  double get progress {
    final next = nextLevelAt;
    if (next == null) return 1;
    return (points - levelStart) / (next - levelStart);
  }

  int get pointsToNext => nextLevelAt == null ? 0 : nextLevelAt! - points;
}
