import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/active_breaks/data/firebase_active_break_repository.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/domain/repositories/active_break_completion_port.dart';
import 'package:muevete/features/active_breaks/domain/repositories/active_break_repository.dart';
import 'package:muevete/features/active_breaks/domain/services/active_break_builder.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/presentation/activity_recorder.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/presentation/providers/exercise_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_completion_provider.dart';

final activeBreakRepositoryProvider = Provider<ActiveBreakRepository>((ref) {
  return FirebaseActiveBreakRepository(
    firestore: ref.read(firebaseFirestoreProvider),
  );
});

final activeBreakBuilderProvider = Provider<ActiveBreakBuilder>((ref) {
  return ActiveBreakBuilder(
    exerciseRepository: ref.read(exerciseRepositoryProvider),
  );
});

final activeBreaksProvider = FutureProvider.autoDispose<List<ActiveBreak>>((ref) {
  return ref.read(activeBreakRepositoryProvider).getActiveBreaks();
});

final activeBreakWorkoutProvider =
    FutureProvider.autoDispose.family<Workout, ActiveBreak>((ref, activeBreak) {
  return ref.read(activeBreakBuilderProvider).buildWorkout(activeBreak);
});

/// Read when an active break is marked completed, so the choice holds for
/// that press. During the in-app tour nothing is recorded.
final activeBreakCompletionProvider =
    Provider.autoDispose<ActiveBreakCompletionPort>((ref) {
  if (ref.watch(workoutCompletionIsRehearsalProvider)) {
    return const TutorialActiveBreakCompletion();
  }
  return PersistingActiveBreakCompletion(ref.read(activityRecorderProvider));
});

/// Records the active break in `completedActiveBreaks`, never as a workout.
class PersistingActiveBreakCompletion implements ActiveBreakCompletionPort {
  const PersistingActiveBreakCompletion(this._recorder);

  final ActivityRecorder _recorder;

  @override
  Future<void> complete(DateTime completedAt) =>
      _recorder.record(ActivityKind.activeBreak, completedAt);
}

/// Lets the tour rehearse an active break without recording anything.
class TutorialActiveBreakCompletion implements ActiveBreakCompletionPort {
  const TutorialActiveBreakCompletion();

  @override
  Future<void> complete(DateTime completedAt) async {}
}

ActiveBreak chooseRandomActiveBreak(List<ActiveBreak> activeBreaks) {
  if (activeBreaks.isEmpty) {
    throw StateError('No Active Breaks are available.');
  }
  return activeBreaks[Random().nextInt(activeBreaks.length)];
}
