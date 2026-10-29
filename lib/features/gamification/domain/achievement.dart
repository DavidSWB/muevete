/// One badge of the catalogue in the `achievements` collection.
class Achievement {
  const Achievement({
    required this.achievementId,
    required this.order,
    required this.icon,
    required this.name,
    required this.description,
    required this.condition,
  });

  final String achievementId;

  /// Position in the medal case, lowest first.
  final int order;

  /// A Material icon name such as `fitness_center`, drawn on the medal.
  final String icon;

  /// By language code (`es`, `en`).
  final Map<String, String> name;

  /// How to earn it, by language code; shown on a locked slot.
  final Map<String, String> description;

  final AchievementCondition condition;
}

/// What unlocks an [Achievement].
sealed class AchievementCondition {
  const AchievementCondition();
}

/// At least [count] recorded completions of [kind].
class CompletionCountCondition extends AchievementCondition {
  const CompletionCountCondition({required this.kind, required this.count});

  final CountedActivity kind;
  final int count;
}

/// The app tour reached its last step on this device.
class WalkthroughCompletedCondition extends AchievementCondition {
  const WalkthroughCompletedCondition();
}

/// A condition this version of the app does not know. It never unlocks, so
/// a newer catalogue cannot hand out badges by mistake.
class UnknownCondition extends AchievementCondition {
  const UnknownCondition(this.type);

  final String? type;
}

enum CountedActivity { workouts, activeBreaks }

abstract interface class AchievementRepository {
  /// The catalogue, ordered by [Achievement.order].
  Future<List<Achievement>> getAchievements();
}
