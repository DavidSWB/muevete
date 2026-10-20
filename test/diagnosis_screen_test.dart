import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosisState.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:muevete/features/diagnosis/presentation/screens/diagnosis_screen.dart';
import 'package:muevete/features/diagnosis/presentation/widgets/my_quizoption_button.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/widgets/my_quiz_image.dart';

void main() {
  final testQuestions = [
    const Question(
      id: 'q1',
      question: 'Can you hold a plank for 30 seconds?',
      categories: ['core'],
      imagePath: 'assets/images/plank.gif',
      options: [
        QuestionOption(text: 'Yes, easily', value: 3),
        QuestionOption(text: 'With some struggle', value: 2),
        QuestionOption(text: 'No, unable', value: 1),
      ],
      order: 1,
    ),
    const Question(
      id: 'q2',
      question: 'Can you touch your toes with straight legs?',
      categories: ['flexibility'],
      imagePath: '',
      options: [
        QuestionOption(text: 'Yes, palms to floor', value: 3),
        QuestionOption(text: 'Fingertips only', value: 2),
        QuestionOption(text: 'Cannot reach', value: 1),
      ],
      order: 2,
    ),
  ];

  Widget createSubject({required DiagnosisState state}) {
    return ProviderScope(
      overrides: [
        diagnosisProvider.overrideWith(() => _FakeDiagnosisNotifier(state)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DiagnosisScreen(),
      ),
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
    'DiagnosisScreen renders 16:9 media, question, and unselected options',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = DiagnosisState(
        questions: testQuestions,
        currentQuestion: 0,
        answers: {},
      );

      await tester.pumpWidget(createSubject(state: state));
      await tester.pumpAndSettle();

      // Verify 16:9 media banner exists with ValueKey
      expect(
        find.byKey(const ValueKey('diagnosis-exercise-visual')),
        findsOneWidget,
      );

      // Verify question prompt
      expect(find.text('Can you hold a plank for 30 seconds?'), findsOneWidget);

      // Verify all 3 options are rendered
      expect(find.text('Yes, easily'), findsOneWidget);
      expect(find.text('With some struggle'), findsOneWidget);
      expect(find.text('No, unable'), findsOneWidget);

      // All options start unselected
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Next button is disabled initially
      final nextButtonFinder = find.byKey(
        const ValueKey('diagnosis-next-button'),
      );
      expect(nextButtonFinder, findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(nextButtonFinder);
      expect(elevatedButton.onPressed, isNull);

      // Previous button should not be shown on question 1 (order == 1)
      expect(
        find.byKey(const ValueKey('diagnosis-previous-button')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Tapping option updates selection state and enables Next button',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = DiagnosisState(
        questions: testQuestions,
        currentQuestion: 0,
        answers: {},
      );

      await tester.pumpWidget(createSubject(state: state));
      await tester.pumpAndSettle();

      // Tap first option
      await tester.ensureVisible(find.text('Yes, easily'));
      await tester.tap(find.text('Yes, easily'));
      await tester.pumpAndSettle();

      // One option should now be checked
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));

      // Next button is now enabled
      final nextButtonFinder = find.byKey(
        const ValueKey('diagnosis-next-button'),
      );
      final elevatedButton = tester.widget<ElevatedButton>(nextButtonFinder);
      expect(elevatedButton.onPressed, isNotNull);
    },
  );

  testWidgets(
    'Next and Previous question navigation advances and resets selection',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = DiagnosisState(
        questions: testQuestions,
        currentQuestion: 0,
        answers: {},
      );

      await tester.pumpWidget(createSubject(state: state));
      await tester.pumpAndSettle();

      // Select an option and advance
      await tester.ensureVisible(find.text('Yes, easily'));
      await tester.tap(find.text('Yes, easily'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('diagnosis-next-button')));
      await tester.pumpAndSettle();

      // Now on question 2
      expect(
        find.text('Can you touch your toes with straight legs?'),
        findsOneWidget,
      );

      // Selection is reset
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));

      // Previous button is now visible
      expect(
        find.byKey(const ValueKey('diagnosis-previous-button')),
        findsOneWidget,
      );

      // Tap previous button
      await tester.tap(find.byKey(const ValueKey('diagnosis-previous-button')));
      await tester.pumpAndSettle();

      // Back on question 1
      expect(find.text('Can you hold a plank for 30 seconds?'), findsOneWidget);
    },
  );

  testWidgets(
    'MyQuizImage renders fallback gracefully when imagePath is empty',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MyQuizImage(imagePath: '')),
        ),
      );

      expect(
        find.byKey(const ValueKey('diagnosis-exercise-visual')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    },
  );

  testWidgets('MyQuizoptionButton wraps long text without overflow', (
    WidgetTester tester,
  ) async {
    const longText =
        'This is an exceptionally long option description intended to verify that multiline wrapping occurs cleanly without triggering any RenderFlex overflows on narrow screens.';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 250,
            child: MyQuizoptionButton(
              text: longText,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text(longText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeDiagnosisNotifier extends DiagnosisNotifier {
  _FakeDiagnosisNotifier(this._state);

  DiagnosisState _state;

  @override
  Future<DiagnosisState> build() async => _state;

  @override
  void answer(String questionId, int value) {
    final updated = Map<String, int>.from(_state.answers);
    updated[questionId] = value;
    _state = _state.copyWith(answers: updated);
    state = AsyncData(_state);
  }

  @override
  void nextQuestion() {
    if (_state.currentQuestion < _state.questions.length - 1) {
      _state = _state.copyWith(currentQuestion: _state.currentQuestion + 1);
      state = AsyncData(_state);
    }
  }

  @override
  void previousQuestion() {
    if (_state.currentQuestion > 0) {
      _state = _state.copyWith(currentQuestion: _state.currentQuestion - 1);
      state = AsyncData(_state);
    }
  }

  @override
  Future<void> finish() async {}
}
