import 'package:muevete/l10n/app_localizations.dart';

/// The title and text of a step, in the app's current language.
(String, String) walkthroughStepCopy(AppLocalizations l10n, String stepId) {
  return switch (stepId) {
    'home.welcome' => (l10n.tourHomeWelcomeTitle, l10n.tourHomeWelcomeBody),
    'home.profile' => (l10n.tourHomeProfileTitle, l10n.tourHomeProfileBody),
    'home.weeklyStats' => (
      l10n.tourHomeWeeklyStatsTitle,
      l10n.tourHomeWeeklyStatsBody,
    ),
    'home.health' => (l10n.tourHomeHealthTitle, l10n.tourHomeHealthBody),
    'home.startWorkout' => (
      l10n.tourHomeStartWorkoutTitle,
      l10n.tourHomeStartWorkoutBody,
    ),
    'training.overview' => (
      l10n.tourTrainingOverviewTitle,
      l10n.tourTrainingOverviewBody,
    ),
    'training.openExercise' => (
      l10n.tourTrainingOpenExerciseTitle,
      l10n.tourTrainingOpenExerciseBody,
    ),
    'exercise.prescription' => (
      l10n.tourExercisePrescriptionTitle,
      l10n.tourExercisePrescriptionBody,
    ),
    'exercise.completeSet' => (
      l10n.tourExerciseCompleteSetTitle,
      l10n.tourExerciseCompleteSetBody,
    ),
    'exercise.next' => (l10n.tourExerciseNextTitle, l10n.tourExerciseNextBody),
    'exercise.done' => (l10n.tourExerciseDoneTitle, l10n.tourExerciseDoneBody),
    'training.finishWorkout' => (
      l10n.tourTrainingFinishWorkoutTitle,
      l10n.tourTrainingFinishWorkoutBody,
    ),
    'home.practiceNote' => (
      l10n.tourHomePracticeNoteTitle,
      l10n.tourHomePracticeNoteBody,
    ),
    'nav.openProgress' => (
      l10n.tourNavOpenProgressTitle,
      l10n.tourNavOpenProgressBody,
    ),
    'progress.calendar' => (
      l10n.tourProgressCalendarTitle,
      l10n.tourProgressCalendarBody,
    ),
    'progress.jointStats' => (
      l10n.tourProgressJointStatsTitle,
      l10n.tourProgressJointStatsBody,
    ),
    'progress.retake' => (
      l10n.tourProgressRetakeTitle,
      l10n.tourProgressRetakeBody,
    ),
    'diagnosis.overview' => (
      l10n.tourDiagnosisOverviewTitle,
      l10n.tourDiagnosisOverviewBody,
    ),
    'diagnosis.leave' => (
      l10n.tourDiagnosisLeaveTitle,
      l10n.tourDiagnosisLeaveBody,
    ),
    'nav.openHome' => (l10n.tourNavOpenHomeTitle, l10n.tourNavOpenHomeBody),
    'home.activeBreaks' => (
      l10n.tourHomeActiveBreaksTitle,
      l10n.tourHomeActiveBreaksBody,
    ),
    'ab.overview' => (l10n.tourAbOverviewTitle, l10n.tourAbOverviewBody),
    'ab.openBrowse' => (l10n.tourAbOpenBrowseTitle, l10n.tourAbOpenBrowseBody),
    'ab.browseList' => (l10n.tourAbBrowseListTitle, l10n.tourAbBrowseListBody),
    'ab.openRoutine' => (
      l10n.tourAbOpenRoutineTitle,
      l10n.tourAbOpenRoutineBody,
    ),
    'ab.routine' => (l10n.tourAbRoutineTitle, l10n.tourAbRoutineBody),
    'ab.backToMenu' => (l10n.tourAbBackToMenuTitle, l10n.tourAbBackToMenuBody),
    'ab.openTimer' => (l10n.tourAbOpenTimerTitle, l10n.tourAbOpenTimerBody),
    'ab.timerExit' => (l10n.tourAbTimerExitTitle, l10n.tourAbTimerExitBody),
    'ab.exitToHome' => (l10n.tourAbExitToHomeTitle, l10n.tourAbExitToHomeBody),
    'nav.openSettings' => (
      l10n.tourNavOpenSettingsTitle,
      l10n.tourNavOpenSettingsBody,
    ),
    'settings.language' => (
      l10n.tourSettingsLanguageTitle,
      l10n.tourSettingsLanguageBody,
    ),
    'settings.replay' => (
      l10n.tourSettingsReplayTitle,
      l10n.tourSettingsReplayBody,
    ),
    _ => throw ArgumentError.value(stepId, 'stepId', 'Unknown tour step'),
  };
}
