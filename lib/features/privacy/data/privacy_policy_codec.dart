import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';

/// Converts the privacy policy between its stored form (Firestore and the
/// bundled `assets/policies/privacy_v*.json`) and the domain entities.
///
/// Parsing throws a [FormatException] for anything that would show an empty
/// or partial policy, so callers can fall back to another copy instead.
class PrivacyPolicyCodec {
  const PrivacyPolicyCodec._();

  static const List<String> languages = ['es', 'en'];

  static PrivacyPolicyMetadata metadataFromMap(Map<String, dynamic> data) {
    final current = _version(data['currentVersion'], 'currentVersion');
    final minimum = _version(
      data['minimumAcceptedVersion'],
      'minimumAcceptedVersion',
    );
    if (minimum > current) {
      throw const FormatException(
        'minimumAcceptedVersion cannot be above currentVersion',
      );
    }
    final requires = data['requiresReacceptance'];
    if (requires is! bool) {
      throw const FormatException('requiresReacceptance must be a bool');
    }
    return PrivacyPolicyMetadata(
      currentVersion: current,
      minimumAcceptedVersion: minimum,
      requiresReacceptance: requires,
      effectiveFrom: _date(data['effectiveFrom'], 'effectiveFrom'),
    );
  }

  static Map<String, dynamic> metadataToMap(PrivacyPolicyMetadata metadata) => {
    'currentVersion': metadata.currentVersion,
    'minimumAcceptedVersion': metadata.minimumAcceptedVersion,
    'requiresReacceptance': metadata.requiresReacceptance,
    'effectiveFrom': metadata.effectiveFrom,
  };

  static PrivacyPolicyVersion versionFromMap(Map<String, dynamic> data) {
    return PrivacyPolicyVersion(
      version: _version(data['version'], 'version'),
      effectiveFrom: _date(data['effectiveFrom'], 'effectiveFrom'),
      textEs: _sections(data['textEs'], 'textEs'),
      textEn: _sections(data['textEn'], 'textEn'),
      policyCheckbox: _localized(data['policyCheckbox'], 'policyCheckbox'),
      healthDataCheckbox: _localized(
        data['healthDataCheckbox'],
        'healthDataCheckbox',
      ),
      changeSummary: _localized(data['changeSummary'], 'changeSummary'),
    );
  }

  /// [PrivacyPolicyVersion.effectiveFrom] stays a [DateTime]; Firestore
  /// stores it as a timestamp.
  static Map<String, dynamic> versionToMap(PrivacyPolicyVersion version) => {
    'version': version.version,
    'effectiveFrom': version.effectiveFrom,
    'textEs': _sectionsToList(version.textEs),
    'textEn': _sectionsToList(version.textEn),
    'policyCheckbox': Map<String, String>.of(version.policyCheckbox),
    'healthDataCheckbox': Map<String, String>.of(version.healthDataCheckbox),
    'changeSummary': Map<String, String>.of(version.changeSummary),
  };

  static List<Map<String, dynamic>> _sectionsToList(
    List<PolicySection> sections,
  ) => [
    for (final section in sections)
      {
        'title': section.title,
        'blocks': [
          for (final block in section.blocks)
            {'type': block.type.storedValue, 'text': block.text},
        ],
      },
  ];

  static int _version(Object? value, String field) {
    if (value is int && value >= 1) return value;
    throw FormatException('$field must be a whole number of at least 1');
  }

  /// A Firestore timestamp, or an ISO 8601 string in the bundled file.
  static DateTime _date(Object? value, String field) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('$field must be a date');
  }

  static List<PolicySection> _sections(Object? value, String field) {
    if (value is! List || value.isEmpty) {
      throw FormatException('$field must be a non-empty list of sections');
    }
    return [
      for (var i = 0; i < value.length; i++) _section(value[i], '$field[$i]'),
    ];
  }

  static PolicySection _section(Object? value, String field) {
    if (value is! Map) throw FormatException('$field must be a map');
    final blocks = value['blocks'];
    if (blocks is! List || blocks.isEmpty) {
      throw FormatException('$field.blocks must be a non-empty list');
    }
    return PolicySection(_text(value['title'], '$field.title'), [
      for (var i = 0; i < blocks.length; i++)
        _block(blocks[i], '$field.blocks[$i]'),
    ]);
  }

  static PolicyBlock _block(Object? value, String field) {
    if (value is! Map) throw FormatException('$field must be a map');
    final type = PolicyBlockType.fromStoredValue(value['type']);
    if (type == null) {
      throw FormatException('$field.type must be paragraph or bullet');
    }
    return PolicyBlock(type, _text(value['text'], '$field.text'));
  }

  static Map<String, String> _localized(Object? value, String field) {
    if (value is! Map) throw FormatException('$field must be a map');
    return {
      for (final language in languages)
        language: _text(value[language], '$field.$language'),
    };
  }

  static String _text(Object? value, String field) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('$field is required');
  }
}
