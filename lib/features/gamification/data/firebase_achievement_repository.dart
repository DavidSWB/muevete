import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/gamification/domain/achievement.dart';

class FirebaseAchievementRepository implements AchievementRepository {
  FirebaseAchievementRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// A badge that cannot be read is left out instead of hiding the others.
  @override
  Future<List<Achievement>> getAchievements() async {
    final snapshot = await _firestore.collection('achievements').get();

    final achievements = <Achievement>[];
    for (final doc in snapshot.docs) {
      try {
        achievements.add(parse(doc.id, doc.data()));
      } on FormatException catch (error) {
        developer.log(
          'Skipping achievement ${doc.id}: $error',
          name: 'muevete.gamification',
        );
      }
    }
    achievements.sort((a, b) => a.order.compareTo(b.order));
    return achievements;
  }

  /// Throws a [FormatException] for a document that cannot be shown.
  static Achievement parse(String docId, Map<String, dynamic> data) {
    final id = data['achievementId'];
    return Achievement(
      achievementId: id is String && id.isNotEmpty ? id : docId,
      order: data['order'] is int ? data['order'] as int : 0,
      icon: data['icon'] is String ? data['icon'] as String : '',
      name: _localizedMap(data['name'], 'name'),
      description: _localizedMap(data['description'], 'description'),
      condition: _condition(data['condition']),
    );
  }

  static AchievementCondition _condition(dynamic value) {
    if (value is! Map) return const UnknownCondition(null);
    final type = value['type'];
    final count = value['count'];
    return switch (type) {
      'workouts' when count is int => CompletionCountCondition(
        kind: CountedActivity.workouts,
        count: count,
      ),
      'activeBreaks' when count is int => CompletionCountCondition(
        kind: CountedActivity.activeBreaks,
        count: count,
      ),
      'walkthroughCompleted' => const WalkthroughCompletedCondition(),
      _ => UnknownCondition(type is String ? type : null),
    };
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
}
