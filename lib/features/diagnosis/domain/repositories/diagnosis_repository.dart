import 'package:muevete/features/diagnosis/domain/entities/diagnosis.dart';

abstract class DiagnosisRepository {

  Future <void> saveDiagnosis(Diagnosis diagnosis);

}