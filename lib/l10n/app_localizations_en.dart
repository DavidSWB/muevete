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
  String get notifSavedSuccess => 'Notification settings saved successfully.';

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
      'Preferences were saved, but reminders could not be scheduled. Check notification permissions and try again.';

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
  String get progressMobilityStats => 'Mobility Stats';

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
}
