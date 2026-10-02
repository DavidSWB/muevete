import 'dart:async';

import 'package:flutter/material.dart';

class ActiveBreakTimerScreen extends StatefulWidget {
  const ActiveBreakTimerScreen({super.key});

  @override
  State<ActiveBreakTimerScreen> createState() => _ActiveBreakTimerScreenState();
}

class _ActiveBreakTimerScreenState extends State<ActiveBreakTimerScreen> {
  Timer? timer;
  int selectedMinutes = 3;
  int remainingSeconds = 180;
  bool running = false;
  bool completed = false;
  bool markedCompleted = false;

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

  void pause() {
    timer?.cancel();
    setState(() => running = false);
  }

  void reset() {
    timer?.cancel();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Timer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedMinutes,
              decoration: const InputDecoration(labelText: 'Duration'),
              items: [for (var i = 1; i <= 20; i++) DropdownMenuItem(value: i, child: Text('$i minutes'))],
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
            Text(displayTime, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text('Try to walk for $selectedMinutes ${selectedMinutes == 1 ? 'minute' : 'minutes'} after 1 hour of sitting.'),
            const SizedBox(height: 24),
            if (completed)
              const Text('Active break complete!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                if (!completed)
                  FilledButton(
                    onPressed: running ? pause : start,
                    child: Text(running ? 'Pause' : (remainingSeconds == selectedMinutes * 60 ? 'Start' : 'Resume')),
                  ),
                OutlinedButton(onPressed: reset, child: const Text('Reset')),
                if (completed && !markedCompleted)
                  FilledButton(
                    onPressed: () => setState(() => markedCompleted = true),
                    child: const Text('Mark as completed'),
                  ),
                if (markedCompleted) const Chip(label: Text('Completed')),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
