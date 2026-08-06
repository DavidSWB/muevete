import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/training/data/firebase_training_repository.dart';
import 'package:muevete/features/training/domain/repositories/training_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'training_repository_provider.g.dart';

@riverpod 
TrainingRepository trainingRepository(
  Ref ref,
) {
  return FirebaseTrainingRepository(
    firestore: ref.read(firebaseFirestoreProvider),
  );
}