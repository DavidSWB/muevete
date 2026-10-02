import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/domain/repositories/active_break_repository.dart';

class FirebaseActiveBreakRepository implements ActiveBreakRepository {
  FirebaseActiveBreakRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ActiveBreak>> getActiveBreaks() async {
    final snapshot = await _firestore.collection('active_breaks').get();
    return snapshot.docs
        .map((doc) => _parse(doc.data()))
        .toList();
  }

  ActiveBreak _parse(Map<String, dynamic> data) {
    try {
      final name = _localizedMap(data['name'], 'name');
      final description = _localizedMap(data['description'], 'description');
      final templates = _list(data['template'], 'template')
          .map((value) => _parseTemplate(value as Map<String, dynamic>))
          .toList();

      if (templates.isEmpty) {
        throw const FormatException('template must not be empty');
      }

      return ActiveBreak(
        activeBreakId: _string(data['activeBreakId'], 'activeBreakId'),
        name: name,
        durationMinutes: _int(data['durationMinutes'], 'durationMinutes'),
        description: description,
        templates: templates,
      );
    } catch (error) {
      throw FormatException('Invalid active break ($error)');
    }
  }

  ActiveBreakTemplate _parseTemplate(Map<String, dynamic> data) {
    return ActiveBreakTemplate(
      session: _int(data['session'], 'session'),
      name: _localizedMap(data['name'], 'template.name'),
      exercises: _list(data['exercises'], 'template.exercises')
          .map((value) => _parseExercise(value as Map<String, dynamic>))
          .toList(),
    );
  }

  ActiveBreakExerciseReference _parseExercise(Map<String, dynamic> data) {
    return ActiveBreakExerciseReference(
      exerciseId: _string(data['exerciseId'], 'exerciseId'),
      variantId: _string(data['variantId'], 'variantId'),
      type: _string(data['type'], 'type'),
      durationSeconds: _int(data['durationSeconds'], 'durationSeconds'),
    );
  }

  Map<String, String> _localizedMap(dynamic value, String field) {
    if (value is! Map) throw FormatException('$field must be a map');
    final result = <String, String>{};
    for (final language in ['es', 'en']) {
      final text = value[language];
      if (text is! String || text.isEmpty) {
        throw FormatException('$field.$language is required');
      }
      result[language] = text;
    }
    return result;
  }

  List<dynamic> _list(dynamic value, String field) {
    if (value is! List) throw FormatException('$field must be a list');
    return value;
  }

  String _string(dynamic value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('$field is required');
  }

  int _int(dynamic value, String field) {
    if (value is int) return value;
    throw FormatException('$field must be an integer');
  }
}
