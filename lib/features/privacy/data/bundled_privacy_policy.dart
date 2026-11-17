import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:muevete/features/privacy/data/privacy_policy_codec.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';

/// The copy of the policy shipped inside the app, used when neither
/// Firestore nor its offline cache can provide one. The same file is the
/// input of `tool/publish_policy`, so both copies stay identical.
class BundledPrivacyPolicy {
  BundledPrivacyPolicy({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String assetPath = 'assets/policies/privacy_v2.json';

  final AssetBundle _bundle;

  Future<PrivacyPolicyVersion> load() async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The bundled policy must be a JSON object.');
    }
    return PrivacyPolicyCodec.versionFromMap(decoded);
  }

  /// Metadata to use when `policies/privacy` cannot be read: [version] is
  /// treated as current and mandatory, so nobody who accepted an older
  /// version skips it while offline.
  static PrivacyPolicyMetadata metadataFor(PrivacyPolicyVersion version) =>
      PrivacyPolicyMetadata(
        currentVersion: version.version,
        minimumAcceptedVersion: version.version,
        requiresReacceptance: true,
        effectiveFrom: version.effectiveFrom,
      );
}
