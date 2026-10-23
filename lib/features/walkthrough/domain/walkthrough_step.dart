/// Screens the tour visits. Tabs of the main screen and pushed routes alike.
enum WalkthroughScreen {
  home,
  training,
  exercise,
  progress,
  diagnosis,
  activeBreaksMenu,
  activeBreaksBrowse,
  activeBreakRoutine,
  activeBreakTimer,
  settings;

  /// Whether the screen is a tab of the main screen, which the tour can
  /// select by itself when it resumes. Pushed routes cannot be recreated.
  bool get isTab =>
      this == home || this == training || this == progress || this == settings;
}

/// User actions that complete a step without changing the screen.
enum WalkthroughAction {
  setCompleted,
  exerciseNext,
  exerciseDone,
  workoutFinishPressed,
}

/// Facts about the user's data that make a step pointless.
enum WalkthroughCondition {
  /// The exercise being shown is the last one of its workout.
  noNextExercise,
}

enum WalkthroughStepType {
  /// Explains something; the user moves on with Next.
  informational,

  /// Waits for the user to use the real, highlighted control.
  gated,
}

/// Something the app reports to the tour.
sealed class WalkthroughSignal {
  const WalkthroughSignal();
}

/// A screen became the visible one.
final class ScreenRevealed extends WalkthroughSignal {
  const ScreenRevealed(this.screen);

  final WalkthroughScreen screen;

  @override
  bool operator ==(Object other) =>
      other is ScreenRevealed && other.screen == screen;

  @override
  int get hashCode => Object.hash(ScreenRevealed, screen);

  @override
  String toString() => 'ScreenRevealed(${screen.name})';
}

/// The handler of a real control finished its work.
final class ActionReceipt extends WalkthroughSignal {
  const ActionReceipt(this.action);

  final WalkthroughAction action;

  @override
  bool operator ==(Object other) =>
      other is ActionReceipt && other.action == action;

  @override
  int get hashCode => Object.hash(ActionReceipt, action);

  @override
  String toString() => 'ActionReceipt(${action.name})';
}

class WalkthroughStep {
  const WalkthroughStep({
    required this.id,
    required this.screen,
    required this.type,
    this.completesOn,
    this.requiresFirst,
    this.alsoAccepts,
    this.skipWhen,
    this.passThrough = false,
    this.target,
    this.centered = false,
  });

  /// Stable id, saved on the device and used as the copy's ARB stem.
  final String id;

  /// The screen the step is shown on.
  final WalkthroughScreen screen;

  final WalkthroughStepType type;

  /// Gated steps only: the signal that completes the step.
  final WalkthroughSignal? completesOn;

  /// Gated steps only: a receipt that must arrive before [completesOn]
  /// counts, so the destination alone is not enough.
  final ActionReceipt? requiresFirst;

  /// Gated steps only: a signal on the way to [completesOn] that keeps the
  /// step and only marks it as half done.
  final ScreenRevealed? alsoAccepts;

  /// The step is skipped while this condition holds.
  final WalkthroughCondition? skipWhen;

  /// Informational steps only: taps inside the highlight reach the real
  /// control, which can be used without moving the tour.
  final bool passThrough;

  /// The anchor to highlight when it differs from [id].
  final String? target;

  /// The step points at nothing; its card sits in the middle of the screen.
  final bool centered;

  /// The anchor the step highlights, or null for a centered step.
  String? get targetId => centered ? null : (target ?? id);

  bool get isGated => type == WalkthroughStepType.gated;

  @override
  String toString() => 'WalkthroughStep($id)';
}
