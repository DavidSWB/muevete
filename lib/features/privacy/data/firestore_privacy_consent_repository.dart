import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/features/privacy/domain/privacy_consent_repository.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';

class FirestorePrivacyConsentRepository implements PrivacyConsentRepository {
  FirestorePrivacyConsentRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> acceptCurrentPolicy() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated.');
    }
    // update() fails if the profile does not exist instead of creating a
    // partial one.
    await _firestore.collection('users').doc(currentUser.uid).update({
      privacyPolicyVersionField: currentPrivacyPolicyVersion,
      privacyAcceptedAtField: FieldValue.serverTimestamp(),
    });
  }
}
