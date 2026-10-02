import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/active_breaks/data/firebase_active_break_repository.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/domain/repositories/active_break_repository.dart';
import 'package:muevete/features/active_breaks/domain/services/active_break_builder.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/presentation/providers/exercise_provider.dart';

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

ActiveBreak chooseRandomActiveBreak(List<ActiveBreak> activeBreaks) {
  if (activeBreaks.isEmpty) {
    throw StateError('No Active Breaks are available.');
  }
  return activeBreaks[Random().nextInt(activeBreaks.length)];
}
