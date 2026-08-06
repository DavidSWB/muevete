import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/profile/data/firestore_profile_repository.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository_provider.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref){
  return FirestoreProfileRepository(
    auth: ref.watch(firebaseAuthProvider), 
    firestore: ref.watch(firebaseFirestoreProvider)
  );
}