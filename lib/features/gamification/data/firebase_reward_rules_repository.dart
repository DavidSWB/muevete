import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/gamification/domain/reward_rules.dart';

class FirebaseRewardRulesRepository implements RewardRulesRepository {
  FirebaseRewardRulesRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// [RewardRules.defaults] when the document does not exist.
  @override
  Future<RewardRules> getRules() async {
    final snapshot = await _firestore
        .collection('progression_rules')
        .doc('rewards')
        .get();
    final data = snapshot.data();
    return data == null ? RewardRules.defaults : RewardRules.fromJson(data);
  }
}
