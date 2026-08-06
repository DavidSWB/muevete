import 'package:muevete/features/diagnosis/domain/entities/question.dart';

class DiagnosisState {

  final List<Question> questions;
  final int currentQuestion;
  final Map<String, int> answers;

  const DiagnosisState({
    required this.questions,
    required this.currentQuestion,
    required this.answers,
  });

  DiagnosisState copyWith({
    List<Question>? questions,
    int? currentQuestion,
    Map<String, int>? answers,
  }) {
    return DiagnosisState(
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      answers: answers ?? this.answers,
    );
  }
}