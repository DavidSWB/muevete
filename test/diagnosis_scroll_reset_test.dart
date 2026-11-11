import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosisState.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:muevete/features/diagnosis/presentation/screens/diagnosis_screen.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/widgets/my_quiz_image.dart';

/// Every diagnosis question must open scrolled to the top, so its image and
/// heading are visible, even if the previous one was scrolled down.
void main() {
  Question question(int order) => Question(
    id: 'q$order',
    question: {'es': 'Pregunta $order', 'en': 'Question $order'},
    categories: const ['hip'],
    imagePath: '',
    order: order,
    options: [
      for (var i = 1; i <= 8; i++)
        QuestionOption(
          text: {
            'es': 'Opción $order.$i con un texto largo para ocupar espacio',
            'en': 'Option $order.$i with a long text that takes up room',
          },
          value: i,
        ),
    ],
  );

  final questions = [question(1), question(2), question(3)];

  Future<void> pumpScreen(WidgetTester tester, {int start = 0}) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diagnosisProvider.overrideWith(
            () => _FakeDiagnosisNotifier(
              DiagnosisState(
                questions: questions,
                currentQuestion: start,
                answers: const {},
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DiagnosisScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double offset(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .pixels;

  /// Scrolls the question down and picks its last option.
  Future<void> scrollDownAndAnswer(WidgetTester tester) async {
    final lastOption = find.textContaining('.8 with a long text');
    await tester.scrollUntilVisible(
      lastOption,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(offset(tester), greaterThan(0));
    await tester.tap(lastOption);
    await tester.pump();
  }

  void expectTopVisible(WidgetTester tester, String heading) {
    expect(offset(tester), 0);
    final screen = tester.getRect(find.byType(Scaffold).first);
    final image = tester.getRect(find.byType(MyQuizImage));
    final title = tester.getRect(find.text(heading));
    expect(image.top, greaterThanOrEqualTo(screen.top));
    expect(title.bottom, lessThanOrEqualTo(screen.bottom));
  }

  testWidgets('the next question starts at the top', (tester) async {
    await pumpScreen(tester);
    await scrollDownAndAnswer(tester);

    await tester.tap(find.byKey(const ValueKey('diagnosis-next-button')));
    await tester.pumpAndSettle();

    expect(find.text('Question 2'), findsOneWidget);
    expectTopVisible(tester, 'Question 2');
  });

  testWidgets('going back also starts at the top', (tester) async {
    await pumpScreen(tester, start: 1);
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(offset(tester), greaterThan(0));

    await tester.tap(find.byKey(const ValueKey('diagnosis-previous-button')));
    await tester.pumpAndSettle();

    expect(find.text('Question 1'), findsOneWidget);
    expectTopVisible(tester, 'Question 1');
  });

  testWidgets('scrolling within one question still works', (tester) async {
    await pumpScreen(tester);
    await scrollDownAndAnswer(tester);

    // Selecting an option rebuilds the question but must not jump back up.
    expect(offset(tester), greaterThan(0));
    expect(find.text('Question 1'), findsOneWidget);
  });
}

class _FakeDiagnosisNotifier extends DiagnosisNotifier {
  _FakeDiagnosisNotifier(this._state);

  DiagnosisState _state;

  @override
  Future<DiagnosisState> build() async => _state;

  @override
  void answer(String questionId, int value) {
    _state = _state.copyWith(answers: {..._state.answers, questionId: value});
    state = AsyncData(_state);
  }

  @override
  void nextQuestion() {
    _state = _state.copyWith(currentQuestion: _state.currentQuestion + 1);
    state = AsyncData(_state);
  }

  @override
  void previousQuestion() {
    _state = _state.copyWith(currentQuestion: _state.currentQuestion - 1);
    state = AsyncData(_state);
  }

  @override
  Future<void> finish() async {}
}
