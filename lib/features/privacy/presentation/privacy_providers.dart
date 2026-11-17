import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/privacy/data/firestore_privacy_consent_repository.dart';
import 'package:muevete/features/privacy/data/firestore_privacy_policy_repository.dart';
import 'package:muevete/features/privacy/domain/privacy_consent_repository.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_repository.dart';

final privacyConsentRepositoryProvider = Provider<PrivacyConsentRepository>(
  (ref) => FirestorePrivacyConsentRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  ),
);

final privacyPolicyRepositoryProvider = Provider<PrivacyPolicyRepository>(
  (ref) => FirestorePrivacyPolicyRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  ),
);
