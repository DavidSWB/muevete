import 'package:muevete/features/training/domain/entities/exercise.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';

class Variantselector {

  double getLowestTargetStat(
    Exercise exercise,
    UserStats stats,
  ) {

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
  ExerciseVariant findVariant(
      Exercise exercise,
      ExerciseLevel desiredLevel,
  ){

    final exactMatch = exercise.variants.where(
      (variant) => variant.requiredLevel == desiredLevel,
    );

    if (exactMatch.isNotEmpty) {
      return exactMatch.first;
    }

    if (desiredLevel == ExerciseLevel.intermediate) {
      final beginner = exercise.variants.where(
        (variant) => variant.requiredLevel == ExerciseLevel.beginner,
      );

      if (beginner.isNotEmpty) {
        return beginner.first;
      }
    }

    return exercise.variants.first;
  }
}