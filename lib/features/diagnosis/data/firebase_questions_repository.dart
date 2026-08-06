import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/diagnosis/domain/repositories/questions_repository.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';

class FirebaseQuestionsRepository implements QuestionsRepository{

   FirebaseQuestionsRepository(
      this._firestore,
  );

  final FirebaseFirestore _firestore;

  @override
  Future<List<Question>> getQuestions () async {
    final snapshot =  await _firestore
                        .collection('preguntas')
                        .get();
    
    final questions = snapshot.docs
    .map((doc){ 
      final json = doc.data();

      return Question.fromJson({
        ...json,
        'id': doc.id,
      });
    });
    
    return questions.toList();
  }
}
