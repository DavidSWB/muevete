/// Scoring parameters from `progression_rules/rewards`. Any value missing
/// from the document keeps its default, so a partial or missing document
/// never blocks a completion.
class RewardRules {
  const RewardRules({
    this.workoutXpPerSet = 5,
    this.workoutXpMax = 100,
    this.workoutRewardsPerDay = 1,
    this.activeBreakXp = 15,
    this.activeBreakRewardsPerDay = 4,
    this.jointPointsPerSet = 2,
    this.levelThresholds = const [0, 30, 80, 150, 250],
  });

  static const defaults = RewardRules();

  /// Movement XP for each set the user marked as completed.
  final int workoutXpPerSet;

  /// Most XP one workout can give.
  final int workoutXpMax;

  /// Workouts per local day that give rewards; later ones give none.
  final int workoutRewardsPerDay;

  final int activeBreakXp;

  /// Active breaks per local day that give XP; later ones give none.
  final int activeBreakRewardsPerDay;

  /// Points each target joint gets for each completed set.
  final int jointPointsPerSet;

  /// Cumulative points where each joint level starts: index 0 is level 1.
  final List<int> levelThresholds;

  factory RewardRules.fromJson(Map<String, dynamic> json) {
    final xp = json['xp'] is Map ? json['xp'] as Map : const {};
    final joints = json['joints'] is Map ? json['joints'] as Map : const {};
    const d = defaults;

    int read(Map source, String key, int fallback) {
      final value = source[key];
      return value is int && value >= 0 ? value : fallback;
    }

    return RewardRules(
      workoutXpPerSet: read(xp, 'workoutPerSet', d.workoutXpPerSet),
      workoutXpMax: read(xp, 'workoutMax', d.workoutXpMax),
      workoutRewardsPerDay: read(
        xp,
        'workoutRewardsPerDay',
        d.workoutRewardsPerDay,
      ),
      activeBreakXp: read(xp, 'activeBreak', d.activeBreakXp),
      activeBreakRewardsPerDay: read(
        xp,
        'activeBreakRewardsPerDay',
        d.activeBreakRewardsPerDay,
      ),
      jointPointsPerSet: read(joints, 'pointsPerSet', d.jointPointsPerSet),
      levelThresholds:
          _thresholds(joints['levelThresholds']) ?? d.levelThresholds,
    );
  }

  /// Null unless [value] is a list of ints starting at 0 and rising.
  static List<int>? _thresholds(Object? value) {
    if (value is! List || value.isEmpty || value.any((v) => v is! int)) {
      return null;
    }
    final thresholds = value.cast<int>().toList();
    if (thresholds.first != 0) return null;
    for (var i = 1; i < thresholds.length; i++) {
      if (thresholds[i] <= thresholds[i - 1]) return null;
    }
    return thresholds;
  }
}

abstract interface class RewardRulesRepository {
  Future<RewardRules> getRules();
}
