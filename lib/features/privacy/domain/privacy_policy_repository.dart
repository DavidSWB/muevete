import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';

/// Reads the published privacy policy. The app never writes it: new
/// versions are published from `tool/publish_policy`.
abstract class PrivacyPolicyRepository {
  /// The current `policies/privacy` metadata, and every later change to it.
  /// Emits an error when the document is missing or cannot be read.
  Stream<PrivacyPolicyMetadata> watchMetadata();

  /// The text of [version], from the server or, when offline, from the
  /// copy saved on the device. Throws a [StateError] when that version is
  /// not published or no copy is available, and a [FormatException] when it
  /// cannot be shown.
  Future<FetchedPolicyVersion> getVersion(int version);
}
