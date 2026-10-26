/// Ranges for the personal fields, checked before a profile is saved.
class PersonalInfoValidator {
  const PersonalInfoValidator._();

  static const int maxAge = 120;
  static const double maxWeightKg = 400;
  static const double maxHeightCm = 300;

  static bool isValidAge(int? age) => age != null && age > 0 && age <= maxAge;

  static bool isValidWeightKg(double? weight) =>
      weight != null && weight.isFinite && weight > 0 && weight <= maxWeightKg;

  static bool isValidHeightCm(double? height) =>
      height != null && height.isFinite && height > 0 && height <= maxHeightCm;
}
