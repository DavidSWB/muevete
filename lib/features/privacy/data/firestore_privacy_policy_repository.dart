import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/privacy/data/privacy_policy_codec.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_repository.dart';

/// Reads `policies/privacy` and `policies/privacy/versions/{version}`.
/// Both are public, so this works before sign-in. Offline, Firestore
/// answers from its own cache when it has a copy.
class FirestorePrivacyPolicyRepository implements PrivacyPolicyRepository {
  FirestorePrivacyPolicyRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _policy =>
      _firestore.collection('policies').doc('privacy');

  @override
  Stream<PrivacyPolicyMetadata> watchMetadata() {
    return _policy.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw StateError('policies/privacy is not published.');
      }
      return PrivacyPolicyCodec.metadataFromMap(data);
    });
  }

  @override
  Future<FetchedPolicyVersion> getVersion(int version) async {
    final document = _policy.collection('versions').doc('$version');
    DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      // Offline, this already answers from the device cache when it can.
      snapshot = await document.get();
    } on FirebaseException {
      // No connection and the default read gave up: try the cache alone.
      snapshot = await document.get(const GetOptions(source: Source.cache));
    }
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw StateError('Privacy policy version $version is not published.');
    }
    final parsed = PrivacyPolicyCodec.versionFromMap(data);
    if (parsed.version != version) {
      throw FormatException(
        'Document versions/$version holds version ${parsed.version}.',
      );
    }
    return FetchedPolicyVersion(
      parsed,
      fromCache: snapshot.metadata.isFromCache,
    );
  }
}
