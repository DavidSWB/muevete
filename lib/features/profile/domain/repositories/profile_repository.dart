import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile();

  Future<void> saveProfile(UserModel user);

  /// Updates only the user-edited fields of the signed-in user's profile;
  /// every other field is left as stored.
  Future<void> updatePersonalInfo(PersonalInfo info);

  /// Creates the document for a new account, with empty activity history.
  Future<void> createProfile(UserModel user);

  /// Adds one completion to the history for [kind] and stores [streak] in the
  /// same write. Recording the same [completedAt] twice keeps a single entry.
  ///
  /// [reward] receives the history of [kind] recorded before this
  /// completion; what it returns is added to `movementXp` and
  /// `jointProgress` in that same write. A completion that is already
  /// recorded writes nothing, so its reward is never given twice.
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  });

  /// Adds [badgeIds] to `unlockedBadgeIds`; ids already there stay once.
  Future<void> unlockBadges(Set<String> badgeIds);
}
