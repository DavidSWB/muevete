import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/training/data/firebase_progression_repository.dart';
import 'package:muevete/features/training/domain/repositories/progression_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progression_provider.g.dart';

@riverpod
ProgressionRepository progressionRepository(
    Ref ref,
){
  return FirebaseProgressionRepository(
    firestore: ref.read(firebaseFirestoreProvider),
  );
}