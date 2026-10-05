import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_type.dart';
import 'package:muevete/features/training/domain/entities/progessionrules.dart';
import 'package:muevete/features/training/domain/repositories/progression_repository.dart';

class FirebaseProgressionRepository implements ProgressionRepository {
  FirebaseProgressionRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<ProgessionRules> getRules(
    ExerciseType type,
    ExerciseLevel level,
    bool hold,
  ) async {
    final snapshot = await _firestore
        .collection('progression_rules')
        .doc(type.name)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw StateError(
        'Progression rules not found for type: ${type.name}',
      );
    }

    final data = snapshot.data()!;
    final modeKey = hold ? 'hold' : 'reps';
    final modeData = data[modeKey] as Map<String, dynamic>;

    // compound / accessory: tienen sub-niveles con cycle y reset
    if (type == ExerciseType.compound || type == ExerciseType.accessory) {
      final levelData = modeData[level.name] as Map<String, dynamic>;
      final cycle = (levelData['cycle'] as List)
          .map((c) => ProgressionStep.fromJson(c as Map<String, dynamic>))
          .toList();
      return ProgessionRules(
        id: '${type.name}_${level.name}',
        cycle: cycle,
        reset: levelData['reset'] as bool,
        level: level.name,
        type: type.name,
      );
    }

    // mobility / flexibility: estructura plana, sin sub-niveles
    return ProgessionRules(
      id: type.name,
      cycle: [
        ProgressionStep(
          week: 1,
          sets: modeData['sets'] as int,
          reps: modeData['minReps'] as int?,
        ),
      ],
      reset: modeData['reset'] as bool,
      level: level.name,
      type: type.name,
    );
  }
}