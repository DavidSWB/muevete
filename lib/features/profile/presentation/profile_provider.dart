import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
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
    } catch (error, stackTrace) {
      _logSchedulingFailure(
        'Failed to schedule notifications after loading the profile',
        error,
        stackTrace,
      );
    }
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

  /// Saves the user-edited fields only, so app-managed data written meanwhile
  /// (stats, history, panel edits) is never overwritten.
  Future<void> updatePersonalInfo(PersonalInfo info) async {
    final currentUser = await future;
    await ref.read(profileRepositoryProvider).updatePersonalInfo(info);
    state = AsyncData(currentUser.withPersonalInfo(info));
  }

  Future<void> saveNotificationPreferences(UserNotifications notifications) async {
    final currentUser = await future;
    final updatedUser = currentUser.copyWith(notifications: notifications);
    await saveProfile(updatedUser);
    try {
      await NotificationScheduler.rescheduleAll(updatedUser, force: true);
    } catch (error, stackTrace) {
      _logSchedulingFailure(
        'Failed to schedule notifications after saving preferences',
        error,
        stackTrace,
      );
      throw NotificationSchedulingException(error, stackTrace);
    }
  }

  /// Shows [badgeIds] as unlocked once they are saved, without reloading.
  void markBadgesUnlocked(Set<String> badgeIds) {
    final user = state.value;
    if (user == null) return;
    state = AsyncData(
      user.copyWith(
        unlockedBadgeIds: {...user.unlockedBadgeIds, ...badgeIds}.toList(),
      ),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// `developer.log` never reaches logcat in release builds, so the failure is
/// also printed; that is the only trace left on a physical device. The error
/// comes from the notification plugin and carries no profile data.
void _logSchedulingFailure(String message, Object error, StackTrace stackTrace) {
  developer.log(
    message,
    name: 'muevete.notifications',
    error: error,
    stackTrace: stackTrace,
  );
  debugPrint('muevete.notifications: $message: $error');
}

class NotificationSchedulingException implements Exception {
  const NotificationSchedulingException(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => 'Notification scheduling failed: $error';
}
