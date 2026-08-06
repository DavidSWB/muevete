import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/training/domain/entities/progessionrules.dart';
import 'package:muevete/features/training/domain/repositories/progression_repository.dart';

class FirebaseProgressionRepository implements ProgressionRepository{
  FirebaseProgressionRepository({
    required FirebaseFirestore firestore,  
  }): _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<ProgessionRules> getRules(
    type,
    level,
  ) async {
    String userLevel = level == 'advanced' ? 'compound_advanced' : 'compound_beginner';
    final snapshot = await _firestore
      .collection('progression_rules')
      .doc(userLevel)
      .get();

    final data = snapshot.data()!;
    
    return ProgessionRules.fromJson({
      ...data,
      "id": snapshot.id,
    });
  }

}