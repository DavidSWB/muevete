import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/services/body_measure_options.dart';
import 'package:muevete/shared/widgets/wheel_time_picker.dart';

void main() {
  group('BodyMeasureOptions', () {
    test('converts pounds to kilograms to 0.1 kg', () {
      expect(BodyMeasureOptions.lbsToKg(155), 70.3);
      expect(BodyMeasureOptions.lbsToKg(220), 99.8);
      expect(BodyMeasureOptions.kgToLbs(70).round(), 154);
    });

    test('offers the documented ranges and steps', () {
      final ages = BodyMeasureOptions.ages();
      expect(ages.first, 13);
      expect(ages.last, 100);

      final heights = BodyMeasureOptions.heightsCm();
      expect(heights.first, 100);
      expect(heights.last, 230);

      final weights = BodyMeasureOptions.weightsKg();
      expect(weights.first, 30);
      expect(weights[1], 30.5);
      expect(weights.last, 250);
    });

    test('keeps a stored value the ranges do not cover', () {
      expect(BodyMeasureOptions.ages(current: 110), contains(110));
      expect(BodyMeasureOptions.weightsKg(current: 70.3), contains(70.3));
      expect(BodyMeasureOptions.heightsCm(current: 250), contains(250));

      final weights = BodyMeasureOptions.weightsKg(current: 70.3);
      expect(weights, orderedEquals([...weights]..sort()));
    });

    test('finds the closest option', () {
      expect(BodyMeasureOptions.closestIndex([30, 30.5, 31], 30.4), 1);
    });
  });

  group('showWheelTimePicker', () {
    Future<TimeOfDay?> pick(
      WidgetTester tester, {
      required bool use24Hour,
      required Future<void> Function() interact,
    }) async {
      TimeOfDay? result;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(alwaysUse24HourFormat: use24Hour),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showWheelTimePicker(
                    context,
                    initialTime: const TimeOfDay(hour: 9, minute: 30),
                    title: 'Start time',
                    doneLabel: 'Done',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await interact();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('picks hours and minutes in 24-hour format', (tester) async {
      final time = await pick(
        tester,
        use24Hour: true,
        interact: () async {
          expect(find.text('09'), findsOneWidget);
          await tester.tap(find.text('10'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('31'));
          await tester.pumpAndSettle();
        },
      );
      expect(time, const TimeOfDay(hour: 10, minute: 31));
    });

    testWidgets('switches to the afternoon in 12-hour format', (tester) async {
      final time = await pick(
        tester,
        use24Hour: false,
        interact: () async {
          await tester.tap(find.text('PM'));
          await tester.pumpAndSettle();
        },
      );
      expect(time, const TimeOfDay(hour: 21, minute: 30));
    });

    testWidgets('dismissing returns nothing', (tester) async {
      TimeOfDay? result = const TimeOfDay(hour: 0, minute: 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showWheelTimePicker(
                    context,
                    initialTime: const TimeOfDay(hour: 9, minute: 30),
                    title: 'Start time',
                    doneLabel: 'Done',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });
}
