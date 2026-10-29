import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/gamification/domain/achievement_evaluator.dart';
import 'package:muevete/features/gamification/presentation/gamification_providers.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';

final badgeSyncProvider = Provider<BadgeSync>(BadgeSync.new);

/// Gives the user every badge their history has earned. Unlocking is
/// add-only, so running it again, or twice at once, never repeats a badge.
class BadgeSync {
  BadgeSync(this._ref);

  final Ref _ref;
  final Set<String> _saving = {};

  /// Saves the badges [user] has newly earned and returns their ids. A
  /// failure is logged and returns none: badges are earned again on the
  /// next check, and must never block what triggered it.
  Future<Set<String>> sync(
    UserModel user, {
    required bool walkthroughCompleted,
  }) async {
    final earned = <String>{};
    try {
      final catalogue = await _ref.read(achievementsProvider.future);
      earned.addAll(
        const AchievementEvaluator().newlyEarned(
          catalogue: catalogue,
          user: user,
          walkthroughCompleted: walkthroughCompleted,
        ),
      );
      earned.removeAll(_saving);
      if (earned.isEmpty) return const {};

      _saving.addAll(earned);
      try {
        await _ref.read(profileRepositoryProvider).unlockBadges(earned);
      } finally {
        _saving.removeAll(earned);
      }
      _ref.read(profileProvider.notifier).markBadgesUnlocked(earned);
      return earned;
    } catch (error, stackTrace) {
      developer.log(
        'Could not unlock badges',
        name: 'muevete.gamification',
        error: error,
        stackTrace: stackTrace,
      );
      return const {};
    }
  }
}
