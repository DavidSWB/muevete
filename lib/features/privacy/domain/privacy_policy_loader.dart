import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_repository.dart';

/// Picks the policy text to show for [metadata]: the current version from
/// Firestore (live or its offline copy), or else the bundled version.
///
/// The bundled copy is never presented as a newer version than it is: when
/// the current version is newer and cannot be loaded, the result names it
/// in [LoadedPrivacyPolicy.unavailableVersion].
Future<LoadedPrivacyPolicy> loadPrivacyPolicy({
  required PrivacyPolicyMetadata metadata,
  required PrivacyPolicyRepository repository,
  required Future<PrivacyPolicyVersion> Function() loadBundled,
  void Function(Object error, StackTrace stackTrace)? onFallback,
}) async {
  try {
    final fetched = await repository.getVersion(metadata.currentVersion);
    return LoadedPrivacyPolicy(
      policy: fetched.policy,
      source: fetched.fromCache ? PolicySource.cache : PolicySource.server,
    );
  } catch (error, stackTrace) {
    onFallback?.call(error, stackTrace);
  }
  final bundled = await loadBundled();
  return LoadedPrivacyPolicy(
    policy: bundled,
    source: PolicySource.bundled,
    unavailableVersion: metadata.currentVersion > bundled.version
        ? metadata.currentVersion
        : null,
  );
}
