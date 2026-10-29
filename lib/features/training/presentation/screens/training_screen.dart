import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/profile/presentation/activity_save_failed.dart';
import 'package:muevete/features/training/presentation/providers/workout_completion_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:muevete/features/training/presentation/providers/workout_set_progress_provider.dart';
import 'package:muevete/features/training/presentation/widgets/hero/workout_hero.dart';
import 'package:muevete/features/training/presentation/widgets/panel/workout_sliding_panel.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/screens/error_screen.dart';
import 'package:muevete/shared/screens/loading_screen.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workoutAsync = ref.watch(workoutControllerProvider);

    return workoutAsync.when(
      data: (workout) {
        final setProgress = workoutSetProgressProvider(workout.exercises);
        // Keeps the ticked sets while the user moves between exercises.
        ref.watch(setProgress);
        return Scaffold(
          body: Stack(
            children: [
              WorkoutHero(workout: workout),
              WorkoutSlidingPanel(
                workout: workout,
                panelAnchorId: 'training.overview',
                firstExerciseAnchorId: 'training.openExercise',
                finishAnchorId: 'training.finishWorkout',
                onWorkoutFinished: () async {
                  ref
                      .read(walkthroughControllerProvider.notifier)
                      .onSignal(
                        const ActionReceipt(
                          WalkthroughAction.workoutFinishPressed,
                        ),
                      );
                  try {
                    await ref
                        .read(workoutCompletionProvider)
                        .complete(ref.read(setProgress.notifier).summary());
                  } catch (error) {
                    debugPrint('Could not save the workout: $error');
                    if (context.mounted) showActivitySaveFailed(context);
                    return;
                  }
                  // The next time this workout is done starts unticked.
                  ref.invalidate(setProgress);
                  ref.read(mainNavIndexProvider.notifier).setIndex(0);
                  if (context.mounted) {
                    context.go('/home');
                  }
                },
              ),
            ],
          ),
        );
      },
      loading: () => const LoadingScreen(),
      error: (error, _) => ErrorScreen(
        error,
        onRetry: () => ref.invalidate(workoutControllerProvider),
        retryLabel: l10n?.notifRetry ?? 'Retry',
      ),
    );
  }
}
