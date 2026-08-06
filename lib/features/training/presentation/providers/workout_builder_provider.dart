import 'package:muevete/features/training/domain/services/workout_builder.dart';
import 'package:muevete/features/training/presentation/providers/exercise_provider.dart';
import 'package:muevete/features/training/presentation/providers/progression_provider.dart';
import 'package:muevete/features/training/presentation/providers/variant_selector_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workout_builder_provider.g.dart';

@riverpod
WorkoutBuilder workoutBuilder(Ref ref) {
  return WorkoutBuilder(
    exerciseRepository: ref.read(exerciseRepositoryProvider),
    progressionRepository: ref.read(progressionRepositoryProvider),
    variantSelector: ref.read(variantSelectorProvider),
  );
}