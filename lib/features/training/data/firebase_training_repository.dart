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

    if (!snapshot.exists || snapshot.data() == null) {
      throw StateError('Training plan not found: $id');
    }

    return _parsePlan(snapshot.id, snapshot.data()!);
  }

  @override
  Future<List<TrainingPlan>> getPlans() async {
    final snapshot = await _firestore.collection('plans').get();

    return snapshot.docs
        .map((doc) => _parsePlan(doc.id, doc.data()))
        .toList();
  }

  TrainingPlan _parsePlan(String id, Map<String, dynamic> data) {
    try {
      return TrainingPlan.fromJson({
        ...data,
        'planId': id,
      });
    } catch (error) {
      throw FormatException('Invalid training plan: $id', error);
    }
  }
}
