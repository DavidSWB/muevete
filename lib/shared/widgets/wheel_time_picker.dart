import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/wheel_picker.dart';

/// Picks a time on hour and minute wheels, in 12- or 24-hour format as the
/// device shows times. Returns null when dismissed.
Future<TimeOfDay?> showWheelTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  required String title,
  required String doneLabel,
  String? hourLabel,
  String? minuteLabel,
}) {
  return showWheelPickerSheet<TimeOfDay>(
    context,
    title: title,
    doneLabel: doneLabel,
    initialValue: initialTime,
    wheelBuilder: (onChanged) => TimeWheels(
      initialTime: initialTime,
      onChanged: onChanged,
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
      hourLabel: hourLabel,
      minuteLabel: minuteLabel,
    ),
  );
}

class TimeWheels extends StatefulWidget {
  const TimeWheels({
    super.key,
    required this.initialTime,
    required this.onChanged,
    required this.use24Hour,
    this.hourLabel,
    this.minuteLabel,
  });

  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onChanged;
  final bool use24Hour;
  final String? hourLabel;
  final String? minuteLabel;

  @override
  State<TimeWheels> createState() => _TimeWheelsState();
}

class _TimeWheelsState extends State<TimeWheels> {
  late int _hour = widget.initialTime.hour;
  late int _minute = widget.initialTime.minute;

  void _emit() => widget.onChanged(TimeOfDay(hour: _hour, minute: _minute));

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final isPm = _hour >= 12;

    final hourWheel = widget.use24Hour
        ? WheelPicker(
            key: const ValueKey('time-hour-wheel'),
            itemCount: 24,
            initialIndex: _hour,
            labelBuilder: _twoDigits,
            onSelected: (index) {
              _hour = index;
              _emit();
            },
            width: 96,
            semanticsLabel: widget.hourLabel,
          )
        : WheelPicker(
            // Index 0 is 12, then 1 to 11.
            key: const ValueKey('time-hour-wheel'),
            itemCount: 12,
            initialIndex: _hour % 12,
            labelBuilder: (index) => '${index == 0 ? 12 : index}',
            onSelected: (index) {
              _hour = index + (_hour >= 12 ? 12 : 0);
              _emit();
            },
            width: 96,
            semanticsLabel: widget.hourLabel,
          );

    return WheelPickerBand(
      children: [
        hourWheel,
        const Text(
          ':',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        WheelPicker(
          key: const ValueKey('time-minute-wheel'),
          itemCount: 60,
          initialIndex: _minute,
          labelBuilder: _twoDigits,
          onSelected: (index) {
            _minute = index;
            _emit();
          },
          width: 96,
          semanticsLabel: widget.minuteLabel,
        ),
        if (!widget.use24Hour) ...[
          const SizedBox(width: 8),
          WheelPicker(
            key: const ValueKey('time-period-wheel'),
            itemCount: 2,
            initialIndex: isPm ? 1 : 0,
            labelBuilder: (index) => index == 0
                ? material.anteMeridiemAbbreviation
                : material.postMeridiemAbbreviation,
            onSelected: (index) {
              _hour = _hour % 12 + (index == 1 ? 12 : 0);
              _emit();
            },
            width: 80,
            selectedFontSize: 30,
          ),
        ],
      ],
    );
  }
}
