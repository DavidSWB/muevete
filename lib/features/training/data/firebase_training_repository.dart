import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/repositories/training_repository.dart';

class FirebaseTrainingRepository implements TrainingRepository{
  FirebaseTrainingRepository({
    required FirebaseFirestore firestore,  

  }): _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<TrainingPlan> getPlan(String id) async{
    final snapshot = await _firestore
      .collection('plans')
      .doc(id)
      .get();

    final data = snapshot.data()!;

    return TrainingPlan.fromJson({
      ...data,
      "planId": snapshot.id,
    });
  }
}