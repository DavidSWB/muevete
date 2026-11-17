/// The published privacy policy as the app reads it from
/// `policies/privacy` and `policies/privacy/versions/{version}`.
library;

/// How a block of policy text is shown.
enum PolicyBlockType {
  paragraph('paragraph'),
  bullet('bullet');

  const PolicyBlockType(this.storedValue);

  /// The value stored in Firestore and in the bundled policy file.
  final String storedValue;

  static PolicyBlockType? fromStoredValue(Object? value) {
    for (final type in values) {
      if (type.storedValue == value) return type;
    }
    return null;
  }
}

/// One paragraph or bullet point of a section, kept in reading order.
class PolicyBlock {
  const PolicyBlock(this.type, this.text);

  final PolicyBlockType type;
  final String text;
}

/// One numbered heading of the policy with its paragraphs and bullets.
class PolicySection {
  const PolicySection(this.title, this.blocks);

  final String title;
  final List<PolicyBlock> blocks;
}

/// `policies/privacy`: which version is in force and whether users must
/// accept it again.
class PrivacyPolicyMetadata {
  const PrivacyPolicyMetadata({
    required this.currentVersion,
    required this.minimumAcceptedVersion,
    required this.requiresReacceptance,
    required this.effectiveFrom,
  });

  /// The version users read in Settings and accept from now on.
  final int currentVersion;

  /// The last version that required reacceptance. A user who accepted an
  /// older version must accept again, even if [currentVersion] is a minor
  /// change.
  final int minimumAcceptedVersion;

  /// Whether [currentVersion] itself must be accepted again.
  final bool requiresReacceptance;

  final DateTime effectiveFrom;
}

/// `policies/privacy/versions/{version}`: the full text of one published
/// version. A published version is never changed; a new text is a new
/// version.
class PrivacyPolicyVersion {
  const PrivacyPolicyVersion({
    required this.version,
    required this.effectiveFrom,
    required this.textEs,
    required this.textEn,
    required this.policyCheckbox,
    required this.healthDataCheckbox,
    required this.changeSummary,
  });

  final int version;
  final DateTime effectiveFrom;

  /// The Spanish text, which is the legal reference.
  final List<PolicySection> textEs;

  /// The English translation of [textEs].
  final List<PolicySection> textEn;

  /// Label of the policy checkbox, keyed by language code (`es`, `en`).
  final Map<String, String> policyCheckbox;

  /// Label of the health-data authorization checkbox, keyed by language code.
  final Map<String, String> healthDataCheckbox;

  /// What changed in this version, keyed by language code.
  final Map<String, String> changeSummary;

  /// The sections for [languageCode]; Spanish for any language but English.
  List<PolicySection> sectionsFor(String languageCode) =>
      languageCode == 'en' ? textEn : textEs;
}
