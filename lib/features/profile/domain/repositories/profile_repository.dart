import 'package:muevete/features/profile/domain/entities/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile();

  Future<void> saveProfile(UserModel user);

}