import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/training/data/firebase_exercise_repository.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'exercise_provider.g.dart';

@riverpod
ExerciseRepository exerciseRepository(
    Ref ref,
){
  return FirebaseExerciseRepository(
    firestore: ref.read(firebaseFirestoreProvider),
  ); 
}