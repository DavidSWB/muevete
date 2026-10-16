import 'dart:async';

import 'package:flutter/material.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/widgets/set_completion_row.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/utils/youtube_utils.dart';
import 'package:muevete/shared/widgets/exercise_video_player.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final WorkoutExercise exercise;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _timerEndsAt;
  int? _activeSet;
  late final List<bool> _completed;
  late final List<int> _remainingSeconds;

  bool get _isHold => widget.exercise.duration != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _completed = List<bool>.filled(widget.exercise.sets, false);
    _remainingSeconds = List<int>.filled(
      widget.exercise.sets,
      widget.exercise.duration ?? 0,
    );
  }

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
  }

  void _toggleTimer(int index) {
    if (_completed[index]) return;
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
    _timerEndsAt = DateTime.now().add(Duration(seconds: seconds));
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _timerEndsAt == null || _activeSet != index) return;
      final remaining = _timerEndsAt!.difference(DateTime.now());
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
        : (endsAt.difference(DateTime.now()).inMilliseconds / 1000).ceil();
    _timer?.cancel();
    _timer = null;
    _timerEndsAt = null;
    _activeSet = null;
    if (mounted) {
      setState(() {
        _remainingSeconds[activeSet] = secondsLeft.clamp(0, 86400);
      });
    }
  }

  void _completeFromTimer(int index) {
    _timer?.cancel();
    _timer = null;
    _timerEndsAt = null;
    _activeSet = null;
    if (!mounted) return;
    setState(() {
      _remainingSeconds[index] = 0;
      _completed[index] = true;
    });
  }

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
    final variant = widget.exercise.exercise;

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
              ClipRRect(
                key: const ValueKey('exercise-visual'),
                borderRadius: BorderRadius.circular(20),
                child: _buildVisual(variant.visualPath),
              ),
              const SizedBox(height: 24),
              Text(
                variant.name['en'] ?? 'Exercise',
                key: const ValueKey('exercise-title'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                variant.description['en'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _Stats(exercise: widget.exercise),
              const SizedBox(height: 24),
              for (var index = 0; index < widget.exercise.sets; index++)
                ExerciseSetRow(
                  setNumber: index + 1,
                  isHold: _isHold,
                  isCompleted: _completed[index],
                  isRunning: _activeSet == index,
                  value: _setValue(index),
                  onToggleCompleted: () => _toggleCompleted(index),
                  onToggleTimer: () => _toggleTimer(index),
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
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const ValueKey('exercise-done-button'),
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Done!'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.exercise});

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat('Sets', '${exercise.sets}'),
        _Stat('Reps', '${exercise.reps ?? "-"}'),
        _Stat('Rest', '${exercise.rest}s'),
        if (exercise.duration != null) _Stat('Duration', '${exercise.duration}s'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
