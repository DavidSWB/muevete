import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosis.dart';

class FirebaseDiagnosisRepository implements DiagnosisRepository{

  FirebaseDiagnosisRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,  
  }): _auth = auth,
      _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  @override
  Future<void> saveDiagnosis(Diagnosis diagnosis) async{
    await _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .update({
        'stats': diagnosis.toJson(),
      });
  }
}