import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';

/// A complete policy version for tests, with recognizable labels.
PrivacyPolicyVersion testPolicyVersion(int version) => PrivacyPolicyVersion(
  version: version,
  effectiveFrom: DateTime(2026, 11, 17),
  textEs: [
    PolicySection('1. Responsable del tratamiento', [
      PolicyBlock(PolicyBlockType.paragraph, 'Texto de la versión $version.'),
      const PolicyBlock(PolicyBlockType.bullet, 'Una viñeta.'),
    ]),
  ],
  textEn: [
    PolicySection('1. Data controller', [
      PolicyBlock(PolicyBlockType.paragraph, 'Text of version $version.'),
      const PolicyBlock(PolicyBlockType.bullet, 'A bullet.'),
    ]),
  ],
  policyCheckbox: {
    'es': 'Acepto la política v$version.',
    'en': 'I accept policy v$version.',
  },
  healthDataCheckbox: {
    'es': 'Autorizo mis datos de salud v$version.',
    'en': 'I authorize my health data v$version.',
  },
  changeSummary: {
    'es': 'Cambios de la versión $version.',
    'en': 'Changes in version $version.',
  },
);

PrivacyPolicyMetadata testPolicyMetadata({
  int current = 2,
  int? minimum,
  bool requiresReacceptance = true,
}) => PrivacyPolicyMetadata(
  currentVersion: current,
  minimumAcceptedVersion: minimum ?? current,
  requiresReacceptance: requiresReacceptance,
  effectiveFrom: DateTime(2026, 11, 17),
);

/// Overrides so screens show [version] as the current policy without
/// Firestore.
List<Override> privacyPolicyOverrides({int version = 2}) => [
  currentPrivacyPolicyProvider.overrideWith(
    (ref) async => testPolicyVersion(version),
  ),
  privacyPolicyMetadataProvider.overrideWith(
    (ref) => Stream.value(testPolicyMetadata(current: version)),
  ),
];
