import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/diagnosis/data/firebase_diagnosis_repository.dart';
import 'package:muevete/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diagnosis_repository_providers.g.dart';

@riverpod
DiagnosisRepository diagnosisRepository(Ref ref){
  return FirebaseDiagnosisRepository(
    auth: ref.watch(firebaseAuthProvider), 
    firestore: ref.watch(firebaseFirestoreProvider)
  );
}