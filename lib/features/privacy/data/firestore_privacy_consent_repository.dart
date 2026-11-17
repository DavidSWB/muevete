import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/features/privacy/domain/consent_record.dart';
import 'package:muevete/features/privacy/domain/privacy_consent_repository.dart';

/// The value written for a consent given now under policy [version]. The
/// date is the server's clock, which the Firestore rules require.
Map<String, dynamic> consentRecordWrite(int version) => {
  'version': version,
  'date': FieldValue.serverTimestamp(),
};

class FirestorePrivacyConsentRepository implements PrivacyConsentRepository {
  FirestorePrivacyConsentRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> acceptPolicy(int version) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated.');
    }
    // update() fails if the profile does not exist instead of creating a
    // partial one. The old `privacyPolicyVersion` field is left as it is,
    // as proof of the earlier acceptance.
    await _firestore.collection('users').doc(currentUser.uid).update({
      policyAcceptedField: consentRecordWrite(version),
      healthDataAuthorizationField: consentRecordWrite(version),
    });
  }
}
