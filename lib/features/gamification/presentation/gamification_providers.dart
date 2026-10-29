import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/gamification/data/firebase_reward_rules_repository.dart';
import 'package:muevete/features/gamification/domain/reward_rules.dart';

final rewardRulesRepositoryProvider = Provider<RewardRulesRepository>((ref) {
  return FirebaseRewardRulesRepository(
    firestore: ref.read(firebaseFirestoreProvider),
  );
});

/// The scoring rules, or the bundled defaults when they cannot be read, so
/// a completion is never blocked by them.
final rewardRulesProvider = FutureProvider<RewardRules>((ref) async {
  try {
    return await ref.read(rewardRulesRepositoryProvider).getRules();
  } catch (error, stackTrace) {
    developer.log(
      'Using default reward rules',
      name: 'muevete.gamification',
      error: error,
      stackTrace: stackTrace,
    );
    return RewardRules.defaults;
  }
});
