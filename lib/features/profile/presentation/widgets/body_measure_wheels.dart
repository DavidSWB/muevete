import 'package:flutter/material.dart';
import 'package:muevete/features/profile/domain/services/body_measure_options.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/widgets/wheel_picker.dart';

/// Age in whole years.
class AgeWheel extends StatefulWidget {
  const AgeWheel({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<AgeWheel> createState() => _AgeWheelState();
}

class _AgeWheelState extends State<AgeWheel> {
  // Fixed for the wheel's lifetime, so indices never shift under it.
  late final List<int> _ages = BodyMeasureOptions.ages(current: widget.value);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return WheelPickerBand(
      unit: l10n.unitYears,
      children: [
        WheelPicker(
          key: const ValueKey('age-wheel'),
          itemCount: _ages.length,
          initialIndex: BodyMeasureOptions.closestIndex(_ages, widget.value),
          labelBuilder: (index) => '${_ages[index]}',
          onSelected: (index) => widget.onChanged(_ages[index]),
          semanticsLabel: l10n.profileAgeLabel,
        ),
      ],
    );
  }
}

/// Height in whole centimetres.
class HeightWheel extends StatefulWidget {
  const HeightWheel({
    super.key,
    required this.valueCm,
    required this.onChanged,
  });

  final double valueCm;
  final ValueChanged<double> onChanged;

  @override
  State<HeightWheel> createState() => _HeightWheelState();
}

class _HeightWheelState extends State<HeightWheel> {
  late final List<int> _heights = BodyMeasureOptions.heightsCm(
    current: widget.valueCm,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return WheelPickerBand(
      unit: l10n.unitCm,
      children: [
        WheelPicker(
          key: const ValueKey('height-wheel'),
          itemCount: _heights.length,
          initialIndex: BodyMeasureOptions.closestIndex(
            _heights,
            widget.valueCm,
          ),
          labelBuilder: (index) => '${_heights[index]}',
          onSelected: (index) => widget.onChanged(_heights[index].toDouble()),
          semanticsLabel: l10n.profileHeightLabel,
        ),
      ],
    );
  }
}

/// Weight in kg (0.5 kg steps) or lbs (whole pounds), chosen on a second
/// wheel. [onChanged] always reports kilograms.
class WeightWheel extends StatefulWidget {
  const WeightWheel({
    super.key,
    required this.valueKg,
    required this.onChanged,
  });

  final double valueKg;
  final ValueChanged<double> onChanged;

  @override
  State<WeightWheel> createState() => _WeightWheelState();
}

class _WeightWheelState extends State<WeightWheel> {
  WeightUnit _unit = WeightUnit.kg;
  late double _kg = widget.valueKg;
  late List<num> _values = _optionsFor(_unit);

  List<num> _optionsFor(WeightUnit unit) => switch (unit) {
    WeightUnit.kg => BodyMeasureOptions.weightsKg(current: _kg),
    WeightUnit.lbs => BodyMeasureOptions.weightsLbs(currentKg: _kg),
  };

  int get _initialIndex => BodyMeasureOptions.closestIndex(
    _values,
    _unit == WeightUnit.kg ? _kg : BodyMeasureOptions.kgToLbs(_kg),
  );

  void _onValue(int index) {
    final value = _values[index];
    _kg = _unit == WeightUnit.kg
        ? value.toDouble()
        : BodyMeasureOptions.lbsToKg(value);
    widget.onChanged(_kg);
  }

  void _onUnit(int index) {
    // The weight itself doesn't change; only how it is shown.
    setState(() {
      _unit = WeightUnit.values[index];
      _values = _optionsFor(_unit);
    });
  }

  static String _format(num value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = [l10n.unitKg, l10n.unitLbs];

    return WheelPickerBand(
      children: [
        WheelPicker(
          // A new wheel per unit, starting at the converted weight.
          key: ValueKey('weight-wheel-${_unit.name}'),
          itemCount: _values.length,
          initialIndex: _initialIndex,
          labelBuilder: (index) => _format(_values[index]),
          onSelected: _onValue,
          width: 140,
          semanticsLabel: l10n.profileWeightLabel,
        ),
        const SizedBox(width: 12),
        WheelPicker(
          key: const ValueKey('weight-unit-wheel'),
          itemCount: units.length,
          initialIndex: _unit.index,
          labelBuilder: (index) => units[index],
          onSelected: _onUnit,
          width: 90,
          selectedFontSize: 36,
        ),
      ],
    );
  }
}
