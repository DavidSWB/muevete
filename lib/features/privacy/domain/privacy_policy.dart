import 'dart:math' as math;

import 'package:muevete/features/privacy/domain/consent_record.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';

/// What the app must do about the privacy policy for a signed-in user.
enum PrivacyPolicyStatus {
  /// The user accepted the current version.
  upToDate,

  /// The user must accept the current version before using the app.
  mustAccept,

  /// A minor update the user only needs to be told about.
  updateNotice,
}

/// Compares the user's two consent records with the published [metadata].
///
/// Both records must reach the last mandatory version: a profile that is
/// missing either one (including profiles from before versioned policies,
/// which only have the old date field) must accept again. A newer version
/// that does not require reacceptance only shows a notice.
PrivacyPolicyStatus evaluatePrivacyPolicyStatus({
  required PrivacyPolicyMetadata metadata,
  required ConsentRecord? policyAccepted,
  required ConsentRecord? healthDataAuthorization,
}) {
  if (policyAccepted == null || healthDataAuthorization == null) {
    return PrivacyPolicyStatus.mustAccept;
  }
  final mandatory = metadata.requiresReacceptance
      ? math.max(metadata.minimumAcceptedVersion, metadata.currentVersion)
      : metadata.minimumAcceptedVersion;
  if (policyAccepted.version < mandatory ||
      healthDataAuthorization.version < mandatory) {
    return PrivacyPolicyStatus.mustAccept;
  }
  if (policyAccepted.version < metadata.currentVersion) {
    return PrivacyPolicyStatus.updateNotice;
  }
  return PrivacyPolicyStatus.upToDate;
}

/// Where users send requests about their data. Named in the policy text
/// and in the account-deletion messages.
const String privacyPolicyContactEmail = 'davidc.eraso221@umariana.edu.co';
