import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/training/domain/entities/exercise_sequence.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/widgets/set_completion_row.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/utils/youtube_utils.dart';
import 'package:muevete/shared/widgets/exercise_video_player.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.sequence,
  });

  static const routeName = 'exercise';

  final WorkoutExercise exercise;

  /// The workout this exercise belongs to. When it has a following exercise,
  /// the screen shows a Next button that opens it in place of this one.
  final ExerciseSequence? sequence;

  static Route<void> route(ExerciseSequence sequence) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => ExerciseDetailScreen(
        exercise: sequence.current,
        sequence: sequence,
      ),
    );
  }

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with WidgetsBindingObserver {
  static const int _maxClampSeconds = 86400;

  Timer? _timer;
  DateTime? _timerEndsAt;
  int? _activeSet;
  late final List<bool> _completed;
  late final List<int> _remainingSeconds;

  bool get _isHold => widget.exercise.duration != null;

  int get _completedSetCount =>
      _completed.where((isSetDone) => isSetDone).length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _completed = List<bool>.filled(widget.exercise.sets, false);
    _remainingSeconds = List<int>.filled(
      widget.exercise.sets,
      widget.exercise.duration ?? 0,
    );
    // Lets the tour skip its Next step on the last exercise of a workout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tour.setCondition(
        WalkthroughCondition.noNextExercise,
        !(widget.sequence?.hasNext ?? false),
      );
    });
  }

  WalkthroughController get _tour =>
      ref.read(walkthroughControllerProvider.notifier);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _pauseTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _toggleCompleted(int index) {
    HapticFeedback.lightImpact();
    if (_completed[index]) {
      if (_activeSet == index) _pauseTimer();
      setState(() {
        _completed[index] = false;
        if (_isHold) _remainingSeconds[index] = widget.exercise.duration ?? 0;
      });
      return;
    }

    if (_activeSet == index) _pauseTimer();
    setState(() => _completed[index] = true);
    _tour.onSignal(const ActionReceipt(WalkthroughAction.setCompleted));
  }

  void _toggleTimer(int index) {
    if (_completed[index]) return;
    HapticFeedback.selectionClick();
    if (_activeSet == index) {
      _pauseTimer();
    } else {
      _startTimer(index);
    }
  }

  void _startTimer(int index) {
    _pauseTimer();
    final seconds = _remainingSeconds[index];
    if (seconds <= 0) {
      _completeFromTimer(index);
      return;
    }

    _activeSet = index;
    _timerEndsAt = clock.now().add(Duration(seconds: seconds));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _timerEndsAt == null || _activeSet != index) return;
      final remaining = _timerEndsAt!.difference(clock.now());
      final secondsLeft = (remaining.inMilliseconds / 1000).ceil();
      if (secondsLeft <= 0) {
        _completeFromTimer(index);
      } else if (_remainingSeconds[index] != secondsLeft) {
        setState(() => _remainingSeconds[index] = secondsLeft);
      }
    });
    setState(() {});
  }

  void _pauseTimer() {
    final activeSet = _activeSet;
    if (activeSet == null) return;

    final endsAt = _timerEndsAt;
    final secondsLeft = endsAt == null
        ? _remainingSeconds[activeSet]
        : (endsAt.difference(clock.now()).inMilliseconds / 1000).ceil();
    _timer?.cancel();
    _timer = null;
    _timerEndsAt = null;
    _activeSet = null;
    if (mounted) {
      setState(() {
        _remainingSeconds[activeSet] =
            secondsLeft.clamp(0, _maxClampSeconds);
      });
    }
  }

  void _completeFromTimer(int index) {
    _timer?.cancel();
    _timer = null;
    _timerEndsAt = null;
    _activeSet = null;
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _remainingSeconds[index] = 0;
      _completed[index] = true;
    });
    _tour.onSignal(const ActionReceipt(WalkthroughAction.setCompleted));
  }

  void _openNextExercise() {
    final sequence = widget.sequence;
    if (sequence == null || !sequence.hasNext) return;
    HapticFeedback.lightImpact();
    _tour.onSignal(const ActionReceipt(WalkthroughAction.exerciseNext));
    Navigator.of(context)
        .pushReplacement(ExerciseDetailScreen.route(sequence.next()));
  }

  Widget _anchorFirstSet(int index, Widget row) => index == 0
      ? WalkthroughAnchor(id: 'exercise.completeSet', child: row)
      : row;

  String _setValue(int index) {
    if (_isHold) return '${_remainingSeconds[index]}s';
    return '${widget.exercise.reps ?? '-'}';
  }

  Widget _buildVisual(String visualPath) {
    if (extractYouTubeId(visualPath) != null) {
      return ExerciseVideoPlayer(visualPath: visualPath);
    }
    if (visualPath.trim().startsWith('assets/')) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(visualPath.trim(), fit: BoxFit.cover),
      );
    }
    return ExerciseVideoPlayer(visualPath: visualPath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final variant = widget.exercise.exercise;
    final totalSets = widget.exercise.sets;
    final progressRatio =
        totalSets > 0 ? _completedSetCount / totalSets : 0.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  key: const ValueKey('exercise-visual'),
                  borderRadius: BorderRadius.circular(20),
                  child: _buildVisual(variant.visualPath),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                variant.name.localized(context, fallback: 'Exercise'),
                key: const ValueKey('exercise-title'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                variant.description.localized(context, fallback: ''),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 20),
              WalkthroughAnchor(
                id: 'exercise.prescription',
                child: _PrescriptionStatsBar(exercise: widget.exercise),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 6,
                  backgroundColor: AppColors.softGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressRatio >= 1.0
                        ? AppColors.success
                        : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var index = 0; index < widget.exercise.sets; index++)
                _anchorFirstSet(
                  index,
                  ExerciseSetRow(
                    setNumber: index + 1,
                    isHold: _isHold,
                    isCompleted: _completed[index],
                    isRunning: _activeSet == index,
                    value: _setValue(index),
                    onToggleCompleted: () => _toggleCompleted(index),
                    onToggleTimer: () => _toggleTimer(index),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: SizedBox(
            height: 54,
            child: Row(
              children: [
                Expanded(
                  child: WalkthroughAnchor(
                    id: 'exercise.done',
                    child: SizedBox.expand(
                      child: ElevatedButton(
                        key: const ValueKey('exercise-done-button'),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _tour.onSignal(
                            const ActionReceipt(WalkthroughAction.exerciseDone),
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(l10n.exerciseDone),
                      ),
                    ),
                  ),
                ),
                if (widget.sequence?.hasNext ?? false) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: WalkthroughAnchor(
                      id: 'exercise.next',
                      child: SizedBox.expand(
                        child: OutlinedButton.icon(
                          key: const ValueKey('exercise-next-button'),
                          onPressed: _openNextExercise,
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(l10n.exerciseNext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(
                              color: AppColors.primaryDark,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionStatsBar extends StatelessWidget {
  const _PrescriptionStatsBar({required this.exercise});

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _StatPill(
          icon: Icons.layers_outlined,
          label: l10n.exerciseSets,
          value: '${exercise.sets}',
        ),
        const SizedBox(width: 8),
        _StatPill(
          icon: Icons.repeat_rounded,
          label: l10n.exerciseRepsShort,
          value: '${exercise.reps ?? "-"}',
        ),
        const SizedBox(width: 8),
        _StatPill(
          icon: Icons.timer_outlined,
          label: l10n.exerciseRest,
          value: '${exercise.rest}s',
        ),
        if (exercise.duration != null) ...[
          const SizedBox(width: 8),
          _StatPill(
            icon: Icons.hourglass_bottom_rounded,
            label: l10n.exerciseDuration,
            value: '${exercise.duration}s',
          ),
        ],
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.softGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryDark),
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
      ),
    );
  }
}
