// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Muévete';

  @override
  String get authLogin => 'Login';

  @override
  String get authEmailHint => 'example@gmail.com';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authEnter => 'Enter';

  @override
  String get authCreateAccountPrompt => 'Create a new account';

  @override
  String get authRegister => 'Register';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get authCreateAccountTitle => 'Create Account';

  @override
  String get authFullNameHint => 'Full name';

  @override
  String get authAgeHint => 'Age (e.g. 25)';

  @override
  String get authWeightHint => 'Weight in kg (e.g. 70.5)';

  @override
  String get authHeightHint => 'Height in cm (e.g. 175)';

  @override
  String get authMedicalConditionsHint => 'Medical conditions (optional)';

  @override
  String get valEmptyEmailPassword => 'Email and password cannot be empty.';

  @override
  String get valPasswordMinLength =>
      'Password must be at least 6 characters long.';

  @override
  String get valInvalidEmail => 'Please enter a valid email address.';

  @override
  String get valMandatoryFields => 'All mandatory fields must be filled.';

  @override
  String get valInvalidAge => 'Please enter a valid age (1-120).';

  @override
  String get valInvalidWeight => 'Please enter a valid weight in kg.';

  @override
  String get valInvalidHeight => 'Please enter a valid height in cm.';

  @override
  String get errInvalidCredentials => 'Invalid email or password.';

  @override
  String get errInvalidEmailFormat => 'Invalid email format.';

  @override
  String get errUserDisabled => 'This user account has been disabled.';

  @override
  String get errTooManyRequests =>
      'Too many failed attempts. Please try again later.';

  @override
  String get errNetwork =>
      'Network error. Please check your internet connection.';

  @override
  String get errAuthFailed => 'Authentication failed. Please try again.';

  @override
  String get errEmailInUse =>
      'This email is already in use by another account.';

  @override
  String get errWeakPassword => 'The password provided is too weak.';

  @override
  String get errUnexpected => 'An unexpected error occurred. Please try again.';

  @override
  String errGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get errAccountExistsOtherProvider =>
      'An account with this email already exists. Please sign in with your original method.';

  @override
  String get errSignInCancelled => 'Sign-in was cancelled.';

  @override
  String get authSignInWithGoogle => 'Continue with Google';

  @override
  String get authSignInWithApple => 'Continue with Apple';

  @override
  String get authOrDivider => 'or';

  @override
  String get navHome => 'Home';

  @override
  String get navTraining => 'Training';

  @override
  String get navActiveBreaks => 'Breaks';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String homeGreeting(String username) {
    return 'Hi $username!';
  }

  @override
  String get homeSubGreeting => 'Let’s keep moving.';

  @override
  String get homeKeepProgress => 'Keep progress!';

  @override
  String get homeStayConsistent => 'Stay consistent with your training.';

  @override
  String get homeCompleted => 'Completed';

  @override
  String get homeOverallLevel => 'Overall level';

  @override
  String get homeNextWorkout => 'Next workout';

  @override
  String get homeStartTraining => 'Start training now!';

  @override
  String get homeActiveBreaks => 'Active breaks';

  @override
  String get homeActiveBreaksDesc => 'Quick routines to keep you moving.';

  @override
  String get homeCouldNotLoadProfile => 'Could not load profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsChangeProgram => 'Change training program';

  @override
  String get settingsLogOut => 'Log Out';

  @override
  String get settingsLanguageSubtitle => 'English';

  @override
  String get languageTitle => 'Select Language';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get notifSettingsTitle => 'Notification Settings';

  @override
  String get notifDisabledTitle => 'Notifications Disabled';

  @override
  String get notifDisabledDesc =>
      'Notification permissions are disabled on your device. Muévete cannot deliver workout or active break reminders until permission is enabled.';

  @override
  String get notifRequestPermission => 'Request Permission';

  @override
  String get notifTrainingReminders => 'Training Reminders';

  @override
  String notifDays(String days) {
    return 'Days: $days';
  }

  @override
  String notifTime(String time) {
    return 'Time: $time';
  }

  @override
  String get notifChangeSchedule => 'Change Schedule in Program Setup';

  @override
  String get notifNoActiveSchedule => 'No Active Training Schedule';

  @override
  String get notifNoActiveScheduleDesc =>
      'To enable training reminders, please select a training plan and set your workout days.';

  @override
  String get notifConfigureProgram => 'Configure Program';

  @override
  String get notifActiveBreakReminders => 'Active-Break Reminders';

  @override
  String get notifActiveBreakDesc =>
      'Receive reminders to move throughout your day during a configurable time window.';

  @override
  String get notifStartTime => 'Start Time';

  @override
  String get notifEndTime => 'End Time';

  @override
  String get notifRangeError =>
      'End time must be later than start time within the same day.';

  @override
  String get notifInterval => 'Reminder Interval';

  @override
  String get notifMin60 => '60 min\n(1 hour)';

  @override
  String get notifMin120 => '120 min\n(2 hours)';

  @override
  String get notifMin180 => '180 min\n(3 hours)';

  @override
  String get notifSavePreferences => 'Save Preferences';

  @override
  String get notifSavedSuccess => 'Preferences saved and reminders updated.';

  @override
  String get notifSavedDisabledDevice =>
      'Settings saved, but notifications are disabled on this device.';

  @override
  String get notifFailedLoadProfile => 'Failed to load profile.';

  @override
  String get notifRetry => 'Retry';

  @override
  String get notifErrorSave =>
      'Could not save notification settings. Please try again.';

  @override
  String get notifErrorSchedule =>
      'Preferences were saved, but reminders could not be scheduled on this device. Please try again.';

  @override
  String get notifErrorScheduleNoPermission =>
      'Preferences were saved, but reminders can\'t be shown because notifications are disabled on this device. Turn them on and save again.';

  @override
  String get diagTitle => 'Diagnosis';

  @override
  String get diagPrevious => 'Previous';

  @override
  String get diagNext => 'Next';

  @override
  String get diagFinish => 'Finish';

  @override
  String get diagConfirmFinish => 'Are you sure you wanna finish the test?';

  @override
  String get diagSomethingWentWrong => 'Sorry, something went wrong';

  @override
  String get diagSavedSuccess => 'Diagnosis saved Successfully!';

  @override
  String get diagAccept => 'Accept';

  @override
  String get progTitle => 'Training program';

  @override
  String get progSelectSubtitle => 'Select a program to continue to Home.';

  @override
  String get progSelectDays => 'Select your training days';

  @override
  String get progReminderTime => 'Reminder Time';

  @override
  String get progRecoveryWarning =>
      '⚠️ Scheduling workouts that target the same muscles consecutively limits recovery. Consider leaving a 48h window.';

  @override
  String get progContinue => 'Continue';

  @override
  String get progCouldNotLoad => 'Could not load training programs.';

  @override
  String get progNoPrograms => 'No training programs are available.';

  @override
  String get progCouldNotSave =>
      'Could not save the training program. Please try again.';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressMobilityStats => 'Joint stats';

  @override
  String get progressShoulder => 'Shoulder';

  @override
  String get progressHip => 'Hip';

  @override
  String get progressKnee => 'Knee';

  @override
  String get progressAnkle => 'Ankle';

  @override
  String get progressRetake => 'Retake Assessment';

  @override
  String get abTitle => 'Active Breaks';

  @override
  String get abMotto =>
      'You better move that beautiful butt... or you\'ll lose it.';

  @override
  String get abBrowseTitle => 'Active Breaks';

  @override
  String get abBrowseDesc => 'Choose a quick routine to keep moving.';

  @override
  String get abPersonalTimerTitle => 'Personal Timer';

  @override
  String get abPersonalTimerDesc => 'Set a timer for a self-directed break.';

  @override
  String get abChooseTitle => 'Choose an Active Break';

  @override
  String get abChooseRandom => 'Choose randomly';

  @override
  String abDurationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String abTryToWalk(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'minutes',
      one: 'minute',
    );
    return 'Try to walk for $minutes $_temp0 after 1 hour of sitting.';
  }

  @override
  String get abComplete => 'Active break complete!';

  @override
  String get abStart => 'Start';

  @override
  String get abPause => 'Pause';

  @override
  String get abReset => 'Reset';

  @override
  String get abMarkCompleted => 'Mark active break as completed';

  @override
  String get abCompletedMarked => 'Completed';

  @override
  String get abCouldNotLoad => 'Could not load Active Breaks.';

  @override
  String get abNoAvailable => 'No Active Breaks are available right now.';

  @override
  String get abMarkRoutineCompleted => 'Mark active break as completed';

  @override
  String get abRoutineCompleted => 'Completed';

  @override
  String get activitySaveFailed => 'Could not save. Please try again.';

  @override
  String get notifTrainingTitle => 'Time to train!';

  @override
  String notifTrainingBody(int session) {
    return 'Session $session: Your scheduled workout is ready.';
  }

  @override
  String get notifActiveBreakTitle => 'Active Break';

  @override
  String get notifActiveBreakBody => 'Time to move! Take a short active break.';

  @override
  String get exerciseDone => 'Done!';

  @override
  String get exerciseNext => 'Next';

  @override
  String get workoutFinish => 'Finish Workout';

  @override
  String get exerciseSets => 'Sets';

  @override
  String get exerciseReps => 'Reps';

  @override
  String get exerciseRepsShort => 'Reps';

  @override
  String get exerciseRest => 'Rest';

  @override
  String get exerciseDuration => 'Duration';

  @override
  String get exerciseStartTimer => 'Start timer';

  @override
  String get exercisePauseTimer => 'Pause timer';

  @override
  String get exerciseMarkSetComplete => 'Mark set complete';

  @override
  String get exerciseMarkSetIncomplete => 'Mark set incomplete';

  @override
  String exerciseSetCompleted(int number) {
    return 'Set $number completed';
  }

  @override
  String exerciseSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String exerciseVolumeReps(String sets, int reps) {
    return '$sets × $reps reps';
  }

  @override
  String exerciseVolumeDuration(String sets, int seconds) {
    return '$sets × ${seconds}s';
  }

  @override
  String get tourPrevious => 'Previous';

  @override
  String get tourNext => 'Next';

  @override
  String get tourDone => 'Got it';

  @override
  String get tourClose => 'Close tour';

  @override
  String tourStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get tourTapHighlighted => 'Tap the highlighted control to continue';

  @override
  String get tourTryAgain => 'Try again';

  @override
  String get tourTargetMissing => 'We couldn\'t find this on the screen.';

  @override
  String get tourOneMoreBack => 'One more step back';

  @override
  String get settingsReplayTour => 'Take the tour again';

  @override
  String get settingsReplayTourSubtitle => 'Walk through the app step by step';

  @override
  String get tourHomeWelcomeTitle => 'Welcome to Muévete';

  @override
  String get tourHomeWelcomeBody =>
      'A quick tour of the app. You can close it any time and replay it from Settings.';

  @override
  String get tourHomeProfileTitle => 'Your profile';

  @override
  String get tourHomeProfileBody =>
      'This takes you to your profile and settings. We\'ll visit them at the end of the tour.';

  @override
  String get tourHomeWeeklyStatsTitle => 'Your week';

  @override
  String get tourHomeWeeklyStatsBody =>
      'See how many workouts you\'ve done this week and your estimated training time.';

  @override
  String get tourHomeHealthTitle => 'Your health matters too';

  @override
  String get tourHomeHealthBody =>
      'A short tip to look after your body. This card takes you to your progress.';

  @override
  String get tourHomeStartWorkoutTitle => 'Start training';

  @override
  String get tourHomeStartWorkoutBody =>
      'Tap “Start workout” to open your next scheduled workout.';

  @override
  String get tourTrainingOverviewTitle => 'Your workout';

  @override
  String get tourTrainingOverviewBody =>
      'A list of exercises. Each one shows your sets and reps, or how long to hold.';

  @override
  String get tourTrainingOpenExerciseTitle => 'Open an exercise';

  @override
  String get tourTrainingOpenExerciseBody =>
      'Tap the first one to see how it\'s done.';

  @override
  String get tourExercisePrescriptionTitle => 'What to do';

  @override
  String get tourExercisePrescriptionBody =>
      'Here you see your sets, reps (or the duration, for holds) and rest.';

  @override
  String get tourExerciseCompleteSetTitle => 'Mark your first set';

  @override
  String get tourExerciseCompleteSetBody =>
      'When you finish a set, mark it here. For holds, wait until the timer ends.';

  @override
  String get tourExerciseNextTitle => 'Move on';

  @override
  String get tourExerciseNextBody =>
      'Tap “Next” to go to the next exercise in your workout.';

  @override
  String get tourExerciseDoneTitle => 'Finish the exercise';

  @override
  String get tourExerciseDoneBody =>
      'Tap “Done!” to go back to the exercise list.';

  @override
  String get tourTrainingFinishWorkoutTitle => 'Finish the workout';

  @override
  String get tourTrainingFinishWorkoutBody =>
      'Tap “Finish Workout”. This is just practice: nothing will be saved.';

  @override
  String get tourHomePracticeNoteTitle => 'Nothing was saved';

  @override
  String get tourHomePracticeNoteBody =>
      'Since that was practice, your week is unchanged. A real finished workout will count here.';

  @override
  String get tourNavOpenProgressTitle => 'Open your progress';

  @override
  String get tourNavOpenProgressBody => 'Tap “Progress” in the bottom bar.';

  @override
  String get tourProgressCalendarTitle => 'Your calendar';

  @override
  String get tourProgressCalendarBody =>
      'Green days are workouts you actually finished. You can also see how many you\'ve done.';

  @override
  String get tourProgressJointStatsTitle => 'Joint stats';

  @override
  String get tourProgressJointStatsBody =>
      'Your mobility level for each joint, from 0 to 5. It updates when you retake the assessment.';

  @override
  String get tourProgressRetakeTitle => 'Retake the assessment';

  @override
  String get tourProgressRetakeBody =>
      'Tap the button to open it. We won\'t submit anything during the tour.';

  @override
  String get tourDiagnosisOverviewTitle => 'Your physical assessment';

  @override
  String get tourDiagnosisOverviewBody =>
      'These questions help adapt your program to your level. You don\'t need to answer anything now.';

  @override
  String get tourDiagnosisLeaveTitle => 'Go back';

  @override
  String get tourDiagnosisLeaveBody =>
      'Tap the back arrow to leave without changing anything.';

  @override
  String get tourNavOpenHomeTitle => 'Back to Home';

  @override
  String get tourNavOpenHomeBody => 'Tap “Home” in the bottom bar.';

  @override
  String get tourHomeActiveBreaksTitle => 'Active breaks';

  @override
  String get tourHomeActiveBreaksBody =>
      'Short routines to break up long periods of sitting. Tap the section to open them.';

  @override
  String get tourAbOverviewTitle => 'Two ways to move';

  @override
  String get tourAbOverviewBody =>
      'Pick a routine from the list or use the timer. Active breaks are separate from your training program.';

  @override
  String get tourAbOpenBrowseTitle => 'Browse routines';

  @override
  String get tourAbOpenBrowseBody =>
      'Tap the option to see the available routines.';

  @override
  String get tourAbBrowseListTitle => 'Pick a routine';

  @override
  String get tourAbBrowseListBody =>
      'Choose one you like, or use the random button to let the app pick for you.';

  @override
  String get tourAbOpenRoutineTitle => 'Open a routine';

  @override
  String get tourAbOpenRoutineBody =>
      'Tap the first one to see what it\'s like.';

  @override
  String get tourAbRoutineTitle => 'How a routine works';

  @override
  String get tourAbRoutineBody =>
      'You follow the exercises one by one. We won\'t finish this one during the tour.';

  @override
  String get tourAbBackToMenuTitle => 'Back to the menu';

  @override
  String get tourAbBackToMenuBody =>
      'Use the back arrow until you reach the active breaks menu.';

  @override
  String get tourAbOpenTimerTitle => 'Try the timer';

  @override
  String get tourAbOpenTimerBody => 'Tap the timer option.';

  @override
  String get tourAbTimerExitTitle => 'The timer';

  @override
  String get tourAbTimerExitBody =>
      'Pick how many minutes and time your break. Tap the back arrow to continue.';

  @override
  String get tourAbExitToHomeTitle => 'Leave active breaks';

  @override
  String get tourAbExitToHomeBody => 'Tap the back arrow to return to Home.';

  @override
  String get tourNavOpenSettingsTitle => 'Open Settings';

  @override
  String get tourNavOpenSettingsBody => 'Tap “Settings” in the bottom bar.';

  @override
  String get tourSettingsLanguageTitle => 'Change language';

  @override
  String get tourSettingsLanguageBody =>
      'Use this switch to move between Spanish and English any time. The tour keeps your place.';

  @override
  String get tourSettingsReplayTitle => 'Replay the tour';

  @override
  String get tourSettingsReplayBody =>
      'You can repeat it from here any time. Let\'s get moving!';

  @override
  String get tourInviteTitle => 'Want a quick tour of Muévete?';

  @override
  String get tourInviteBody =>
      'We\'ll walk you through the app step by step. You can also find it later in Settings → “Take the tour again”.';

  @override
  String get tourInviteStart => 'Start tour';

  @override
  String get tourInviteLater => 'Not now';

  @override
  String get tourInviteNever => 'Never ask again';

  @override
  String get tourInviteNeverConfirm =>
      'No problem. You\'ll find the tour in Settings.';

  @override
  String get tourResumeTitle => 'Your tour is unfinished';

  @override
  String tourResumeBody(int current, int total) {
    return 'You were on step $current of $total. Continue where you left off or start over?';
  }

  @override
  String get tourResume => 'Continue';

  @override
  String get tourStartOver => 'Start over';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get dayMonShort => 'Mon';

  @override
  String get dayTueShort => 'Tue';

  @override
  String get dayWedShort => 'Wed';

  @override
  String get dayThuShort => 'Thu';

  @override
  String get dayFriShort => 'Fri';

  @override
  String get daySatShort => 'Sat';

  @override
  String get daySunShort => 'Sun';

  @override
  String get authSexLabel => 'Biological sex';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get valSelectSex => 'Please select your biological sex.';

  @override
  String get editProfileEmailReadOnly => 'Your email can\'t be changed here.';

  @override
  String get editProfileSave => 'Save changes';

  @override
  String get editProfileSaved => 'Profile updated.';

  @override
  String get editProfileSaveFailed =>
      'Could not save your profile. Please try again.';

  @override
  String get homeTodayWorkoutBadge => 'TODAY\'S WORKOUT';

  @override
  String get homeWorkoutDescription =>
      'A complete routine to activate your body and improve your fitness.';

  @override
  String get homeStartWorkoutCta => 'Start\nworkout';

  @override
  String get homeDoneEarly => 'Done early';

  @override
  String get homeRestDayBadge => 'REST DAY';

  @override
  String get homeRestDayTitle => 'Rest day!';

  @override
  String get homeRestDayDescription =>
      'Take time to recover today, and keep moving gently throughout the day.';

  @override
  String get homeRestDayActiveBreak => 'Take an active break';

  @override
  String get homeRestDayAdvance => 'Start next workout early';

  @override
  String get measureAgeTitle => 'How old are you?';

  @override
  String get measureWeightTitle => 'How much do you weigh?';

  @override
  String get measureHeightTitle => 'How tall are you?';

  @override
  String get profileAgeLabel => 'Age';

  @override
  String get profileWeightLabel => 'Weight';

  @override
  String get profileHeightLabel => 'Height';

  @override
  String get unitYears => 'years';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLbs => 'lbs';

  @override
  String get unitCm => 'cm';

  @override
  String get commonNext => 'Next';

  @override
  String get commonDone => 'Done';

  @override
  String get timePickerHour => 'Hour';

  @override
  String get timePickerMinute => 'Minutes';

  @override
  String get tourHomeMissionTitle => 'Our mission';

  @override
  String get tourHomeMissionBody =>
      'Muévete helps you spend less time sitting and move more every day, with guided workouts and short active breaks.';

  @override
  String get tourHomeHabitsTitle => 'A habit that grows with you';

  @override
  String get tourHomeHabitsBody =>
      'Workouts and active breaks help you build a habit of moving. Exercises match your level and can move up with you when you retake the assessment.';

  @override
  String get tipTypeTip => 'TIP';

  @override
  String get tipTypeEvidence => 'WHAT THE EVIDENCE SAYS';

  @override
  String get tipDismiss => 'Dismiss tip';

  @override
  String tipSource(String source) {
    return 'Source: $source';
  }

  @override
  String tipOpenSource(String source) {
    return 'Open the source: $source';
  }

  @override
  String get tipSourceFailed =>
      'We couldn\'t open the link. Please try again later.';

  @override
  String get settingsTips => 'Health tips';

  @override
  String get settingsTipsDaily => 'One a day';

  @override
  String get settingsTipsEveryOpen => 'Every time I open the app';

  @override
  String get settingsTipsOff => 'Off';

  @override
  String get progressMovementTitle => 'Your movement progress';

  @override
  String progressMovementXp(int xp) {
    return '$xp XP';
  }

  @override
  String get progressMovementXpHint =>
      'You earn XP by completing workouts and active breaks. It doesn\'t change how hard your exercises are.';

  @override
  String get progressJointHint =>
      'Each completed set adds points to the joints it works.';

  @override
  String progressJointLevel(int level) {
    return 'Level $level';
  }

  @override
  String progressJointPoints(int points, int next) {
    return '$points/$next pts';
  }

  @override
  String get progressJointMaxLevel => 'Top level';

  @override
  String progressJointLevelLabel(
    String joint,
    int level,
    int points,
    int next,
  ) {
    return '$joint: level $level, $points of $next points';
  }

  @override
  String progressJointMaxLevelLabel(String joint, int level) {
    return '$joint: level $level, top level';
  }

  @override
  String get progressMedalsTitle => 'Your medals';

  @override
  String progressMedalsCount(int unlocked, int total) {
    return '$unlocked of $total';
  }

  @override
  String progressMedalUnlockedLabel(String name) {
    return '$name: medal unlocked';
  }

  @override
  String progressMedalLockedLabel(String name, String hint) {
    return '$name: medal locked. $hint';
  }

  @override
  String get progressMedalsLoading => 'Loading medals';

  @override
  String get progressMedalsError => 'Couldn\'t load your medals.';

  @override
  String homeWeeklyBreaksCount(int count, int goal) {
    return '$count/$goal';
  }

  @override
  String get homeWeeklyBreaksCaption => 'breaks this week';

  @override
  String homeWeeklyBreaksLabel(int count, int goal) {
    return '$count of $goal active breaks this week';
  }
}
