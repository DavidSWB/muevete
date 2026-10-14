import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/workout_exercise.dart';
import 'package:muevete/features/training/presentation/screens/exercise_detail_screen.dart';

void main() {
  testWidgets('rep sets can be checked independently', (tester) async {
    await tester.pumpWidget(_detailScreen(reps: 8, sets: 2));

    expect(find.text('Reps'), findsNWidgets(3));
    expect(find.text('8'), findsNWidgets(3));

    await tester.tap(find.byTooltip('Mark set complete').first);
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('hold set displays duration, pauses, resumes, and auto-checks',
      (tester) async {
    await tester.pumpWidget(_detailScreen(duration: 2, sets: 1));

    expect(find.text('Duration'), findsNWidgets(2));
    expect(find.text('2s'), findsOneWidget);

    await tester.tap(find.byTooltip('Start timer'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byTooltip('Pause timer'));
    await tester.pump();

    expect(find.byTooltip('Start timer'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

    await tester.tap(find.byTooltip('Start timer'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('0s'), findsOneWidget);
  });

  testWidgets('unchecking a completed hold resets its timer', (tester) async {
    await tester.pumpWidget(_detailScreen(duration: 1, sets: 1));

    await tester.tap(find.byTooltip('Start timer'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byTooltip('Mark set incomplete'));
    await tester.pump();

    expect(find.text('1s'), findsOneWidget);
    expect(find.byTooltip('Start timer'), findsOneWidget);
  });
}

Widget _detailScreen({int? reps, int? duration, required int sets}) {
  return MaterialApp(
    home: ExerciseDetailScreen(
      exercise: WorkoutExercise(
        exercise: const ExerciseVariant(
          variantId: 'test',
          name: {'en': 'Test exercise'},
          description: {'en': 'Description'},
          visualPath: 'assets/images/workoutPicture.jpg',
          requiredLevel: ExerciseLevel.beginner,
        ),
        sets: sets,
        reps: reps,
        rest: 30,
        duration: duration,
      ),
    ),
  );
}
