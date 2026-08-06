import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_type.dart';
import 'package:muevete/features/training/domain/entities/progessionrules.dart';

abstract class ProgressionRepository {
  Future <ProgessionRules> getRules(
    ExerciseType type,
    ExerciseLevel level,
  );
}