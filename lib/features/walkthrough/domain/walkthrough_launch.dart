import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';

enum WalkthroughLaunch {
  /// Do nothing.
  none,

  /// Start the tour by itself.
  autoStart,

  /// Ask whether the user wants the tour.
  invite,
}

/// What to do when a signed-in user reaches Home. A user with nothing saved
/// and no finished workouts is treated as new and gets the tour by itself;
/// anyone else who has not finished or declined it is invited.
WalkthroughLaunch decideWalkthroughLaunch({
  required WalkthroughProgress? saved,
  required bool hasCompletedWorkouts,
}) {
  if (saved == null) {
    return hasCompletedWorkouts
        ? WalkthroughLaunch.invite
        : WalkthroughLaunch.autoStart;
  }
  return switch (saved.status) {
    WalkthroughStatus.dismissed => WalkthroughLaunch.invite,
    WalkthroughStatus.active ||
    WalkthroughStatus.completed ||
    WalkthroughStatus.declined => WalkthroughLaunch.none,
  };
}
