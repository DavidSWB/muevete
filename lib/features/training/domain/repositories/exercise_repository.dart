import 'package:muevete/features/training/domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Future<Exercise> getExercise(String id);

  //Future <List<Exercise>> getExercises();
}