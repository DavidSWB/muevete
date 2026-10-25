/// A completion that counts toward the user's consistency.
enum ActivityKind {
  /// A training-plan workout, stored in `completedWorkouts`.
  workout,

  /// An active-break routine or a personal-timer break, stored in
  /// `completedActiveBreaks`.
  activeBreak,
}
