// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Muévete';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authEmailHint => 'ejemplo@correo.com';

  @override
  String get authPasswordHint => 'Contraseña';

  @override
  String get authEnter => 'Entrar';

  @override
  String get authCreateAccountPrompt => 'Crear una cuenta nueva';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authAlreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get authCreateAccountTitle => 'Crear cuenta';

  @override
  String get authFullNameHint => 'Nombre completo';

  @override
  String get authAgeHint => 'Edad (ej. 25)';

  @override
  String get authWeightHint => 'Peso en kg (ej. 70.5)';

  @override
  String get authHeightHint => 'Altura en cm (ej. 175)';

  @override
  String get authMedicalConditionsHint => 'Condiciones médicas (opcional)';

  @override
  String get valEmptyEmailPassword =>
      'El correo y la contraseña no pueden estar vacíos.';

  @override
  String get valPasswordMinLength =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get valInvalidEmail =>
      'Por favor ingresa un correo electrónico válido.';

  @override
  String get valMandatoryFields =>
      'Todos los campos obligatorios deben completarse.';

  @override
  String get valInvalidAge => 'Por favor ingresa una edad válida (1-120).';

  @override
  String get valInvalidWeight => 'Por favor ingresa un peso válido en kg.';

  @override
  String get valInvalidHeight => 'Por favor ingresa una altura válida en cm.';

  @override
  String get errInvalidCredentials => 'Correo o contraseña inválidos.';

  @override
  String get errInvalidEmailFormat => 'El formato del correo es inválido.';

  @override
  String get errUserDisabled => 'Esta cuenta de usuario ha sido inhabilitada.';

  @override
  String get errTooManyRequests =>
      'Demasiados intentos fallidos. Inténtalo más tarde.';

  @override
  String get errNetwork => 'Error de red. Revisa tu conexión a internet.';

  @override
  String get errAuthFailed => 'Error de autenticación. Inténtalo de nuevo.';

  @override
  String get errEmailInUse => 'Este correo ya está en uso por otra cuenta.';

  @override
  String get errWeakPassword =>
      'La contraseña proporcionada es demasiado débil.';

  @override
  String get errUnexpected =>
      'Ocurrió un error inesperado. Inténtalo de nuevo.';

  @override
  String errGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navTraining => 'Entrenamiento';

  @override
  String get navProgress => 'Progreso';

  @override
  String get navSettings => 'Ajustes';

  @override
  String homeGreeting(String username) {
    return '¡Hola $username!';
  }

  @override
  String get homeSubGreeting => 'Sigamos en movimiento.';

  @override
  String get homeKeepProgress => '¡Mantén el progreso!';

  @override
  String get homeStayConsistent => 'Mantén la constancia con tu entrenamiento.';

  @override
  String get homeCompleted => 'Completados';

  @override
  String get homeOverallLevel => 'Nivel general';

  @override
  String get homeNextWorkout => 'Siguiente sesión';

  @override
  String get homeStartTraining => '¡Empieza a entrenar ahora!';

  @override
  String get homeActiveBreaks => 'Pausas activas';

  @override
  String get homeActiveBreaksDesc =>
      'Rutinas cortas para mantenerte en movimiento.';

  @override
  String get homeCouldNotLoadProfile => 'No se pudo cargar el perfil';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsChangeProgram => 'Cambiar programa de entrenamiento';

  @override
  String get settingsLogOut => 'Cerrar sesión';

  @override
  String get settingsLanguageSubtitle => 'Español';

  @override
  String get languageTitle => 'Seleccionar idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get notifSettingsTitle => 'Ajustes de notificaciones';

  @override
  String get notifDisabledTitle => 'Notificaciones desactivadas';

  @override
  String get notifDisabledDesc =>
      'Los permisos de notificaciones están desactivados en tu dispositivo. Muévete no podrá enviar recordatorios hasta que se habiliten los permisos.';

  @override
  String get notifRequestPermission => 'Solicitar permiso';

  @override
  String get notifTrainingReminders => 'Recordatorios de entrenamiento';

  @override
  String notifDays(String days) {
    return 'Días: $days';
  }

  @override
  String notifTime(String time) {
    return 'Hora: $time';
  }

  @override
  String get notifChangeSchedule =>
      'Cambiar horario en configuración del programa';

  @override
  String get notifNoActiveSchedule => 'Sin horario de entrenamiento activo';

  @override
  String get notifNoActiveScheduleDesc =>
      'Para habilitar los recordatorios, selecciona un plan de entrenamiento y configura tus días.';

  @override
  String get notifConfigureProgram => 'Configurar programa';

  @override
  String get notifActiveBreakReminders => 'Recordatorios de pausas activas';

  @override
  String get notifActiveBreakDesc =>
      'Recibe recordatorios para moverte durante el día en un horario configurable.';

  @override
  String get notifStartTime => 'Hora de inicio';

  @override
  String get notifEndTime => 'Hora de fin';

  @override
  String get notifRangeError =>
      'La hora de fin debe ser posterior a la de inicio en el mismo día.';

  @override
  String get notifInterval => 'Intervalo de recordatorio';

  @override
  String get notifMin60 => '60 min\n(1 hora)';

  @override
  String get notifMin120 => '120 min\n(2 horas)';

  @override
  String get notifMin180 => '180 min\n(3 horas)';

  @override
  String get notifSavePreferences => 'Guardar preferencias';

  @override
  String get notifSavedSuccess =>
      'Ajustes de notificaciones guardados correctamente.';

  @override
  String get notifSavedDisabledDevice =>
      'Ajustes guardados, pero las notificaciones están desactivadas en este dispositivo.';

  @override
  String get notifFailedLoadProfile => 'No se pudo cargar el perfil.';

  @override
  String get notifRetry => 'Reintentar';

  @override
  String get notifErrorSave =>
      'No se pudieron guardar los ajustes. Inténtalo de nuevo.';

  @override
  String get notifErrorSchedule =>
      'Se guardaron las preferencias, pero no se pudieron programar los recordatorios. Revisa los permisos y vuelve a intentarlo.';

  @override
  String get diagTitle => 'Diagnóstico';

  @override
  String get diagPrevious => 'Anterior';

  @override
  String get diagNext => 'Siguiente';

  @override
  String get diagFinish => 'Finalizar';

  @override
  String get diagConfirmFinish => '¿Seguro que deseas finalizar el test?';

  @override
  String get diagSomethingWentWrong => 'Lo sentimos, algo salió mal';

  @override
  String get diagSavedSuccess => '¡Diagnóstico guardado exitosamente!';

  @override
  String get diagAccept => 'Aceptar';

  @override
  String get progTitle => 'Programa de entrenamiento';

  @override
  String get progSelectSubtitle =>
      'Selecciona un programa para continuar al Inicio.';

  @override
  String get progSelectDays => 'Selecciona tus días de entrenamiento';

  @override
  String get progReminderTime => 'Hora del recordatorio';

  @override
  String get progRecoveryWarning =>
      '⚠️ Entrenar los mismos músculos en días consecutivos limita la recuperación. Considera dejar un intervalo de 48h.';

  @override
  String get progContinue => 'Continuar';

  @override
  String get progCouldNotLoad =>
      'No se pudieron cargar los programas de entrenamiento.';

  @override
  String get progNoPrograms => 'No hay programas de entrenamiento disponibles.';

  @override
  String get progCouldNotSave =>
      'No se pudo guardar el programa. Inténtalo de nuevo.';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get progressMobilityStats => 'Estadísticas de movilidad';

  @override
  String get progressShoulder => 'Hombro';

  @override
  String get progressHip => 'Cadera';

  @override
  String get progressKnee => 'Rodilla';

  @override
  String get progressAnkle => 'Tobillo';

  @override
  String get progressRetake => 'Repetir evaluación';

  @override
  String get abTitle => 'Pausas activas';

  @override
  String get abMotto => 'Más vale mover ese lindo cuerpo... o lo perderás.';

  @override
  String get abBrowseTitle => 'Pausas activas';

  @override
  String get abBrowseDesc =>
      'Elige una rutina rápida para mantenerte en movimiento.';

  @override
  String get abPersonalTimerTitle => 'Temporizador personal';

  @override
  String get abPersonalTimerDesc =>
      'Configura un temporizador para tu propia pausa.';

  @override
  String get abChooseTitle => 'Elige una pausa activa';

  @override
  String get abChooseRandom => 'Elegir al azar';

  @override
  String abDurationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String abTryToWalk(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'minutos',
      one: 'minuto',
    );
    return 'Intenta caminar durante $minutes $_temp0 después de 1 hora sentado.';
  }

  @override
  String get abComplete => '¡Pausa activa completada!';

  @override
  String get abStart => 'Iniciar';

  @override
  String get abPause => 'Pausar';

  @override
  String get abReset => 'Reiniciar';

  @override
  String get abMarkCompleted => 'Marcar como completada';

  @override
  String get abCompletedMarked => '¡Completada!';

  @override
  String get abCouldNotLoad => 'No se pudieron cargar las pausas activas.';

  @override
  String get abNoAvailable =>
      'No hay pausas activas disponibles en este momento.';

  @override
  String get notifTrainingTitle => '¡Hora de entrenar!';

  @override
  String notifTrainingBody(int session) {
    return 'Sesión $session: Tu entrenamiento programado está listo.';
  }

  @override
  String get notifActiveBreakTitle => 'Pausa activa';

  @override
  String get notifActiveBreakBody =>
      '¡Hora de moverte! Toma una pausa activa corta.';

  @override
  String get dayMonday => 'Lunes';

  @override
  String get dayTuesday => 'Martes';

  @override
  String get dayWednesday => 'Miércoles';

  @override
  String get dayThursday => 'Jueves';

  @override
  String get dayFriday => 'Viernes';

  @override
  String get daySaturday => 'Sábado';

  @override
  String get daySunday => 'Domingo';

  @override
  String get dayMonShort => 'Lun';

  @override
  String get dayTueShort => 'Mar';

  @override
  String get dayWedShort => 'Mié';

  @override
  String get dayThuShort => 'Jue';

  @override
  String get dayFriShort => 'Vie';

  @override
  String get daySatShort => 'Sáb';

  @override
  String get daySunShort => 'Dom';
}
