import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/firebase_questions_repository.dart';
import '../../domain/repositories/questions_repository.dart';
import '../../../../core/firebase/firebase_providers.dart';

part 'questions_repository_providers.g.dart';

@riverpod
QuestionsRepository questionsRepository(Ref ref,){

    return FirebaseQuestionsRepository(

        ref.watch(
            firebaseFirestoreProvider,
        ),

    );

}