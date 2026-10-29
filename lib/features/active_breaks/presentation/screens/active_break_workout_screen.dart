import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/presentation/providers/active_break_providers.dart';
import 'package:muevete/features/profile/presentation/activity_save_failed.dart';
import 'package:muevete/features/training/presentation/providers/workout_set_progress_provider.dart';
import 'package:muevete/features/training/presentation/widgets/hero/workout_hero.dart';
import 'package:muevete/features/training/presentation/widgets/panel/workout_sliding_panel.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/screens/loading_screen.dart';

class ActiveBreakWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveBreakWorkoutScreen({super.key, required this.activeBreak});

  final ActiveBreak activeBreak;

  @override
  ConsumerState<ActiveBreakWorkoutScreen> createState() =>
      _ActiveBreakWorkoutScreenState();
}

class _ActiveBreakWorkoutScreenState
    extends ConsumerState<ActiveBreakWorkoutScreen> {
  bool completed = false;

  /// Kept until the completion is saved, so a retry keeps a single entry.
  DateTime? _pendingCompletion;

  Future<void> _complete() async {
    final completedAt = _pendingCompletion ??= DateTime.now();
    try {
      await ref.read(activeBreakCompletionProvider).complete(completedAt);
    } catch (error) {
      debugPrint('Could not save the active break: $error');
      if (mounted) showActivitySaveFailed(context);
      return;
    }
    _pendingCompletion = null;
    if (!mounted) return;
    setState(() => completed = true);
    ref.read(mainNavIndexProvider.notifier).setIndex(0);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workout = ref.watch(activeBreakWorkoutProvider(widget.activeBreak));
    return workout.when(
      loading: () => const LoadingScreen(),
      error: (error, stackTrace) {
        debugPrint(
          'Could not load Active Break "${widget.activeBreak.activeBreakId}": $error',
        );
        debugPrintStack(stackTrace: stackTrace);
        final message = error.toString().replaceFirst('FormatException: ', '');
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load this Active Break.\n\n$message',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      data: (value) {
        // Keeps the ticked sets while the user moves between exercises.
        ref.watch(workoutSetProgressProvider(value.exercises));
        return Scaffold(
          body: Stack(
            children: [
              WorkoutHero(workout: value),
              WorkoutSlidingPanel(
                workout: value,
                finishButtonLabel: completed
                    ? l10n.abRoutineCompleted
                    : l10n.abMarkRoutineCompleted,
                onWorkoutFinished: _complete,
              ),
            ],
          ),
        );
      },
    );
  }
}
