# Patrones Flutter para Entrenamiento Guiado (Muévete)

## 1. Temporizador con Números Tabulares (*Glanceable Timer*)

Evita el salto horizontal de los dígitos cada segundo usando `FontFeature.tabularFigures()`:

```dart
import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class GlanceableTimerDisplay extends StatelessWidget {
  const GlanceableTimerDisplay({
    super.key,
    required this.formattedTime,
    required this.isRunning,
  });

  final String formattedTime;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isRunning ? AppColors.cardBlue : AppColors.softGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRunning ? AppColors.primaryDark : AppColors.border,
          width: isRunning ? 2 : 1,
        ),
      ),
      child: Text(
        formattedTime,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: isRunning ? AppColors.primaryDark : AppColors.textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
```

---

## 2. Fila de Serie Animada con Feedback Háptico (`ExerciseSetRow`)

Destaca visualmente la serie que está corriendo (`isRunning`) y la que ya fue completada (`isCompleted`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class AnimatedSetCard extends StatelessWidget {
  const AnimatedSetCard({
    super.key,
    required this.setNumber,
    required this.label,
    required this.value,
    required this.isCompleted,
    required this.isRunning,
    required this.onToggleCompleted,
  });

  final int setNumber;
  final String label;
  final String value;
  final bool isCompleted;
  final bool isRunning;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isRunning
        ? AppColors.cardBlue
        : isCompleted
            ? AppColors.successSoft.withValues(alpha: 0.45)
            : AppColors.surface;

    final borderColor = isRunning
        ? AppColors.primaryDark
        : isCompleted
            ? AppColors.success.withValues(alpha: 0.4)
            : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isRunning ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isRunning
                      ? AppColors.primaryDark
                      : AppColors.softGrey,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$setNumber',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: (isCompleted || isRunning)
                    ? Colors.white
                    : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onToggleCompleted();
            },
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isCompleted ? AppColors.success : AppColors.textMuted,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 3. Tarjetas de Prescripción (*Stat Pills*)

Agrupa *Sets*, *Reps*, *Rest* y *Duration* en píldoras visuales escaneables de un vistazo:

```dart
Widget buildPrescriptionPill({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.softGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
```
