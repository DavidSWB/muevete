import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Muévete'**
  String get appName;

  /// No description provided for @authLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authLogin;

  /// No description provided for @authEmailHint.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordHint;

  /// No description provided for @authEnter.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get authEnter;

  /// No description provided for @authCreateAccountPrompt.
  ///
  /// In es, this message translates to:
  /// **'Crear una cuenta nueva'**
  String get authCreateAccountPrompt;

  /// No description provided for @authRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get authRegister;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes una cuenta? Inicia sesión'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccountTitle;

  /// No description provided for @authFullNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get authFullNameHint;

  /// No description provided for @authAgeHint.
  ///
  /// In es, this message translates to:
  /// **'Edad (ej. 25)'**
  String get authAgeHint;

  /// No description provided for @authWeightHint.
  ///
  /// In es, this message translates to:
  /// **'Peso en kg (ej. 70.5)'**
  String get authWeightHint;

  /// No description provided for @authHeightHint.
  ///
  /// In es, this message translates to:
  /// **'Altura en cm (ej. 175)'**
  String get authHeightHint;

  /// No description provided for @authMedicalConditionsHint.
  ///
  /// In es, this message translates to:
  /// **'Condiciones médicas (opcional)'**
  String get authMedicalConditionsHint;

  /// No description provided for @valEmptyEmailPassword.
  ///
  /// In es, this message translates to:
  /// **'El correo y la contraseña no pueden estar vacíos.'**
  String get valEmptyEmailPassword;

  /// No description provided for @valPasswordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres.'**
  String get valPasswordMinLength;

  /// No description provided for @valInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un correo electrónico válido.'**
  String get valInvalidEmail;

  /// No description provided for @valMandatoryFields.
  ///
  /// In es, this message translates to:
  /// **'Todos los campos obligatorios deben completarse.'**
  String get valMandatoryFields;

  /// No description provided for @valInvalidAge.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa una edad válida (1-120).'**
  String get valInvalidAge;

  /// No description provided for @valInvalidWeight.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un peso válido en kg.'**
  String get valInvalidWeight;

  /// No description provided for @valInvalidHeight.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa una altura válida en cm.'**
  String get valInvalidHeight;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña inválidos.'**
  String get errInvalidCredentials;

  /// No description provided for @errInvalidEmailFormat.
  ///
  /// In es, this message translates to:
  /// **'El formato del correo es inválido.'**
  String get errInvalidEmailFormat;

  /// No description provided for @errUserDisabled.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta de usuario ha sido inhabilitada.'**
  String get errUserDisabled;

  /// No description provided for @errTooManyRequests.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos fallidos. Inténtalo más tarde.'**
  String get errTooManyRequests;

  /// No description provided for @errNetwork.
  ///
  /// In es, this message translates to:
  /// **'Error de red. Revisa tu conexión a internet.'**
  String get errNetwork;

  /// No description provided for @errAuthFailed.
  ///
  /// In es, this message translates to:
  /// **'Error de autenticación. Inténtalo de nuevo.'**
  String get errAuthFailed;

  /// No description provided for @errEmailInUse.
  ///
  /// In es, this message translates to:
  /// **'Este correo ya está en uso por otra cuenta.'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña proporcionada es demasiado débil.'**
  String get errWeakPassword;

  /// No description provided for @errUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado. Inténtalo de nuevo.'**
  String get errUnexpected;

  /// No description provided for @errGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errGeneric(String error);

  /// No description provided for @errAccountExistsOtherProvider.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con este correo. Por favor inicia sesión con tu método original.'**
  String get errAccountExistsOtherProvider;

  /// No description provided for @errSignInCancelled.
  ///
  /// In es, this message translates to:
  /// **'El inicio de sesión fue cancelado.'**
  String get errSignInCancelled;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authSignInWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get authSignInWithApple;

  /// No description provided for @authOrDivider.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get authOrDivider;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navTraining.
  ///
  /// In es, this message translates to:
  /// **'Entrenamiento'**
  String get navTraining;

  /// No description provided for @navProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'¡Hola {username}!'**
  String homeGreeting(String username);

  /// No description provided for @homeSubGreeting.
  ///
  /// In es, this message translates to:
  /// **'Sigamos en movimiento.'**
  String get homeSubGreeting;

  /// No description provided for @homeKeepProgress.
  ///
  /// In es, this message translates to:
  /// **'¡Mantén el progreso!'**
  String get homeKeepProgress;

  /// No description provided for @homeStayConsistent.
  ///
  /// In es, this message translates to:
  /// **'Mantén la constancia con tu entrenamiento.'**
  String get homeStayConsistent;

  /// No description provided for @homeCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completados'**
  String get homeCompleted;

  /// No description provided for @homeOverallLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel general'**
  String get homeOverallLevel;

  /// No description provided for @homeNextWorkout.
  ///
  /// In es, this message translates to:
  /// **'Siguiente sesión'**
  String get homeNextWorkout;

  /// No description provided for @homeStartTraining.
  ///
  /// In es, this message translates to:
  /// **'¡Empieza a entrenar ahora!'**
  String get homeStartTraining;

  /// No description provided for @homeActiveBreaks.
  ///
  /// In es, this message translates to:
  /// **'Pausas activas'**
  String get homeActiveBreaks;

  /// No description provided for @homeActiveBreaksDesc.
  ///
  /// In es, this message translates to:
  /// **'Rutinas cortas para mantenerte en movimiento.'**
  String get homeActiveBreaksDesc;

  /// No description provided for @homeCouldNotLoadProfile.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el perfil'**
  String get homeCouldNotLoadProfile;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccount;

  /// No description provided for @settingsEditProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get settingsEditProfile;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsChangeProgram.
  ///
  /// In es, this message translates to:
  /// **'Cambiar programa de entrenamiento'**
  String get settingsChangeProgram;

  /// No description provided for @settingsLogOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsLogOut;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get languageTitle;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de notificaciones'**
  String get notifSettingsTitle;

  /// No description provided for @notifDisabledTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones desactivadas'**
  String get notifDisabledTitle;

  /// No description provided for @notifDisabledDesc.
  ///
  /// In es, this message translates to:
  /// **'Los permisos de notificaciones están desactivados en tu dispositivo. Muévete no podrá enviar recordatorios hasta que se habiliten los permisos.'**
  String get notifDisabledDesc;

  /// No description provided for @notifRequestPermission.
  ///
  /// In es, this message translates to:
  /// **'Solicitar permiso'**
  String get notifRequestPermission;

  /// No description provided for @notifTrainingReminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de entrenamiento'**
  String get notifTrainingReminders;

  /// No description provided for @notifDays.
  ///
  /// In es, this message translates to:
  /// **'Días: {days}'**
  String notifDays(String days);

  /// No description provided for @notifTime.
  ///
  /// In es, this message translates to:
  /// **'Hora: {time}'**
  String notifTime(String time);

  /// No description provided for @notifChangeSchedule.
  ///
  /// In es, this message translates to:
  /// **'Cambiar horario en configuración del programa'**
  String get notifChangeSchedule;

  /// No description provided for @notifNoActiveSchedule.
  ///
  /// In es, this message translates to:
  /// **'Sin horario de entrenamiento activo'**
  String get notifNoActiveSchedule;

  /// No description provided for @notifNoActiveScheduleDesc.
  ///
  /// In es, this message translates to:
  /// **'Para habilitar los recordatorios, selecciona un plan de entrenamiento y configura tus días.'**
  String get notifNoActiveScheduleDesc;

  /// No description provided for @notifConfigureProgram.
  ///
  /// In es, this message translates to:
  /// **'Configurar programa'**
  String get notifConfigureProgram;

  /// No description provided for @notifActiveBreakReminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de pausas activas'**
  String get notifActiveBreakReminders;

  /// No description provided for @notifActiveBreakDesc.
  ///
  /// In es, this message translates to:
  /// **'Recibe recordatorios para moverte durante el día en un horario configurable.'**
  String get notifActiveBreakDesc;

  /// No description provided for @notifStartTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de inicio'**
  String get notifStartTime;

  /// No description provided for @notifEndTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de fin'**
  String get notifEndTime;

  /// No description provided for @notifRangeError.
  ///
  /// In es, this message translates to:
  /// **'La hora de fin debe ser posterior a la de inicio en el mismo día.'**
  String get notifRangeError;

  /// No description provided for @notifInterval.
  ///
  /// In es, this message translates to:
  /// **'Intervalo de recordatorio'**
  String get notifInterval;

  /// No description provided for @notifMin60.
  ///
  /// In es, this message translates to:
  /// **'60 min\n(1 hora)'**
  String get notifMin60;

  /// No description provided for @notifMin120.
  ///
  /// In es, this message translates to:
  /// **'120 min\n(2 horas)'**
  String get notifMin120;

  /// No description provided for @notifMin180.
  ///
  /// In es, this message translates to:
  /// **'180 min\n(3 horas)'**
  String get notifMin180;

  /// No description provided for @notifSavePreferences.
  ///
  /// In es, this message translates to:
  /// **'Guardar preferencias'**
  String get notifSavePreferences;

  /// No description provided for @notifSavedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de notificaciones guardados correctamente.'**
  String get notifSavedSuccess;

  /// No description provided for @notifSavedDisabledDevice.
  ///
  /// In es, this message translates to:
  /// **'Ajustes guardados, pero las notificaciones están desactivadas en este dispositivo.'**
  String get notifSavedDisabledDevice;

  /// No description provided for @notifFailedLoadProfile.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el perfil.'**
  String get notifFailedLoadProfile;

  /// No description provided for @notifRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get notifRetry;

  /// No description provided for @notifErrorSave.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los ajustes. Inténtalo de nuevo.'**
  String get notifErrorSave;

  /// No description provided for @notifErrorSchedule.
  ///
  /// In es, this message translates to:
  /// **'Se guardaron las preferencias, pero no se pudieron programar los recordatorios. Revisa los permisos y vuelve a intentarlo.'**
  String get notifErrorSchedule;

  /// No description provided for @diagTitle.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico'**
  String get diagTitle;

  /// No description provided for @diagPrevious.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get diagPrevious;

  /// No description provided for @diagNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get diagNext;

  /// No description provided for @diagFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get diagFinish;

  /// No description provided for @diagConfirmFinish.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que deseas finalizar el test?'**
  String get diagConfirmFinish;

  /// No description provided for @diagSomethingWentWrong.
  ///
  /// In es, this message translates to:
  /// **'Lo sentimos, algo salió mal'**
  String get diagSomethingWentWrong;

  /// No description provided for @diagSavedSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Diagnóstico guardado exitosamente!'**
  String get diagSavedSuccess;

  /// No description provided for @diagAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get diagAccept;

  /// No description provided for @progTitle.
  ///
  /// In es, this message translates to:
  /// **'Programa de entrenamiento'**
  String get progTitle;

  /// No description provided for @progSelectSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un programa para continuar al Inicio.'**
  String get progSelectSubtitle;

  /// No description provided for @progSelectDays.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tus días de entrenamiento'**
  String get progSelectDays;

  /// No description provided for @progReminderTime.
  ///
  /// In es, this message translates to:
  /// **'Hora del recordatorio'**
  String get progReminderTime;

  /// No description provided for @progRecoveryWarning.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Entrenar los mismos músculos en días consecutivos limita la recuperación. Considera dejar un intervalo de 48h.'**
  String get progRecoveryWarning;

  /// No description provided for @progContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get progContinue;

  /// No description provided for @progCouldNotLoad.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los programas de entrenamiento.'**
  String get progCouldNotLoad;

  /// No description provided for @progNoPrograms.
  ///
  /// In es, this message translates to:
  /// **'No hay programas de entrenamiento disponibles.'**
  String get progNoPrograms;

  /// No description provided for @progCouldNotSave.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el programa. Inténtalo de nuevo.'**
  String get progCouldNotSave;

  /// No description provided for @progressTitle.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progressTitle;

  /// No description provided for @progressMobilityStats.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de movilidad'**
  String get progressMobilityStats;

  /// No description provided for @progressShoulder.
  ///
  /// In es, this message translates to:
  /// **'Hombro'**
  String get progressShoulder;

  /// No description provided for @progressHip.
  ///
  /// In es, this message translates to:
  /// **'Cadera'**
  String get progressHip;

  /// No description provided for @progressKnee.
  ///
  /// In es, this message translates to:
  /// **'Rodilla'**
  String get progressKnee;

  /// No description provided for @progressAnkle.
  ///
  /// In es, this message translates to:
  /// **'Tobillo'**
  String get progressAnkle;

  /// No description provided for @progressRetake.
  ///
  /// In es, this message translates to:
  /// **'Repetir evaluación'**
  String get progressRetake;

  /// No description provided for @abTitle.
  ///
  /// In es, this message translates to:
  /// **'Pausas activas'**
  String get abTitle;

  /// No description provided for @abMotto.
  ///
  /// In es, this message translates to:
  /// **'Más vale mover ese lindo cuerpo... o lo perderás.'**
  String get abMotto;

  /// No description provided for @abBrowseTitle.
  ///
  /// In es, this message translates to:
  /// **'Pausas activas'**
  String get abBrowseTitle;

  /// No description provided for @abBrowseDesc.
  ///
  /// In es, this message translates to:
  /// **'Elige una rutina rápida para mantenerte en movimiento.'**
  String get abBrowseDesc;

  /// No description provided for @abPersonalTimerTitle.
  ///
  /// In es, this message translates to:
  /// **'Temporizador personal'**
  String get abPersonalTimerTitle;

  /// No description provided for @abPersonalTimerDesc.
  ///
  /// In es, this message translates to:
  /// **'Configura un temporizador para tu propia pausa.'**
  String get abPersonalTimerDesc;

  /// No description provided for @abChooseTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una pausa activa'**
  String get abChooseTitle;

  /// No description provided for @abChooseRandom.
  ///
  /// In es, this message translates to:
  /// **'Elegir al azar'**
  String get abChooseRandom;

  /// No description provided for @abDurationMinutes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 minuto} other{{count} minutos}}'**
  String abDurationMinutes(int count);

  /// No description provided for @abTryToWalk.
  ///
  /// In es, this message translates to:
  /// **'Intenta caminar durante {minutes} {minutes, plural, =1{minuto} other{minutos}} después de 1 hora sentado.'**
  String abTryToWalk(int minutes);

  /// No description provided for @abComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Pausa activa completada!'**
  String get abComplete;

  /// No description provided for @abStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar'**
  String get abStart;

  /// No description provided for @abPause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get abPause;

  /// No description provided for @abReset.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get abReset;

  /// No description provided for @abMarkCompleted.
  ///
  /// In es, this message translates to:
  /// **'Marcar como completada'**
  String get abMarkCompleted;

  /// No description provided for @abCompletedMarked.
  ///
  /// In es, this message translates to:
  /// **'¡Completada!'**
  String get abCompletedMarked;

  /// No description provided for @abCouldNotLoad.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las pausas activas.'**
  String get abCouldNotLoad;

  /// No description provided for @abNoAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay pausas activas disponibles en este momento.'**
  String get abNoAvailable;

  /// No description provided for @notifTrainingTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Hora de entrenar!'**
  String get notifTrainingTitle;

  /// No description provided for @notifTrainingBody.
  ///
  /// In es, this message translates to:
  /// **'Sesión {session}: Tu entrenamiento programado está listo.'**
  String notifTrainingBody(int session);

  /// No description provided for @notifActiveBreakTitle.
  ///
  /// In es, this message translates to:
  /// **'Pausa activa'**
  String get notifActiveBreakTitle;

  /// No description provided for @notifActiveBreakBody.
  ///
  /// In es, this message translates to:
  /// **'¡Hora de moverte! Toma una pausa activa corta.'**
  String get notifActiveBreakBody;

  /// No description provided for @dayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get daySunday;

  /// No description provided for @dayMonShort.
  ///
  /// In es, this message translates to:
  /// **'Lun'**
  String get dayMonShort;

  /// No description provided for @dayTueShort.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get dayTueShort;

  /// No description provided for @dayWedShort.
  ///
  /// In es, this message translates to:
  /// **'Mié'**
  String get dayWedShort;

  /// No description provided for @dayThuShort.
  ///
  /// In es, this message translates to:
  /// **'Jue'**
  String get dayThuShort;

  /// No description provided for @dayFriShort.
  ///
  /// In es, this message translates to:
  /// **'Vie'**
  String get dayFriShort;

  /// No description provided for @daySatShort.
  ///
  /// In es, this message translates to:
  /// **'Sáb'**
  String get daySatShort;

  /// No description provided for @daySunShort.
  ///
  /// In es, this message translates to:
  /// **'Dom'**
  String get daySunShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
