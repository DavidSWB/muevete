import 'package:muevete/features/training/domain/entities/exercise_type.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';

class Exercise {

  final String exerciseId;

  final Map<String, String> name;

  final ExerciseType type;

  final bool hold;

  final List<String> targets;

  final List<ExerciseVariant> variants;

  const Exercise({
    required this.exerciseId,
    required this.name,
    required this.type,
    required this.hold,
    required this.targets,
    required this.variants,
  });

  factory Exercise.fromJson(Map<String, dynamic> json){
    final exerciseId = _requiredString(json['exerciseId'], 'exerciseId');
    final typeName = _requiredString(json['type'], 'type');
    final type = ExerciseType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => throw FormatException(
        'Invalid exercise type "$typeName" in exercise "$exerciseId"',
      ),
    );

    final rawVariants = json['variants'];
    if (rawVariants is! List) {
      throw FormatException('Missing variants list in exercise "$exerciseId"');
    }

    return Exercise(

      exerciseId: exerciseId,

      name: Map<String,String>.from(json["name"]),

      type: type,

      hold: json['hold'] as bool? ?? false,

      targets:
          (json["targets"] as List<dynamic>)
              .map((e) => e.toString())
              .toList(),

      variants: rawVariants
          .map((e) => ExerciseVariant.fromJson(e))
          .toList(),

          );

  }

  static String _requiredString(dynamic value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Missing $field in exercise document');
  }

  Map<String,dynamic> toJson(){

    return {

      "exerciseId": exerciseId,

      "name": name,

      "type": type.name,

      "hold": hold,

      "targets": targets,

      "variants":
          variants
              .map((e) => e.toJson())
              .toList(),

    };

  }

}
