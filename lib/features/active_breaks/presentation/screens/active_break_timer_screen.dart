import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/active_breaks/presentation/providers/active_break_providers.dart';
import 'package:muevete/features/profile/presentation/activity_save_failed.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';

class ActiveBreakTimerScreen extends ConsumerStatefulWidget {
  const ActiveBreakTimerScreen({super.key});

  @override
  ConsumerState<ActiveBreakTimerScreen> createState() =>
      _ActiveBreakTimerScreenState();
}

class _ActiveBreakTimerScreenState
    extends ConsumerState<ActiveBreakTimerScreen> {
  Timer? timer;
  int selectedMinutes = 3;
  int remainingSeconds = 180;
  bool running = false;
  bool completed = false;
  bool markedCompleted = false;
  bool saving = false;

  /// Kept until the completion is saved, so a retry keeps a single entry.
  DateTime? _pendingCompletion;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void start() {
    if (completed) return;
    timer?.cancel();
    setState(() => running = true);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (remainingSeconds <= 1) {
        timer?.cancel();
        setState(() {
          remainingSeconds = 0;
          running = false;
          completed = true;
        });
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  /// A finished personal timer counts as a completed active break.
  Future<void> markCompleted() async {
    if (saving || markedCompleted) return;
    final completedAt = _pendingCompletion ??= DateTime.now();
    setState(() => saving = true);
    try {
      await ref.read(activeBreakCompletionProvider).complete(completedAt);
      _pendingCompletion = null;
      if (mounted) setState(() => markedCompleted = true);
    } catch (error) {
      debugPrint('Could not save the timer break: $error');
      if (mounted) showActivitySaveFailed(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void pause() {
    timer?.cancel();
    setState(() => running = false);
  }

  void reset() {
    timer?.cancel();
    _pendingCompletion = null;
    setState(() {
      remainingSeconds = selectedMinutes * 60;
      running = false;
      completed = false;
      markedCompleted = false;
    });
  }

  String get displayTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: walkthroughBackButton(context, 'ab.back'),
        title: Text(l10n.abPersonalTimerTitle),
        actions: const [
          LocaleSwitcher(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedMinutes,
              decoration: InputDecoration(
                labelText: l10n.abDurationMinutes(selectedMinutes).split(' ').last,
              ),
              items: [
                for (var i = 1; i <= 20; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(l10n.abDurationMinutes(i)),
                  ),
              ],
              onChanged: running || completed
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        selectedMinutes = value;
                        remainingSeconds = value * 60;
                      });
                    },
            ),
            const Spacer(),
            Text(displayTime,
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text(l10n.abTryToWalk(selectedMinutes)),
            const SizedBox(height: 24),
            if (completed)
              Text(
                l10n.abComplete,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                if (!completed)
                  FilledButton(
                    onPressed: running ? pause : start,
                    child: Text(running ? l10n.abPause : l10n.abStart),
                  ),
                OutlinedButton(onPressed: reset, child: Text(l10n.abReset)),
                if (completed && !markedCompleted)
                  FilledButton(
                    onPressed: saving ? null : markCompleted,
                    child: Text(l10n.abMarkCompleted),
                  ),
                if (markedCompleted)
                  Chip(label: Text(l10n.abCompletedMarked)),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
