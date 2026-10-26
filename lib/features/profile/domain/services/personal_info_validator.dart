/// Ranges shared by sign-up and Edit Profile. Each parser returns null when
/// the text is not a valid value.
class PersonalInfoValidator {
  const PersonalInfoValidator._();

  static const int maxAge = 120;
  static const double maxWeightKg = 400;
  static const double maxHeightCm = 300;

  static int? parseAge(String text) {
    final age = int.tryParse(text.trim());
    if (age == null || age <= 0 || age > maxAge) return null;
    return age;
  }

  static double? parseWeightKg(String text) {
    final weight = double.tryParse(text.trim());
    if (weight == null ||
        !weight.isFinite ||
        weight <= 0 ||
        weight > maxWeightKg) {
      return null;
    }
    return weight;
  }

  static double? parseHeightCm(String text) {
    final height = double.tryParse(text.trim());
    if (height == null ||
        !height.isFinite ||
        height <= 0 ||
        height > maxHeightCm) {
      return null;
    }
    return height;
  }
}
