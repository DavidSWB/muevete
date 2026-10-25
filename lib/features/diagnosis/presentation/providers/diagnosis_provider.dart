import 'package:muevete/features/diagnosis/domain/entities/diagnosisState.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/diagnosis_calculator.dart';
import 'questions_repository_providers.dart';
import 'diagnosis_repository_providers.dart';

part 'diagnosis_provider.g.dart';

@riverpod
class DiagnosisNotifier extends _$DiagnosisNotifier {

  @override
  Future<DiagnosisState> build() async {

    final questionsRepository =
        ref.read(questionsRepositoryProvider);

    final questions =
        await questionsRepository.getQuestions();

    final sortedQuestions = questions.toList()..sort(
      (a,b) => a.order.compareTo(b.order),
    );

    return DiagnosisState(
      questions: sortedQuestions,
      currentQuestion: 0,
      answers: {},
    );
  }

  void answer(
    String questionId,
    int value,
  ){

    final diagnosis = state.value;
    if (diagnosis == null) return;

    final updatedAnswers =
        Map<String, int>.from(diagnosis.answers);

    updatedAnswers[questionId] = value;

    state = AsyncData(
      diagnosis.copyWith(
        answers: updatedAnswers,
      ),
    );

  }

  void previousQuestion() {
    final diagnosis = state.value;
    
    if (diagnosis == null) return;

    if (diagnosis.currentQuestion >= 1){

      state = AsyncData(
        diagnosis.copyWith(
          currentQuestion: diagnosis.currentQuestion - 1,
        ),
      );

    }
      
  }

  void nextQuestion() {
    final diagnosis = state.value;

    if(diagnosis == null) return;

    if (diagnosis.currentQuestion < diagnosis.questions.length - 1){

      state = AsyncData(
        diagnosis.copyWith(
          currentQuestion: diagnosis.currentQuestion + 1,
        ),
      );

    }

  }

  Future<void> finish() async {
    try{
      final diagnosis = state.value;
      if (diagnosis == null) return;

      if (diagnosis.answers.length != diagnosis.questions.length) {
        throw StateError('Cannot finish diagnosis with unanswered questions');
      }

      final userDiagnosis =

        DiagnosisCalculator().calculate(
          diagnosis.questions,
          diagnosis.answers,
        );
      final repository =
        ref.read(diagnosisRepositoryProvider);

      // Saving the stats moves onboarding past the diagnosis, which unmounts
      // DiagnosisScreen before the write returns. Stay alive until the save
      // and the profile refresh are done.
      final keepAlive = ref.keepAlive();
      try {
        await repository.saveDiagnosis(userDiagnosis);
        await ref.read(profileProvider.notifier).refresh();
      } finally {
        keepAlive.close();
      }
    }
    catch(e){
      rethrow;
    }

  }
}
