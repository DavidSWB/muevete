import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';
import 'package:muevete/features/diagnosis/domain/services/diagnosis_calculator.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/profile/domain/services/joint_stat_range.dart';

/// Per-joint stats stay within 1–5, both when the diagnosis computes them and
/// when a profile saved before the limit is read.
void main() {
  Question question(String id, List<String> categories, int maxValue) =>
      Question(
        id: id,
        question: const {'es': '?', 'en': '?'},
        categories: categories,
        imagePath: '',
        options: [
          for (var v = 1; v <= maxValue; v++)
            QuestionOption(text: {'es': '$v', 'en': '$v'}, value: v),
        ],
        order: 0,
      );

  // Same shape as the `questions` collection: the flexibility question only
  // feeds the hip and goes up to 6.
  final questions = [
    question('atgSplitSquat', ['ankle', 'knee', 'hip'], 5),
    question('flexibility', ['hip'], 6),
    question('barHang', ['shoulder'], 5),
    question('lateralSquat', ['ankle', 'knee', 'hip'], 5),
    question('overheadReach', ['shoulder'], 5),
  ];
  final calculator = DiagnosisCalculator();

  Diagnosis calculate(Map<String, int> overrides, {int base = 3}) =>
      calculator.calculate(questions, {
        for (final q in questions) q.id: base,
        ...overrides,
      });

  group('DiagnosisCalculator', () {
    test('maximum flexibility option gives hip = 5', () {
      final best = calculate({'flexibility': 6}, base: 5);

      expect(best.hip, 5);
      expect(best.knee, 5);
      expect(best.ankle, 5);
      expect(best.shoulder, 5);
    });

    test('maximum flexibility alone still averages below 5', () {
      // (3 + 6 + 3) / 3 = 4: values inside the range are not touched.
      expect(calculate({'flexibility': 6}).hip, 4);
    });

    test('values within 1–5 are unchanged', () {
      final result = calculate({
        'atgSplitSquat': 2,
        'flexibility': 5,
        'lateralSquat': 4,
        'barHang': 1,
        'overheadReach': 2,
      });

      expect(result.hip, closeTo(11 / 3, 1e-9));
      expect(result.knee, 3);
      expect(result.ankle, 3);
      expect(result.shoulder, 1.5);
    });

    test('lowest answers give 1', () {
      final worst = calculate({}, base: 1);

      expect(worst.hip, 1);
      expect(worst.knee, 1);
      expect(worst.ankle, 1);
      expect(worst.shoulder, 1);
    });
  });

  group('reading stored stats', () {
    test('stored profile with hip 6 is read as 5', () {
      final stats = UserStats.fromJson({
        'knee': 4,
        'hip': 6,
        'ankle': 3.5,
        'shoulder': 2,
      });

      expect(stats.hip, 5);
      expect(stats.getStat('hip'), 5);
      expect(stats.knee, 4);
      expect(stats.ankle, 3.5);
      expect(stats.shoulder, 2);
    });

    test('a 5.33 hip from the old calculation is read as 5', () {
      final user = UserModel.fromJson(
        id: 'u',
        json: {
          'stats': {'knee': 5, 'hip': 16 / 3, 'ankle': 5, 'shoulder': 5},
        },
      );

      expect(user.stats!.hip, 5);
      expect(user.stats!.overallLevel, 5);
    });

    test('stored stats within 1–5 are unchanged', () {
      final stats = UserStats.fromJson({
        'knee': 2,
        'hip': 3.3333333333333335,
        'ankle': 1,
        'shoulder': 4.5,
      });

      expect(stats.toJson(), {
        'knee': 2.0,
        'hip': 3.3333333333333335,
        'ankle': 1.0,
        'shoulder': 4.5,
      });
    });

    test('Diagnosis.fromJson applies the same limit', () {
      final diagnosis = Diagnosis.fromJson({
        'ankle': 2,
        'knee': 3,
        'hip': 6,
        'shoulder': 4.5,
      });

      expect(diagnosis.hip, 5);
      expect(diagnosis.ankle, 2);
      expect(diagnosis.knee, 3);
      expect(diagnosis.shoulder, 4.5);
    });
  });

  test('clampJointStat keeps values in [1, 5]', () {
    expect(clampJointStat(6), 5);
    expect(clampJointStat(5.0001), 5);
    expect(clampJointStat(0), 1);
    expect(clampJointStat(2.5), 2.5);
    expect(minJointStat, 1);
    expect(maxJointStat, 5);
  });
}
