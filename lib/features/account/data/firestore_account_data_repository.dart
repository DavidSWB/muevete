import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/account/domain/account_deletion_service.dart';

/// All of a user's app data lives in `users/{uid}`; the document has no
/// subcollections.
class FirestoreAccountDataRepository implements AccountDataRepository {
  FirestoreAccountDataRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<void> deleteUserData(String uid) {
    return _firestore.collection('users').doc(uid).delete();
  }
}
