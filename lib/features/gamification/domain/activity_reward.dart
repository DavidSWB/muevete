/// The joints that have progression points, as stored in `jointProgress`.
const List<String> progressionJoints = ['ankle', 'knee', 'hip', 'shoulder'];

/// One exercise of a finished workout, as far as rewards are concerned.
class CompletedExercise {
  const CompletedExercise({
    required this.targets,
    required this.completedSets,
    required this.prescribedSets,
  });

  /// The exercise's target joints, from the exercise definition.
  final List<String> targets;

  /// Sets the user marked as completed.
  final int completedSets;

  final int prescribedSets;
}

class CompletedWorkout {
  const CompletedWorkout(this.exercises);

  static const empty = CompletedWorkout([]);

  final List<CompletedExercise> exercises;

  /// Completed sets, never more than were prescribed per exercise.
  int get completedSets => exercises.fold(
    0,
    (total, e) => total + e.completedSets.clamp(0, e.prescribedSets),
  );
}

/// What one completion adds to `movementXp` and `jointProgress`.
class ActivityReward {
  const ActivityReward({required this.xp, this.jointPoints = const {}});

  static const none = ActivityReward(xp: 0);

  final int xp;

  /// Points per joint; only joints in [progressionJoints], never zero.
  final Map<String, int> jointPoints;

  bool get isEmpty => xp == 0 && jointPoints.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is ActivityReward &&
      other.xp == xp &&
      other.jointPoints.length == jointPoints.length &&
      jointPoints.entries.every((e) => other.jointPoints[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    xp,
    Object.hashAllUnordered(
      jointPoints.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() => 'ActivityReward(xp: $xp, jointPoints: $jointPoints)';
}

/// Works out a completion's reward from the history recorded before it.
/// [earlier] is the history of the same kind of activity.
typedef RewardForHistory = ActivityReward Function(List<DateTime> earlier);
