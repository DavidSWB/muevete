---
name: fitness-ui
description: >-
  Diseña, construye y mejora pantallas y componentes Flutter para la app de
  ejercicios guiados, movilidad y pausas activas (Muévete). Aplica principios de
  Glanceability (lectura a distancia), zona del pulgar (Thumb Zone), números
  tabulares para temporizadores, micro-interacciones a 60fps, feedback háptico y
  la regla 60/30/10. Usa esta skill al diseñar o refactorizar pantallas de
  entrenamiento, series, cronómetros, diagnóstico o progreso, o mediante
  /fitness-ui.
---

# Fitness & Guided Workout UI Skill (Muévete)

Esta skill de proyecto especializa al agente en el diseño e implementación de interfaces en **Flutter** para **Muévete** (entrenamiento guiado de movilidad, diagnóstico articular y pausas activas).

## Cuándo activar esta Skill

- Cuando el usuario invoque `/fitness-ui`.
- Al crear o modificar pantallas de ejercicios (`TrainingScreen`, `ExerciseDetailScreen`), pausas activas (`ActiveBreaksScreen`, `ActiveBreakTimerScreen`, `ActiveBreakWorkoutScreen`), diagnóstico (`DiagnosisScreen`) o progreso (`ProgressScreen`).
- Cuando se pida mejorar el diseño visual de cronómetros, tarjetas de ejercicios, reproductores de video/GIF o seguimiento de series.

---

## Principios de Diseño para Ejercicios Guiados

### 1. *Glanceability* (Legibilidad en Movimiento y a Distancia)
Durante un ejercicio o estiramiento, el usuario suele estar a **0.5m – 1.5m del teléfono**:
- **Números Tabulares en Temporizadores:** Todo contador de tiempo (`00:30`, `30s`) o repeticiones que cambie dinámicamente **debe** incluir `fontFeatures: const [FontFeature.tabularFigures()]` para evitar que el texto tiemble en cada segundo.
- **Jerarquía de Vistazo Rápido:**
  - Tiempo restante / Contador principal: `32px – 48px`, `FontWeight.w800`.
  - Título del ejercicio: `22px – 26px`, `FontWeight.w800`.
  - Pildoras de prescripción (*Sets × Reps / Duration / Rest*): texto claro con contenedor de contraste suave (`AppColors.cardBlue` o `AppColors.softGrey`).

### 2. Ergonomía de Zona del Pulgar (*Thumb Zone*)
Con el usuario en movimiento o con fatiga muscular, la precisión táctil disminuye:
- **Controles primarios en la zona inferior:** Botones como *Finalizar entrenamiento*, *Siguiente pregunta* o * ¡Listo! (Done)* deben ubicarse en `bottomNavigationBar` con `SafeArea` y altura mínima de `52px – 56px`.
- **Controles de serie (*Play/Pause* y *Check*):** Deben tener un área táctil mínima de `48x48 px` (`BoxConstraints(minWidth: 48, minHeight: 48)`).
- **Diferenciación clara de estados de una serie:**
  - **Pendiente:** Fondo `AppColors.surface`, borde `AppColors.border`.
  - **En curso (Timer activo):** Borde resaltado `AppColors.primaryDark`, fondo `AppColors.cardBlue`, indicador visual activo.
  - **Completada:** Icono `Icons.check_circle` en `AppColors.success` o `AppColors.primaryDark`, texto atenuado.

### 3. Protagonismo Visual del Ejercicio (Regla 60 / 30 / 10)
- **60% Superficie Neutra:** `AppColors.background` (`#F8FAFC`) y `AppColors.surface` (`#FFFFFF`) para que el video o GIF demostrativo sea el centro de atención sin ruido visual.
- **30% Superficies de Apoyo:** `AppColors.softGrey`, `AppColors.cardBlue` y `AppColors.cardOrange` para agrupar métricas, series y calendarios.
- **10% Acento de Acción y Éxito:** `AppColors.primaryDark` (`#0284C7`) para el CTA principal y controles activos, y `AppColors.success` (`#16A34A`) para entrenamientos y series completadas.
- **Contenedor de Video/GIF 16:9:** Mantener siempre relación de aspecto `16 / 9`, bordes redondeados (`16px – 20px`) y un estado *fallback* limpio si el recurso no está disponible.

### 4. Feedback Háptico y Micro-interacciones a 60fps
- **Haptics:** Disparar `HapticFeedback.lightImpact()` al marcar/desmarcar una serie o seleccionar una opción del diagnóstico, y `HapticFeedback.mediumImpact()` al completar un temporizador.
- **Transiciones suaves:** Usar `AnimatedContainer` (200ms, `Curves.easeOutCubic`) en tarjetas seleccionables (`MyQuizoptionButton`, `ExerciseSetRow`, `_PlanCard`) para que los cambios de color y borde se sientan fluidos.

---

## Reglas de Integración con el Proyecto Muévete

1. **Sistema de Tema:** Usa siempre `AppColors` (`lib/shared/theme/app_colors.dart`) y `AppTheme` (`lib/shared/theme/app_theme.dart`). Nunca declares colores hexadecimales sueltos en las vistas.
2. **Localización (`l10n`):** Usa `AppLocalizations.of(context)!` para textos de interfaz y `.localized(context, fallback: ...)` para mapas bilingües provenientes de Firestore (`exercise.name`, `workout.name`).
3. **Compatibilidad con Tests:** Preserva siempre las `ValueKey` existentes en los widgets:
   - `ValueKey('diagnosis-exercise-visual')`
   - `ValueKey('diagnosis-previous-button')`
   - `ValueKey('diagnosis-next-button')`
   - `ValueKey('exercise-visual')`
   - `ValueKey('exercise-title')`
   - `ValueKey('exercise-done-button')`

---

## Referencias y Patrones de Código

Consulta los patrones listos para usar en Flutter para temporizadores, filas de series y tarjetas de métricas en:
- [Patrones Flutter para Entrenamiento Guiado](./references/flutter_workout_patterns.md)
