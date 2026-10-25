import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile();

  Future<void> saveProfile(UserModel user);

  /// Creates the document for a new account, with empty activity history.
  Future<void> createProfile(UserModel user);

  /// Adds one completion to the history for [kind] and stores [streak] in the
  /// same write. Recording the same [completedAt] twice keeps a single entry.
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
  });
}
