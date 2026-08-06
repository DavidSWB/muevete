import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/training/domain/entities/exercise.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';

class FirebaseExerciseRepository implements ExerciseRepository{
  FirebaseExerciseRepository({
    required FirebaseFirestore firestore,  
  }): _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Exercise> getExercise(id) async {
    final snapshot = await _firestore
          .collection('exercises')
          .doc(id)
          .get();

    final data = snapshot.data()!;
    
    return Exercise.fromJson(data);
  }
 
}