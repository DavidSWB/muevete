import 'package:muevete/features/profile/domain/entities/biological_sex.dart';

/// The profile fields the user edits themselves. Everything else in the
/// profile is managed by the app.
class PersonalInfo {
  const PersonalInfo({
    required this.username,
    required this.age,
    required this.height,
    required this.weight,
    required this.sex,
    this.medicalConditions,
  });

  final String username;
  final int age;
  final double height;
  final double weight;
  final BiologicalSex sex;

  /// Null when the user has none, as sign-up stores it.
  final List<String>? medicalConditions;
}
