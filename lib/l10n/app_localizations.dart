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

  /// No description provided for @navActiveBreaks.
  ///
  /// In es, this message translates to:
  /// **'Pausas'**
  String get navActiveBreaks;

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
  /// **'Preferencias guardadas y recordatorios actualizados.'**
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
  /// **'Se guardaron las preferencias, pero no se pudieron programar los recordatorios en este dispositivo. Vuelve a intentarlo.'**
  String get notifErrorSchedule;

  /// No description provided for @notifErrorScheduleNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Se guardaron las preferencias, pero los recordatorios no se pueden mostrar porque las notificaciones están desactivadas en este dispositivo. Actívalas y vuelve a guardar.'**
  String get notifErrorScheduleNoPermission;

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
  /// **'Estadísticas por articulación'**
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

  /// No description provided for @abMarkRoutineCompleted.
  ///
  /// In es, this message translates to:
  /// **'Marcar pausa activa como completada'**
  String get abMarkRoutineCompleted;

  /// No description provided for @abRoutineCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get abRoutineCompleted;

  /// No description provided for @activitySaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Inténtalo de nuevo.'**
  String get activitySaveFailed;

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

  /// No description provided for @exerciseDone.
  ///
  /// In es, this message translates to:
  /// **'¡Hecho!'**
  String get exerciseDone;

  /// No description provided for @exerciseNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get exerciseNext;

  /// No description provided for @workoutFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar entrenamiento'**
  String get workoutFinish;

  /// No description provided for @exerciseSets.
  ///
  /// In es, this message translates to:
  /// **'Series'**
  String get exerciseSets;

  /// No description provided for @exerciseReps.
  ///
  /// In es, this message translates to:
  /// **'Repeticiones'**
  String get exerciseReps;

  /// No description provided for @exerciseRepsShort.
  ///
  /// In es, this message translates to:
  /// **'Reps'**
  String get exerciseRepsShort;

  /// No description provided for @exerciseRest.
  ///
  /// In es, this message translates to:
  /// **'Descanso'**
  String get exerciseRest;

  /// No description provided for @exerciseDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get exerciseDuration;

  /// No description provided for @exerciseStartTimer.
  ///
  /// In es, this message translates to:
  /// **'Iniciar temporizador'**
  String get exerciseStartTimer;

  /// No description provided for @exercisePauseTimer.
  ///
  /// In es, this message translates to:
  /// **'Pausar temporizador'**
  String get exercisePauseTimer;

  /// No description provided for @exerciseMarkSetComplete.
  ///
  /// In es, this message translates to:
  /// **'Marcar serie como completada'**
  String get exerciseMarkSetComplete;

  /// No description provided for @exerciseMarkSetIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Marcar serie como pendiente'**
  String get exerciseMarkSetIncomplete;

  /// No description provided for @exerciseSetCompleted.
  ///
  /// In es, this message translates to:
  /// **'Serie {number} completada'**
  String exerciseSetCompleted(int number);

  /// No description provided for @exerciseSetCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 serie} other{{count} series}}'**
  String exerciseSetCount(int count);

  /// No description provided for @exerciseVolumeReps.
  ///
  /// In es, this message translates to:
  /// **'{sets} × {reps} reps'**
  String exerciseVolumeReps(String sets, int reps);

  /// No description provided for @exerciseVolumeDuration.
  ///
  /// In es, this message translates to:
  /// **'{sets} × {seconds}s'**
  String exerciseVolumeDuration(String sets, int seconds);

  /// No description provided for @tourPrevious.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get tourPrevious;

  /// No description provided for @tourNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tourNext;

  /// No description provided for @tourDone.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get tourDone;

  /// No description provided for @tourClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar guía'**
  String get tourClose;

  /// No description provided for @tourStepCounter.
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String tourStepCounter(int current, int total);

  /// No description provided for @tourTapHighlighted.
  ///
  /// In es, this message translates to:
  /// **'Toca el elemento resaltado para continuar'**
  String get tourTapHighlighted;

  /// No description provided for @tourTryAgain.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get tourTryAgain;

  /// No description provided for @tourTargetMissing.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este elemento en la pantalla.'**
  String get tourTargetMissing;

  /// No description provided for @tourOneMoreBack.
  ///
  /// In es, this message translates to:
  /// **'Una vez más: vuelve atrás'**
  String get tourOneMoreBack;

  /// No description provided for @settingsReplayTour.
  ///
  /// In es, this message translates to:
  /// **'Volver a ver la guía'**
  String get settingsReplayTour;

  /// No description provided for @settingsReplayTourSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Repasa la app paso a paso'**
  String get settingsReplayTourSubtitle;

  /// No description provided for @tourHomeWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Te damos la bienvenida a Muévete'**
  String get tourHomeWelcomeTitle;

  /// No description provided for @tourHomeWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Te mostramos la app en unos minutos. Puedes cerrar la guía cuando quieras y volver a verla desde Ajustes.'**
  String get tourHomeWelcomeBody;

  /// No description provided for @tourHomeProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil'**
  String get tourHomeProfileTitle;

  /// No description provided for @tourHomeProfileBody.
  ///
  /// In es, this message translates to:
  /// **'Desde aquí llegas a tu perfil y a los ajustes. Los visitaremos al final de la guía.'**
  String get tourHomeProfileBody;

  /// No description provided for @tourHomeWeeklyStatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu semana'**
  String get tourHomeWeeklyStatsTitle;

  /// No description provided for @tourHomeWeeklyStatsBody.
  ///
  /// In es, this message translates to:
  /// **'Aquí ves cuántos entrenamientos llevas esta semana y el tiempo estimado que has entrenado.'**
  String get tourHomeWeeklyStatsBody;

  /// No description provided for @tourHomeHealthTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu salud también cuenta'**
  String get tourHomeHealthTitle;

  /// No description provided for @tourHomeHealthBody.
  ///
  /// In es, this message translates to:
  /// **'Un consejo breve para cuidar tu cuerpo. Esta tarjeta te lleva a tu progreso.'**
  String get tourHomeHealthBody;

  /// No description provided for @tourHomeStartWorkoutTitle.
  ///
  /// In es, this message translates to:
  /// **'Empieza a entrenar'**
  String get tourHomeStartWorkoutTitle;

  /// No description provided for @tourHomeStartWorkoutBody.
  ///
  /// In es, this message translates to:
  /// **'Toca «Comenzar entrenamiento» para abrir tu próximo entrenamiento programado.'**
  String get tourHomeStartWorkoutBody;

  /// No description provided for @tourTrainingOverviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu entrenamiento'**
  String get tourTrainingOverviewTitle;

  /// No description provided for @tourTrainingOverviewBody.
  ///
  /// In es, this message translates to:
  /// **'Es una lista de ejercicios. Cada uno indica tus series y repeticiones, o cuánto tiempo mantener la posición.'**
  String get tourTrainingOverviewBody;

  /// No description provided for @tourTrainingOpenExerciseTitle.
  ///
  /// In es, this message translates to:
  /// **'Abre un ejercicio'**
  String get tourTrainingOpenExerciseTitle;

  /// No description provided for @tourTrainingOpenExerciseBody.
  ///
  /// In es, this message translates to:
  /// **'Toca el primero para ver cómo se hace.'**
  String get tourTrainingOpenExerciseBody;

  /// No description provided for @tourExercisePrescriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Qué te toca hacer'**
  String get tourExercisePrescriptionTitle;

  /// No description provided for @tourExercisePrescriptionBody.
  ///
  /// In es, this message translates to:
  /// **'Aquí ves las series, las repeticiones (o la duración, si es un ejercicio de mantener la posición) y el descanso.'**
  String get tourExercisePrescriptionBody;

  /// No description provided for @tourExerciseCompleteSetTitle.
  ///
  /// In es, this message translates to:
  /// **'Marca tu primera serie'**
  String get tourExerciseCompleteSetTitle;

  /// No description provided for @tourExerciseCompleteSetBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando termines una serie, márcala aquí. En los ejercicios de mantener la posición, espera a que termine el tiempo.'**
  String get tourExerciseCompleteSetBody;

  /// No description provided for @tourExerciseNextTitle.
  ///
  /// In es, this message translates to:
  /// **'Pasa al siguiente'**
  String get tourExerciseNextTitle;

  /// No description provided for @tourExerciseNextBody.
  ///
  /// In es, this message translates to:
  /// **'Toca «Siguiente» para ir al próximo ejercicio de tu entrenamiento.'**
  String get tourExerciseNextBody;

  /// No description provided for @tourExerciseDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Termina el ejercicio'**
  String get tourExerciseDoneTitle;

  /// No description provided for @tourExerciseDoneBody.
  ///
  /// In es, this message translates to:
  /// **'Toca «¡Hecho!» para volver a la lista de ejercicios.'**
  String get tourExerciseDoneBody;

  /// No description provided for @tourTrainingFinishWorkoutTitle.
  ///
  /// In es, this message translates to:
  /// **'Finaliza el entrenamiento'**
  String get tourTrainingFinishWorkoutTitle;

  /// No description provided for @tourTrainingFinishWorkoutBody.
  ///
  /// In es, this message translates to:
  /// **'Toca «Finalizar entrenamiento». Es solo una práctica: no se guardará nada.'**
  String get tourTrainingFinishWorkoutBody;

  /// No description provided for @tourHomePracticeNoteTitle.
  ///
  /// In es, this message translates to:
  /// **'No se guardó nada'**
  String get tourHomePracticeNoteTitle;

  /// No description provided for @tourHomePracticeNoteBody.
  ///
  /// In es, this message translates to:
  /// **'Como era una práctica, tu semana sigue igual. Cuando finalices un entrenamiento de verdad, se sumará aquí.'**
  String get tourHomePracticeNoteBody;

  /// No description provided for @tourNavOpenProgressTitle.
  ///
  /// In es, this message translates to:
  /// **'Abre tu progreso'**
  String get tourNavOpenProgressTitle;

  /// No description provided for @tourNavOpenProgressBody.
  ///
  /// In es, this message translates to:
  /// **'Toca «Progreso» en la barra inferior.'**
  String get tourNavOpenProgressBody;

  /// No description provided for @tourProgressCalendarTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu calendario'**
  String get tourProgressCalendarTitle;

  /// No description provided for @tourProgressCalendarBody.
  ///
  /// In es, this message translates to:
  /// **'Los días en verde son entrenamientos que terminaste de verdad. Aquí también ves cuántos llevas.'**
  String get tourProgressCalendarBody;

  /// No description provided for @tourProgressJointStatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas por articulación'**
  String get tourProgressJointStatsTitle;

  /// No description provided for @tourProgressJointStatsBody.
  ///
  /// In es, this message translates to:
  /// **'Tu nivel de movilidad en cada articulación, de 0 a 5. Se actualiza cuando repites la evaluación.'**
  String get tourProgressJointStatsBody;

  /// No description provided for @tourProgressRetakeTitle.
  ///
  /// In es, this message translates to:
  /// **'Repite la evaluación'**
  String get tourProgressRetakeTitle;

  /// No description provided for @tourProgressRetakeBody.
  ///
  /// In es, this message translates to:
  /// **'Toca el botón para abrirla. En la guía no enviaremos nada.'**
  String get tourProgressRetakeBody;

  /// No description provided for @tourDiagnosisOverviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu evaluación física'**
  String get tourDiagnosisOverviewTitle;

  /// No description provided for @tourDiagnosisOverviewBody.
  ///
  /// In es, this message translates to:
  /// **'Con estas preguntas adaptamos tu programa a tu nivel. Ahora no hace falta responder nada.'**
  String get tourDiagnosisOverviewBody;

  /// No description provided for @tourDiagnosisLeaveTitle.
  ///
  /// In es, this message translates to:
  /// **'Vuelve atrás'**
  String get tourDiagnosisLeaveTitle;

  /// No description provided for @tourDiagnosisLeaveBody.
  ///
  /// In es, this message translates to:
  /// **'Toca la flecha de volver para salir sin cambiar nada.'**
  String get tourDiagnosisLeaveBody;

  /// No description provided for @tourNavOpenHomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Vuelve al inicio'**
  String get tourNavOpenHomeTitle;

  /// No description provided for @tourNavOpenHomeBody.
  ///
  /// In es, this message translates to:
  /// **'Toca «Inicio» en la barra inferior.'**
  String get tourNavOpenHomeBody;

  /// No description provided for @tourHomeActiveBreaksTitle.
  ///
  /// In es, this message translates to:
  /// **'Pausas activas'**
  String get tourHomeActiveBreaksTitle;

  /// No description provided for @tourHomeActiveBreaksBody.
  ///
  /// In es, this message translates to:
  /// **'Son rutinas cortas para romper con el tiempo sentado. Toca la sección para abrirlas.'**
  String get tourHomeActiveBreaksBody;

  /// No description provided for @tourAbOverviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Dos formas de moverte'**
  String get tourAbOverviewTitle;

  /// No description provided for @tourAbOverviewBody.
  ///
  /// In es, this message translates to:
  /// **'Elige una rutina de la lista o usa el temporizador. Las pausas activas son aparte de tu programa de entrenamiento.'**
  String get tourAbOverviewBody;

  /// No description provided for @tourAbOpenBrowseTitle.
  ///
  /// In es, this message translates to:
  /// **'Explora las rutinas'**
  String get tourAbOpenBrowseTitle;

  /// No description provided for @tourAbOpenBrowseBody.
  ///
  /// In es, this message translates to:
  /// **'Toca la opción para ver las rutinas disponibles.'**
  String get tourAbOpenBrowseBody;

  /// No description provided for @tourAbBrowseListTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una rutina'**
  String get tourAbBrowseListTitle;

  /// No description provided for @tourAbBrowseListBody.
  ///
  /// In es, this message translates to:
  /// **'Escoge la que prefieras o usa el botón aleatorio para que la app elija por ti.'**
  String get tourAbBrowseListBody;

  /// No description provided for @tourAbOpenRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Abre una rutina'**
  String get tourAbOpenRoutineTitle;

  /// No description provided for @tourAbOpenRoutineBody.
  ///
  /// In es, this message translates to:
  /// **'Toca la primera para ver cómo es.'**
  String get tourAbOpenRoutineBody;

  /// No description provided for @tourAbRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Así funciona una rutina'**
  String get tourAbRoutineTitle;

  /// No description provided for @tourAbRoutineBody.
  ///
  /// In es, this message translates to:
  /// **'Sigues los ejercicios uno por uno. En esta guía no la terminaremos.'**
  String get tourAbRoutineBody;

  /// No description provided for @tourAbBackToMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Vuelve al menú'**
  String get tourAbBackToMenuTitle;

  /// No description provided for @tourAbBackToMenuBody.
  ///
  /// In es, this message translates to:
  /// **'Usa la flecha de volver hasta llegar al menú de pausas activas.'**
  String get tourAbBackToMenuBody;

  /// No description provided for @tourAbOpenTimerTitle.
  ///
  /// In es, this message translates to:
  /// **'Prueba el temporizador'**
  String get tourAbOpenTimerTitle;

  /// No description provided for @tourAbOpenTimerBody.
  ///
  /// In es, this message translates to:
  /// **'Toca la opción del temporizador.'**
  String get tourAbOpenTimerBody;

  /// No description provided for @tourAbTimerExitTitle.
  ///
  /// In es, this message translates to:
  /// **'El temporizador'**
  String get tourAbTimerExitTitle;

  /// No description provided for @tourAbTimerExitBody.
  ///
  /// In es, this message translates to:
  /// **'Elige cuántos minutos y cuenta el tiempo de tu pausa. Toca la flecha de volver para continuar.'**
  String get tourAbTimerExitBody;

  /// No description provided for @tourAbExitToHomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Sal de pausas activas'**
  String get tourAbExitToHomeTitle;

  /// No description provided for @tourAbExitToHomeBody.
  ///
  /// In es, this message translates to:
  /// **'Toca la flecha de volver para ir al inicio.'**
  String get tourAbExitToHomeBody;

  /// No description provided for @tourNavOpenSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Abre los ajustes'**
  String get tourNavOpenSettingsTitle;

  /// No description provided for @tourNavOpenSettingsBody.
  ///
  /// In es, this message translates to:
  /// **'Toca «Ajustes» en la barra inferior.'**
  String get tourNavOpenSettingsBody;

  /// No description provided for @tourSettingsLanguageTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambia de idioma'**
  String get tourSettingsLanguageTitle;

  /// No description provided for @tourSettingsLanguageBody.
  ///
  /// In es, this message translates to:
  /// **'Con este selector alternas entre español e inglés cuando quieras. La guía conserva el paso en el que estás.'**
  String get tourSettingsLanguageBody;

  /// No description provided for @tourSettingsReplayTitle.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a ver la guía'**
  String get tourSettingsReplayTitle;

  /// No description provided for @tourSettingsReplayBody.
  ///
  /// In es, this message translates to:
  /// **'Puedes repetirla desde aquí cuando quieras. ¡A moverse!'**
  String get tourSettingsReplayBody;

  /// No description provided for @tourInviteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres hacer la guía de Muévete?'**
  String get tourInviteTitle;

  /// No description provided for @tourInviteBody.
  ///
  /// In es, this message translates to:
  /// **'Te mostramos la app paso a paso. Si prefieres, la encuentras después en Ajustes → «Volver a ver la guía».'**
  String get tourInviteBody;

  /// No description provided for @tourInviteStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar guía'**
  String get tourInviteStart;

  /// No description provided for @tourInviteLater.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get tourInviteLater;

  /// No description provided for @tourInviteNever.
  ///
  /// In es, this message translates to:
  /// **'No volver a preguntar'**
  String get tourInviteNever;

  /// No description provided for @tourInviteNeverConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sin problema. Encontrarás la guía en Ajustes.'**
  String get tourInviteNeverConfirm;

  /// No description provided for @tourResumeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu guía quedó a medias'**
  String get tourResumeTitle;

  /// No description provided for @tourResumeBody.
  ///
  /// In es, this message translates to:
  /// **'Estabas en el paso {current} de {total}. ¿Quieres continuar donde te quedaste o empezar de nuevo?'**
  String tourResumeBody(int current, int total);

  /// No description provided for @tourResume.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get tourResume;

  /// No description provided for @tourStartOver.
  ///
  /// In es, this message translates to:
  /// **'Empezar de nuevo'**
  String get tourStartOver;

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

  /// No description provided for @authSexLabel.
  ///
  /// In es, this message translates to:
  /// **'Sexo biológico'**
  String get authSexLabel;

  /// No description provided for @sexMale.
  ///
  /// In es, this message translates to:
  /// **'Hombre'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get sexFemale;

  /// No description provided for @valSelectSex.
  ///
  /// In es, this message translates to:
  /// **'Por favor selecciona tu sexo biológico.'**
  String get valSelectSex;

  /// No description provided for @editProfileEmailReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Tu correo no se puede cambiar aquí.'**
  String get editProfileEmailReadOnly;

  /// No description provided for @editProfileSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get editProfileSave;

  /// No description provided for @editProfileSaved.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado.'**
  String get editProfileSaved;

  /// No description provided for @editProfileSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu perfil. Inténtalo de nuevo.'**
  String get editProfileSaveFailed;

  /// No description provided for @homeTodayWorkoutBadge.
  ///
  /// In es, this message translates to:
  /// **'TU ENTRENAMIENTO DE HOY'**
  String get homeTodayWorkoutBadge;

  /// No description provided for @homeWorkoutDescription.
  ///
  /// In es, this message translates to:
  /// **'Una rutina completa para activar tu cuerpo y mejorar tu condición física.'**
  String get homeWorkoutDescription;

  /// No description provided for @homeStartWorkoutCta.
  ///
  /// In es, this message translates to:
  /// **'Comenzar\nentrenamiento'**
  String get homeStartWorkoutCta;

  /// No description provided for @homeDoneEarly.
  ///
  /// In es, this message translates to:
  /// **'Hecho antes'**
  String get homeDoneEarly;

  /// No description provided for @homeRestDayBadge.
  ///
  /// In es, this message translates to:
  /// **'DÍA DE DESCANSO'**
  String get homeRestDayBadge;

  /// No description provided for @homeRestDayTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Día ligero!'**
  String get homeRestDayTitle;

  /// No description provided for @homeRestDayDescription.
  ///
  /// In es, this message translates to:
  /// **'Hoy toca recuperarte. Mantente activo con movimientos suaves durante el día.'**
  String get homeRestDayDescription;

  /// No description provided for @homeRestDayActiveBreak.
  ///
  /// In es, this message translates to:
  /// **'Hacer una pausa activa'**
  String get homeRestDayActiveBreak;

  /// No description provided for @homeRestDayAdvance.
  ///
  /// In es, this message translates to:
  /// **'Adelantar próximo entrenamiento'**
  String get homeRestDayAdvance;

  /// No description provided for @measureAgeTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuántos años tienes?'**
  String get measureAgeTitle;

  /// No description provided for @measureWeightTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto pesas?'**
  String get measureWeightTitle;

  /// No description provided for @measureHeightTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto mides?'**
  String get measureHeightTitle;

  /// No description provided for @profileAgeLabel.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get profileAgeLabel;

  /// No description provided for @profileWeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get profileWeightLabel;

  /// No description provided for @profileHeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Altura'**
  String get profileHeightLabel;

  /// No description provided for @unitYears.
  ///
  /// In es, this message translates to:
  /// **'años'**
  String get unitYears;

  /// No description provided for @unitKg.
  ///
  /// In es, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitLbs.
  ///
  /// In es, this message translates to:
  /// **'lbs'**
  String get unitLbs;

  /// No description provided for @unitCm.
  ///
  /// In es, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @commonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get commonDone;

  /// No description provided for @timePickerHour.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get timePickerHour;

  /// No description provided for @timePickerMinute.
  ///
  /// In es, this message translates to:
  /// **'Minutos'**
  String get timePickerMinute;

  /// No description provided for @tourHomeMissionTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuestra misión'**
  String get tourHomeMissionTitle;

  /// No description provided for @tourHomeMissionBody.
  ///
  /// In es, this message translates to:
  /// **'Muévete te ayuda a pasar menos tiempo sentado y a moverte más cada día, con entrenamientos guiados y pausas activas cortas.'**
  String get tourHomeMissionBody;

  /// No description provided for @tourHomeHabitsTitle.
  ///
  /// In es, this message translates to:
  /// **'Un hábito que crece contigo'**
  String get tourHomeHabitsTitle;

  /// No description provided for @tourHomeHabitsBody.
  ///
  /// In es, this message translates to:
  /// **'Los entrenamientos y las pausas activas te ayudan a crear el hábito de moverte. Los ejercicios se adaptan a tu nivel y pueden avanzar contigo cuando repites la evaluación.'**
  String get tourHomeHabitsBody;

  /// No description provided for @tipTypeTip.
  ///
  /// In es, this message translates to:
  /// **'CONSEJO'**
  String get tipTypeTip;

  /// No description provided for @tipTypeEvidence.
  ///
  /// In es, this message translates to:
  /// **'LO QUE DICE LA EVIDENCIA'**
  String get tipTypeEvidence;

  /// No description provided for @tipDismiss.
  ///
  /// In es, this message translates to:
  /// **'Cerrar consejo'**
  String get tipDismiss;

  /// No description provided for @tipSource.
  ///
  /// In es, this message translates to:
  /// **'Fuente: {source}'**
  String tipSource(String source);

  /// No description provided for @tipOpenSource.
  ///
  /// In es, this message translates to:
  /// **'Abrir la fuente: {source}'**
  String tipOpenSource(String source);

  /// No description provided for @tipSourceFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el enlace. Inténtalo de nuevo más tarde.'**
  String get tipSourceFailed;

  /// No description provided for @settingsTips.
  ///
  /// In es, this message translates to:
  /// **'Consejos de salud'**
  String get settingsTips;

  /// No description provided for @settingsTipsDaily.
  ///
  /// In es, this message translates to:
  /// **'Uno al día'**
  String get settingsTipsDaily;

  /// No description provided for @settingsTipsEveryOpen.
  ///
  /// In es, this message translates to:
  /// **'Cada vez que abro la app'**
  String get settingsTipsEveryOpen;

  /// No description provided for @settingsTipsOff.
  ///
  /// In es, this message translates to:
  /// **'Desactivados'**
  String get settingsTipsOff;

  /// No description provided for @progressMovementTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu progreso de movimiento'**
  String get progressMovementTitle;

  /// No description provided for @progressMovementXp.
  ///
  /// In es, this message translates to:
  /// **'{xp} XP'**
  String progressMovementXp(int xp);

  /// No description provided for @progressMovementXpHint.
  ///
  /// In es, this message translates to:
  /// **'Sumas XP al completar entrenamientos y pausas activas. No cambia la dificultad de tus ejercicios.'**
  String get progressMovementXpHint;

  /// No description provided for @progressJointHint.
  ///
  /// In es, this message translates to:
  /// **'Cada serie completada suma puntos a las articulaciones que trabaja.'**
  String get progressJointHint;

  /// No description provided for @progressJointLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}'**
  String progressJointLevel(int level);

  /// No description provided for @progressJointPoints.
  ///
  /// In es, this message translates to:
  /// **'{points}/{next} pts'**
  String progressJointPoints(int points, int next);

  /// No description provided for @progressJointMaxLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel máximo'**
  String get progressJointMaxLevel;

  /// No description provided for @progressJointLevelLabel.
  ///
  /// In es, this message translates to:
  /// **'{joint}: nivel {level}, {points} de {next} puntos'**
  String progressJointLevelLabel(String joint, int level, int points, int next);

  /// No description provided for @progressJointMaxLevelLabel.
  ///
  /// In es, this message translates to:
  /// **'{joint}: nivel {level}, nivel máximo'**
  String progressJointMaxLevelLabel(String joint, int level);

  /// No description provided for @progressMedalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus medallas'**
  String get progressMedalsTitle;

  /// No description provided for @progressMedalsCount.
  ///
  /// In es, this message translates to:
  /// **'{unlocked} de {total}'**
  String progressMedalsCount(int unlocked, int total);

  /// No description provided for @progressMedalUnlockedLabel.
  ///
  /// In es, this message translates to:
  /// **'{name}: medalla desbloqueada'**
  String progressMedalUnlockedLabel(String name);

  /// No description provided for @progressMedalLockedLabel.
  ///
  /// In es, this message translates to:
  /// **'{name}: medalla bloqueada. {hint}'**
  String progressMedalLockedLabel(String name, String hint);

  /// No description provided for @progressMedalsLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando medallas'**
  String get progressMedalsLoading;

  /// No description provided for @progressMedalsError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las medallas.'**
  String get progressMedalsError;

  /// No description provided for @homeWeeklyBreaksCount.
  ///
  /// In es, this message translates to:
  /// **'{count}/{goal}'**
  String homeWeeklyBreaksCount(int count, int goal);

  /// No description provided for @homeWeeklyBreaksCaption.
  ///
  /// In es, this message translates to:
  /// **'pausas esta semana'**
  String get homeWeeklyBreaksCaption;

  /// No description provided for @homeWeeklyBreaksLabel.
  ///
  /// In es, this message translates to:
  /// **'{count} de {goal} pausas activas esta semana'**
  String homeWeeklyBreaksLabel(int count, int goal);

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get settingsPrivacyPolicy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In es, this message translates to:
  /// **'Política de tratamiento de datos personales'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyVersionLabel.
  ///
  /// In es, this message translates to:
  /// **'Versión vigente: {version}'**
  String privacyPolicyVersionLabel(String version);

  /// No description provided for @privacyConsentCheckbox.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto la política de tratamiento de datos personales, incluida la transferencia de mis datos a servidores de Google en Estados Unidos.'**
  String get privacyConsentCheckbox;

  /// No description provided for @privacyReadPolicy.
  ///
  /// In es, this message translates to:
  /// **'Leer la política'**
  String get privacyReadPolicy;

  /// No description provided for @valPrivacyRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar la política y autorizar el tratamiento de tus datos de salud para continuar.'**
  String get valPrivacyRequired;

  /// No description provided for @privacyConsentTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa nuestra política de datos'**
  String get privacyConsentTitle;

  /// No description provided for @privacyConsentBody.
  ///
  /// In es, this message translates to:
  /// **'Para seguir usando Muévete debes revisar y aceptar la política de tratamiento de datos personales vigente. Si no la aceptas ahora, tus datos no se borran.'**
  String get privacyConsentBody;

  /// No description provided for @privacyConsentAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y continuar'**
  String get privacyConsentAccept;

  /// No description provided for @privacyConsentSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu aceptación. Revisa tu conexión e inténtalo de nuevo.'**
  String get privacyConsentSaveFailed;

  /// No description provided for @privacyHealthConsentCheckbox.
  ///
  /// In es, this message translates to:
  /// **'Autorizo de forma expresa el tratamiento de mis datos de salud (diagnóstico de movilidad y condiciones médicas que registre) para las finalidades descritas en la política. Sé que, por ser datos sensibles, no estoy obligado a autorizarlo.'**
  String get privacyHealthConsentCheckbox;
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
