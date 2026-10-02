import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/training/domain/entities/exercise.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';

class FirebaseExerciseRepository implements ExerciseRepository{
  FirebaseExerciseRepository({
    required FirebaseFirestore firestore,  
  }): _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Exercise> getExercise(String id) async {
    final snapshot = await _firestore
          .collection('exercises')
          .doc(id)
          .get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw StateError('Exercise document "$id" does not exist.');
    }

    try {
      return Exercise.fromJson(snapshot.data()!);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FormatException('Invalid exercise document "$id": $error'),
        stackTrace,
      );
    }
  }
 
}
