import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';
import 'package:muevete/features/diagnosis/domain/services/diagnosis_calculator.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/services/variantSelector.dart';

/// The upload file for the `questions` collection and how the existing
/// diagnosis engine treats the new "No sé" answer (value 1).
void main() {
  final questions =
      (jsonDecode(
                File('firebase/scripts/data/questions.json').readAsStringSync(),
              )
              as List)
          .map((raw) => Question.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
  final calculator = DiagnosisCalculator();
  final levels = Variantselector();

  QuestionOption dontKnow(Question q) =>
      q.options.singleWhere((o) => o.text['es'] == 'No sé');

  /// Answers every question with [pick] and returns the per-joint result.
  Diagnosis answerAll(int Function(Question q) pick) => calculator.calculate(
    questions,
    {for (final q in questions) q.id: pick(q)},
  );

  test('every question offers "No sé" / "I don\'t know" with value 1', () {
    expect(questions, hasLength(5));
    for (final q in questions) {
      final option = dontKnow(q);
      expect(option.value, 1, reason: q.id);
      expect(option.text['en'], "I don't know");
      expect(q.question.localizedWithCode('es'), isNotEmpty);
      expect(q.question.localizedWithCode('en'), isNotEmpty);
      for (final o in q.options) {
        expect(o.text.keys, containsAll(['es', 'en']), reason: q.id);
      }
    }
  });

  test('"No sé" on every question gives beginner for every joint', () {
    final result = answerAll((q) => dontKnow(q).value);

    for (final value in [
      result.ankle,
      result.knee,
      result.hip,
      result.shoulder,
    ]) {
      expect(value, 1);
      expect(levels.calculateLevel(value), ExerciseLevel.beginner);
    }
  });

  test('existing answers keep their results', () {
    final best = answerAll(
      (q) => q.options.map((o) => o.value).reduce((a, b) => a > b ? a : b),
    );
    expect(best.ankle, 5);
    expect(best.knee, 5);
    expect(best.shoulder, 5);
    // The flexibility question goes up to 6, so the hip average exceeds 5.
    expect(best.hip, closeTo(16 / 3, 1e-9));
    expect(levels.calculateLevel(best.shoulder), ExerciseLevel.advanced);

    final middle = answerAll((q) => 3);
    expect(levels.calculateLevel(middle.knee), ExerciseLevel.intermediate);
  });

  test('"No sé" is averaged like any 1: with a 5 it gives intermediate', () {
    // Shoulder comes from two questions. The engine averages them, as agreed
    // for now, so one "No sé" does not force beginner on its own.
    final shoulderQuestions = questions
        .where((q) => q.categories.contains('shoulder'))
        .toList();
    expect(shoulderQuestions, hasLength(2));

    final result = calculator.calculate(questions, {
      for (final q in questions) q.id: 3,
      shoulderQuestions[0].id: dontKnow(shoulderQuestions[0]).value,
      shoulderQuestions[1].id: 5,
    });
    expect(result.shoulder, 3);
    expect(levels.calculateLevel(result.shoulder), ExerciseLevel.intermediate);
  });

  test('plain-text questions from the old collection read as Spanish', () {
    final legacy = Question.fromJson({
      'id': 'old',
      'question': '¿Pregunta?',
      'options': [
        {'text': 'Sí', 'value': 2},
      ],
      'categories': ['hip'],
      'imagePath': '',
      'order': 1,
    });

    expect(legacy.question.localizedWithCode('en'), '¿Pregunta?');
    expect(legacy.options.single.text.localizedWithCode('es'), 'Sí');
  });
}
