import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/presentation/providers/active_break_providers.dart';
import 'package:muevete/features/training/presentation/widgets/hero/workout_hero.dart';
import 'package:muevete/features/training/presentation/widgets/panel/workout_sliding_panel.dart';
import 'package:muevete/shared/screens/loading_screen.dart';

class ActiveBreakWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveBreakWorkoutScreen({super.key, required this.activeBreak});

  final ActiveBreak activeBreak;

  @override
  ConsumerState<ActiveBreakWorkoutScreen> createState() => _ActiveBreakWorkoutScreenState();
}

class _ActiveBreakWorkoutScreenState extends ConsumerState<ActiveBreakWorkoutScreen> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(activeBreakWorkoutProvider(widget.activeBreak));
    return workout.when(
      loading: () => const LoadingScreen(),
      error: (error, stackTrace) {
        debugPrint('Could not load Active Break "${widget.activeBreak.activeBreakId}": $error');
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
      data: (value) => Scaffold(
        body: Stack(
          children: [
            WorkoutHero(workout: value),
            WorkoutSlidingPanel(
              workout: value,
              finishButtonLabel: completed ? 'Completed' : 'Mark Active Break as completed',
              onWorkoutFinished: () async {
                if (!completed && mounted) setState(() => completed = true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
