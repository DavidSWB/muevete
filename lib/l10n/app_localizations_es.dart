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
  String get errAccountExistsOtherProvider =>
      'Ya existe una cuenta con este correo. Por favor inicia sesión con tu método original.';

  @override
  String get errSignInCancelled => 'El inicio de sesión fue cancelado.';

  @override
  String get authSignInWithGoogle => 'Continuar con Google';

  @override
  String get authSignInWithApple => 'Continuar con Apple';

  @override
  String get authOrDivider => 'o';

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
  String get progressMobilityStats => 'Estadísticas por articulación';

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
  String get abMarkRoutineCompleted => 'Marcar pausa activa como completada';

  @override
  String get abRoutineCompleted => 'Completada';

  @override
  String get activitySaveFailed => 'No se pudo guardar. Inténtalo de nuevo.';

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
  String get exerciseDone => '¡Hecho!';

  @override
  String get exerciseNext => 'Siguiente';

  @override
  String get workoutFinish => 'Finalizar entrenamiento';

  @override
  String get exerciseSets => 'Series';

  @override
  String get exerciseReps => 'Repeticiones';

  @override
  String get exerciseRepsShort => 'Reps';

  @override
  String get exerciseRest => 'Descanso';

  @override
  String get exerciseDuration => 'Duración';

  @override
  String get exerciseStartTimer => 'Iniciar temporizador';

  @override
  String get exercisePauseTimer => 'Pausar temporizador';

  @override
  String get exerciseMarkSetComplete => 'Marcar serie como completada';

  @override
  String get exerciseMarkSetIncomplete => 'Marcar serie como pendiente';

  @override
  String exerciseSetCompleted(int number) {
    return 'Serie $number completada';
  }

  @override
  String exerciseSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
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
  String get tourPrevious => 'Anterior';

  @override
  String get tourNext => 'Siguiente';

  @override
  String get tourDone => 'Entendido';

  @override
  String get tourClose => 'Cerrar guía';

  @override
  String tourStepCounter(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get tourTapHighlighted => 'Toca el elemento resaltado para continuar';

  @override
  String get tourTryAgain => 'Reintentar';

  @override
  String get tourTargetMissing =>
      'No encontramos este elemento en la pantalla.';

  @override
  String get tourOneMoreBack => 'Una vez más: vuelve atrás';

  @override
  String get settingsReplayTour => 'Volver a ver la guía';

  @override
  String get settingsReplayTourSubtitle => 'Repasa la app paso a paso';

  @override
  String get tourHomeWelcomeTitle => 'Te damos la bienvenida a Muévete';

  @override
  String get tourHomeWelcomeBody =>
      'Te mostramos la app en unos minutos. Puedes cerrar la guía cuando quieras y volver a verla desde Ajustes.';

  @override
  String get tourHomeProfileTitle => 'Tu perfil';

  @override
  String get tourHomeProfileBody =>
      'Desde aquí llegas a tu perfil y a los ajustes. Los visitaremos al final de la guía.';

  @override
  String get tourHomeWeeklyStatsTitle => 'Tu semana';

  @override
  String get tourHomeWeeklyStatsBody =>
      'Aquí ves cuántos entrenamientos llevas esta semana y el tiempo estimado que has entrenado.';

  @override
  String get tourHomeHealthTitle => 'Tu salud también cuenta';

  @override
  String get tourHomeHealthBody =>
      'Un consejo breve para cuidar tu cuerpo. Esta tarjeta te lleva a tu progreso.';

  @override
  String get tourHomeStartWorkoutTitle => 'Empieza a entrenar';

  @override
  String get tourHomeStartWorkoutBody =>
      'Toca «Comenzar entrenamiento» para abrir tu próximo entrenamiento programado.';

  @override
  String get tourTrainingOverviewTitle => 'Tu entrenamiento';

  @override
  String get tourTrainingOverviewBody =>
      'Es una lista de ejercicios. Cada uno indica tus series y repeticiones, o cuánto tiempo mantener la posición.';

  @override
  String get tourTrainingOpenExerciseTitle => 'Abre un ejercicio';

  @override
  String get tourTrainingOpenExerciseBody =>
      'Toca el primero para ver cómo se hace.';

  @override
  String get tourExercisePrescriptionTitle => 'Qué te toca hacer';

  @override
  String get tourExercisePrescriptionBody =>
      'Aquí ves las series, las repeticiones (o la duración, si es un ejercicio de mantener la posición) y el descanso.';

  @override
  String get tourExerciseCompleteSetTitle => 'Marca tu primera serie';

  @override
  String get tourExerciseCompleteSetBody =>
      'Cuando termines una serie, márcala aquí. En los ejercicios de mantener la posición, espera a que termine el tiempo.';

  @override
  String get tourExerciseNextTitle => 'Pasa al siguiente';

  @override
  String get tourExerciseNextBody =>
      'Toca «Siguiente» para ir al próximo ejercicio de tu entrenamiento.';

  @override
  String get tourExerciseDoneTitle => 'Termina el ejercicio';

  @override
  String get tourExerciseDoneBody =>
      'Toca «¡Hecho!» para volver a la lista de ejercicios.';

  @override
  String get tourTrainingFinishWorkoutTitle => 'Finaliza el entrenamiento';

  @override
  String get tourTrainingFinishWorkoutBody =>
      'Toca «Finalizar entrenamiento». Es solo una práctica: no se guardará nada.';

  @override
  String get tourHomePracticeNoteTitle => 'No se guardó nada';

  @override
  String get tourHomePracticeNoteBody =>
      'Como era una práctica, tu semana sigue igual. Cuando finalices un entrenamiento de verdad, se sumará aquí.';

  @override
  String get tourNavOpenProgressTitle => 'Abre tu progreso';

  @override
  String get tourNavOpenProgressBody => 'Toca «Progreso» en la barra inferior.';

  @override
  String get tourProgressCalendarTitle => 'Tu calendario';

  @override
  String get tourProgressCalendarBody =>
      'Los días en verde son entrenamientos que terminaste de verdad. Aquí también ves cuántos llevas.';

  @override
  String get tourProgressJointStatsTitle => 'Estadísticas por articulación';

  @override
  String get tourProgressJointStatsBody =>
      'Tu nivel de movilidad en cada articulación, de 0 a 5. Se actualiza cuando repites la evaluación.';

  @override
  String get tourProgressRetakeTitle => 'Repite la evaluación';

  @override
  String get tourProgressRetakeBody =>
      'Toca el botón para abrirla. En la guía no enviaremos nada.';

  @override
  String get tourDiagnosisOverviewTitle => 'Tu evaluación física';

  @override
  String get tourDiagnosisOverviewBody =>
      'Con estas preguntas adaptamos tu programa a tu nivel. Ahora no hace falta responder nada.';

  @override
  String get tourDiagnosisLeaveTitle => 'Vuelve atrás';

  @override
  String get tourDiagnosisLeaveBody =>
      'Toca la flecha de volver para salir sin cambiar nada.';

  @override
  String get tourNavOpenHomeTitle => 'Vuelve al inicio';

  @override
  String get tourNavOpenHomeBody => 'Toca «Inicio» en la barra inferior.';

  @override
  String get tourHomeActiveBreaksTitle => 'Pausas activas';

  @override
  String get tourHomeActiveBreaksBody =>
      'Son rutinas cortas para romper con el tiempo sentado. Toca la sección para abrirlas.';

  @override
  String get tourAbOverviewTitle => 'Dos formas de moverte';

  @override
  String get tourAbOverviewBody =>
      'Elige una rutina de la lista o usa el temporizador. Las pausas activas son aparte de tu programa de entrenamiento.';

  @override
  String get tourAbOpenBrowseTitle => 'Explora las rutinas';

  @override
  String get tourAbOpenBrowseBody =>
      'Toca la opción para ver las rutinas disponibles.';

  @override
  String get tourAbBrowseListTitle => 'Elige una rutina';

  @override
  String get tourAbBrowseListBody =>
      'Escoge la que prefieras o usa el botón aleatorio para que la app elija por ti.';

  @override
  String get tourAbOpenRoutineTitle => 'Abre una rutina';

  @override
  String get tourAbOpenRoutineBody => 'Toca la primera para ver cómo es.';

  @override
  String get tourAbRoutineTitle => 'Así funciona una rutina';

  @override
  String get tourAbRoutineBody =>
      'Sigues los ejercicios uno por uno. En esta guía no la terminaremos.';

  @override
  String get tourAbBackToMenuTitle => 'Vuelve al menú';

  @override
  String get tourAbBackToMenuBody =>
      'Usa la flecha de volver hasta llegar al menú de pausas activas.';

  @override
  String get tourAbOpenTimerTitle => 'Prueba el temporizador';

  @override
  String get tourAbOpenTimerBody => 'Toca la opción del temporizador.';

  @override
  String get tourAbTimerExitTitle => 'El temporizador';

  @override
  String get tourAbTimerExitBody =>
      'Elige cuántos minutos y cuenta el tiempo de tu pausa. Toca la flecha de volver para continuar.';

  @override
  String get tourAbExitToHomeTitle => 'Sal de pausas activas';

  @override
  String get tourAbExitToHomeBody =>
      'Toca la flecha de volver para ir al inicio.';

  @override
  String get tourNavOpenSettingsTitle => 'Abre los ajustes';

  @override
  String get tourNavOpenSettingsBody => 'Toca «Ajustes» en la barra inferior.';

  @override
  String get tourSettingsLanguageTitle => 'Cambia de idioma';

  @override
  String get tourSettingsLanguageBody =>
      'Con este selector alternas entre español e inglés cuando quieras. La guía conserva el paso en el que estás.';

  @override
  String get tourSettingsReplayTitle => 'Vuelve a ver la guía';

  @override
  String get tourSettingsReplayBody =>
      'Puedes repetirla desde aquí cuando quieras. ¡A moverse!';

  @override
  String get tourInviteTitle => '¿Quieres hacer la guía de Muévete?';

  @override
  String get tourInviteBody =>
      'Te mostramos la app paso a paso. Si prefieres, la encuentras después en Ajustes → «Volver a ver la guía».';

  @override
  String get tourInviteStart => 'Empezar guía';

  @override
  String get tourInviteLater => 'Ahora no';

  @override
  String get tourInviteNever => 'No volver a preguntar';

  @override
  String get tourInviteNeverConfirm =>
      'Sin problema. Encontrarás la guía en Ajustes.';

  @override
  String get tourResumeTitle => 'Tu guía quedó a medias';

  @override
  String tourResumeBody(int current, int total) {
    return 'Estabas en el paso $current de $total. ¿Quieres continuar donde te quedaste o empezar de nuevo?';
  }

  @override
  String get tourResume => 'Continuar';

  @override
  String get tourStartOver => 'Empezar de nuevo';

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
