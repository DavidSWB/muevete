import 'package:muevete/features/training/domain/entities/exercise.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';

class Variantselector {

  double getLowestTargetStat(
    Exercise exercise,
    UserStats stats,
  ) {

    // With no targets the loop would leave the maximum and pick advanced.
    if (exercise.targets.isEmpty) {
      throw StateError('Exercise "${exercise.exerciseId}" has no targets');
    }

    double minStat = 5;

    for(final target in exercise.targets ){

      final currentStat = stats.getStat(target);

      if(currentStat < minStat){
        minStat = currentStat;
      }

    }

    return minStat;

  }
  ExerciseLevel calculateLevel(double stat){

      if(stat > 4){
          return ExerciseLevel.advanced;
      }

      if(stat > 2){
          return ExerciseLevel.intermediate;
      }

      return ExerciseLevel.beginner;

  }
  /// The hardest variant at or below [desiredLevel], or the easiest variant
  /// when the exercise has none at or below it.
  ///
  /// Exercises offer only some of the levels (beginner and intermediate, or
  /// beginner and advanced), so an advanced user gets the intermediate
  /// variant where there is no advanced one, instead of the beginner one.
  ExerciseVariant findVariant(
      Exercise exercise,
      ExerciseLevel desiredLevel,
  ){
    if (exercise.variants.isEmpty) {
      throw StateError('Exercise "${exercise.exerciseId}" has no variants');
    }

    ExerciseVariant? best;
    ExerciseVariant easiest = exercise.variants.first;

    for (final variant in exercise.variants) {
      final level = variant.requiredLevel.index;
      if (level <= desiredLevel.index &&
          (best == null || level > best.requiredLevel.index)) {
        best = variant;
      }
      if (level < easiest.requiredLevel.index) {
        easiest = variant;
      }
    }

    return best ?? easiest;
  }
}