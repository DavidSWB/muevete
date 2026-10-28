import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/education/domain/educational_message.dart';
import 'package:muevete/features/education/domain/educational_message_repository.dart';

class FirebaseEducationalMessageRepository
    implements EducationalMessageRepository {
  FirebaseEducationalMessageRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Offline, Firestore answers from its cache. A message that cannot be read
  /// is left out instead of hiding all the others.
  @override
  Future<List<EducationalMessage>> getActiveMessages() async {
    final snapshot = await _firestore
        .collection('educational_messages')
        .where('active', isEqualTo: true)
        .get();

    final messages = <EducationalMessage>[];
    for (final doc in snapshot.docs) {
      try {
        messages.add(parse(doc.data()));
      } on FormatException catch (error) {
        developer.log(
          'Skipping educational message ${doc.id}: $error',
          name: 'muevete.education',
        );
      }
    }
    return messages;
  }

  /// Throws a [FormatException] for a document that cannot be shown.
  static EducationalMessage parse(Map<String, dynamic> data) {
    final source = data['source'];
    if (source is! Map) throw const FormatException('source must be a map');

    final urls = _localizedMap(source['url'], 'source.url');
    for (final url in urls.values) {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        throw FormatException('source.url must be https: $url');
      }
    }

    return EducationalMessage(
      messageId: _string(data['messageId'], 'messageId'),
      type: data['type'] == 'evidence'
          ? EducationalMessageType.evidence
          : EducationalMessageType.tip,
      order: data['order'] is int ? data['order'] as int : 0,
      text: _localizedMap(data['text'], 'text'),
      sourceLabel: _localizedMap(source['label'], 'source.label'),
      sourceUrl: urls,
    );
  }

  static Map<String, String> _localizedMap(dynamic value, String field) {
    if (value is! Map) throw FormatException('$field must be a map');
    final result = <String, String>{};
    for (final language in ['es', 'en']) {
      final text = value[language];
      if (text is! String || text.trim().isEmpty) {
        throw FormatException('$field.$language is required');
      }
      result[language] = text;
    }
    return result;
  }

  static String _string(dynamic value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('$field is required');
  }
}
