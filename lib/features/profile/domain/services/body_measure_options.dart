/// Units the weight picker offers. Profiles always store kilograms.
enum WeightUnit { kg, lbs }

/// The values the age, height and weight pickers offer, all inside
/// [PersonalInfoValidator]'s ranges. A stored value outside them is added,
/// so opening a picker never changes a saved value.
class BodyMeasureOptions {
  const BodyMeasureOptions._();

  static const int minAge = 13;
  static const int maxAge = 100;
  static const int defaultAge = 30;

  static const int minHeightCm = 100;
  static const int maxHeightCm = 230;
  static const int defaultHeightCm = 170;

  static const double minWeightKg = 30;
  static const double maxWeightKg = 250;
  static const double weightStepKg = 0.5;
  static const double defaultWeightKg = 70;

  static const int minWeightLbs = 66;
  static const int maxWeightLbs = 551;

  static const double _lbsPerKg = 2.20462262185;

  static List<int> ages({int? current}) =>
      _withCurrent(_range(minAge, maxAge), current);

  static List<int> heightsCm({double? current}) =>
      _withCurrent(_range(minHeightCm, maxHeightCm), current?.round());

  static List<double> weightsKg({double? current}) {
    final steps = ((maxWeightKg - minWeightKg) / weightStepKg).round();
    final values = [
      for (var i = 0; i <= steps; i++) minWeightKg + i * weightStepKg,
    ];
    return _withCurrent(values, current);
  }

  static List<int> weightsLbs({double? currentKg}) => _withCurrent(
    _range(minWeightLbs, maxWeightLbs),
    currentKg == null ? null : kgToLbs(currentKg).round(),
  );

  static double kgToLbs(double kg) => kg * _lbsPerKg;

  /// Kilograms to store for a weight picked in pounds, to 0.1 kg.
  static double lbsToKg(num lbs) => (lbs / _lbsPerKg * 10).round() / 10;

  /// Index of the value in [values] closest to [target].
  static int closestIndex(List<num> values, num target) {
    var best = 0;
    for (var i = 1; i < values.length; i++) {
      if ((values[i] - target).abs() < (values[best] - target).abs()) best = i;
    }
    return best;
  }

  static List<int> _range(int min, int max) => [
    for (var value = min; value <= max; value++) value,
  ];

  static List<T> _withCurrent<T extends num>(List<T> values, T? current) {
    if (current == null || !current.isFinite || values.contains(current)) {
      return values;
    }
    return [...values, current]..sort();
  }
}
