import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

import 'package:muevete/features/training/domain/services/notification_scheduler.dart';

@riverpod
class Profile extends _$Profile{

  @override
  Future<UserModel> build() async{
    final user = await loadProfile();
    try {
      await NotificationScheduler.rescheduleAll(user);
    } catch (_) {}
    return user;
  }

  Future<UserModel> loadProfile() async{
    final profileRepository = ref.read(profileRepositoryProvider); 

    return await profileRepository.getProfile();
  }

  Future<void> saveProfile(UserModel updatedUser) async {
    final repository = ref.read(profileRepositoryProvider);

    await repository.saveProfile(updatedUser);

    state = AsyncData(updatedUser);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

}