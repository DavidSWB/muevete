import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';

const _info = WalkthroughStepType.informational;
const _gated = WalkthroughStepType.gated;

/// The tour, in order.
const List<WalkthroughStep> walkthroughSteps = [
  WalkthroughStep(
    id: 'home.welcome',
    screen: WalkthroughScreen.home,
    type: _info,
    centered: true,
  ),
  // The mission introduction: why Muévete exists and how it helps.
  WalkthroughStep(
    id: 'home.mission',
    screen: WalkthroughScreen.home,
    type: _info,
    centered: true,
  ),
  WalkthroughStep(
    id: 'home.habits',
    screen: WalkthroughScreen.home,
    type: _info,
    centered: true,
  ),
  WalkthroughStep(
    id: 'home.profile',
    screen: WalkthroughScreen.home,
    type: _info,
  ),
  WalkthroughStep(
    id: 'home.weeklyStats',
    screen: WalkthroughScreen.home,
    type: _info,
  ),
  WalkthroughStep(
    id: 'home.health',
    screen: WalkthroughScreen.home,
    type: _info,
  ),
  WalkthroughStep(
    id: 'home.startWorkout',
    screen: WalkthroughScreen.home,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.training),
  ),
  WalkthroughStep(
    id: 'training.overview',
    screen: WalkthroughScreen.training,
    type: _info,
  ),
  WalkthroughStep(
    id: 'training.openExercise',
    screen: WalkthroughScreen.training,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.exercise),
  ),
  WalkthroughStep(
    id: 'exercise.prescription',
    screen: WalkthroughScreen.exercise,
    type: _info,
  ),
  WalkthroughStep(
    id: 'exercise.completeSet',
    screen: WalkthroughScreen.exercise,
    type: _gated,
    completesOn: ActionReceipt(WalkthroughAction.setCompleted),
  ),
  WalkthroughStep(
    id: 'exercise.next',
    screen: WalkthroughScreen.exercise,
    type: _gated,
    requiresFirst: ActionReceipt(WalkthroughAction.exerciseNext),
    completesOn: ScreenRevealed(WalkthroughScreen.exercise),
    skipWhen: WalkthroughCondition.noNextExercise,
  ),
  // Done and the back arrow both return to the list; either completes it.
  WalkthroughStep(
    id: 'exercise.done',
    screen: WalkthroughScreen.exercise,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.training),
  ),
  WalkthroughStep(
    id: 'training.finishWorkout',
    screen: WalkthroughScreen.training,
    type: _gated,
    requiresFirst: ActionReceipt(WalkthroughAction.workoutFinishPressed),
    completesOn: ScreenRevealed(WalkthroughScreen.home),
  ),
  WalkthroughStep(
    id: 'home.practiceNote',
    screen: WalkthroughScreen.home,
    type: _info,
    target: 'home.weeklyStats',
  ),
  WalkthroughStep(
    id: 'nav.openProgress',
    screen: WalkthroughScreen.home,
    type: _gated,
    target: 'nav.progress',
    completesOn: ScreenRevealed(WalkthroughScreen.progress),
  ),
  WalkthroughStep(
    id: 'progress.calendar',
    screen: WalkthroughScreen.progress,
    type: _info,
  ),
  WalkthroughStep(
    id: 'progress.jointStats',
    screen: WalkthroughScreen.progress,
    type: _info,
  ),
  WalkthroughStep(
    id: 'progress.retake',
    screen: WalkthroughScreen.progress,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.diagnosis),
  ),
  WalkthroughStep(
    id: 'diagnosis.overview',
    screen: WalkthroughScreen.diagnosis,
    type: _info,
    centered: true,
  ),
  WalkthroughStep(
    id: 'diagnosis.leave',
    screen: WalkthroughScreen.diagnosis,
    type: _gated,
    target: 'diagnosis.back',
    completesOn: ScreenRevealed(WalkthroughScreen.progress),
  ),
  WalkthroughStep(
    id: 'nav.openHome',
    screen: WalkthroughScreen.progress,
    type: _gated,
    target: 'nav.home',
    completesOn: ScreenRevealed(WalkthroughScreen.home),
  ),
  WalkthroughStep(
    id: 'home.activeBreaks',
    screen: WalkthroughScreen.home,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.activeBreaksMenu),
  ),
  WalkthroughStep(
    id: 'ab.overview',
    screen: WalkthroughScreen.activeBreaksMenu,
    type: _info,
  ),
  WalkthroughStep(
    id: 'ab.openBrowse',
    screen: WalkthroughScreen.activeBreaksMenu,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.activeBreaksBrowse),
  ),
  WalkthroughStep(
    id: 'ab.browseList',
    screen: WalkthroughScreen.activeBreaksBrowse,
    type: _info,
  ),
  WalkthroughStep(
    id: 'ab.openRoutine',
    screen: WalkthroughScreen.activeBreaksBrowse,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.activeBreakRoutine),
  ),
  WalkthroughStep(
    id: 'ab.routine',
    screen: WalkthroughScreen.activeBreakRoutine,
    type: _info,
    centered: true,
  ),
  // The routine sits on top of the list, so going back takes two presses.
  WalkthroughStep(
    id: 'ab.backToMenu',
    screen: WalkthroughScreen.activeBreakRoutine,
    type: _gated,
    target: 'ab.back',
    alsoAccepts: ScreenRevealed(WalkthroughScreen.activeBreaksBrowse),
    completesOn: ScreenRevealed(WalkthroughScreen.activeBreaksMenu),
  ),
  WalkthroughStep(
    id: 'ab.openTimer',
    screen: WalkthroughScreen.activeBreaksMenu,
    type: _gated,
    completesOn: ScreenRevealed(WalkthroughScreen.activeBreakTimer),
  ),
  WalkthroughStep(
    id: 'ab.timerExit',
    screen: WalkthroughScreen.activeBreakTimer,
    type: _gated,
    target: 'ab.back',
    completesOn: ScreenRevealed(WalkthroughScreen.activeBreaksMenu),
  ),
  WalkthroughStep(
    id: 'ab.exitToHome',
    screen: WalkthroughScreen.activeBreaksMenu,
    type: _gated,
    target: 'ab.back',
    completesOn: ScreenRevealed(WalkthroughScreen.home),
  ),
  WalkthroughStep(
    id: 'nav.openSettings',
    screen: WalkthroughScreen.home,
    type: _gated,
    target: 'nav.settings',
    completesOn: ScreenRevealed(WalkthroughScreen.settings),
  ),
  WalkthroughStep(
    id: 'settings.language',
    screen: WalkthroughScreen.settings,
    type: _info,
    passThrough: true,
  ),
  WalkthroughStep(
    id: 'settings.replay',
    screen: WalkthroughScreen.settings,
    type: _info,
  ),
];

int walkthroughStepIndex(String id) =>
    walkthroughSteps.indexWhere((step) => step.id == id);

/// Where the tour picks up after the app restarts on [index]. Pushed screens
/// are gone by then, so it goes back to the last step on a main-screen tab.
int walkthroughResumeIndex(int index) {
  for (var i = index; i >= 0; i--) {
    if (walkthroughSteps[i].screen.isTab) return i;
  }
  return 0;
}

/// Whether Previous may go back from [index]. It never undoes a navigation,
/// so it stops at the first step after a screen change.
bool walkthroughCanGoBack(int index) {
  if (index <= 0 || index >= walkthroughSteps.length) return false;
  final previous = walkthroughSteps[index - 1];
  return previous.screen == walkthroughSteps[index].screen &&
      previous.completesOn is! ScreenRevealed;
}

/// The step to fall back to when the user lands on [screen] by other means,
/// such as the system back button, while on [index]. It is the closest
/// earlier step on that screen, so the tour never jumps ahead. Null when no
/// earlier step is on that screen.
int? walkthroughRealignIndex(int index, WalkthroughScreen screen) {
  for (var i = index - 1; i >= 0; i--) {
    if (walkthroughSteps[i].screen == screen) return i;
  }
  return null;
}
