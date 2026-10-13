import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';

part 'profile_provider.g.dart';

@riverpod
class Profile extends _$Profile {
  @override
  Future<UserModel> build() async {
    final user = await loadProfile();
    try {
      await NotificationScheduler.rescheduleAll(user);
    } catch (_) {}
    return user;
  }

  Future<UserModel> loadProfile() async {
    final profileRepository = ref.read(profileRepositoryProvider);

    return await profileRepository.getProfile();
  }

  Future<void> saveProfile(UserModel updatedUser) async {
    final repository = ref.read(profileRepositoryProvider);

    await repository.saveProfile(updatedUser);

    state = AsyncData(updatedUser);
  }

  Future<void> saveNotificationPreferences(UserNotifications notifications) async {
    final currentUser = await future;
    final updatedUser = currentUser.copyWith(notifications: notifications);
    await saveProfile(updatedUser);
    try {
      await NotificationScheduler.rescheduleAll(updatedUser, force: true);
    } catch (_) {}
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
