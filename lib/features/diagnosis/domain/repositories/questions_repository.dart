import 'package:muevete/features/diagnosis/domain/entities/question.dart';

abstract class QuestionsRepository {
  Future <List<Question>> getQuestions();
}