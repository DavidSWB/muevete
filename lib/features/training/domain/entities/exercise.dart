import 'package:muevete/features/training/domain/entities/exercise_type.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';

class Exercise {

  final String exerciseId;

  final Map<String, String> name;

  final ExerciseType type;

  final List<String> targets;

  final List<ExerciseVariant> variants;

  const Exercise({
    required this.exerciseId,
    required this.name,
    required this.type,
    required this.targets,
    required this.variants,
  });

  factory Exercise.fromJson(Map<String, dynamic> json){

    return Exercise(

      exerciseId: json["exerciseId"],

      name: Map<String,String>.from(json["name"]),

      type: ExerciseType.values.firstWhere(
        (e) => e.name == json["type"],
      ),

      targets:
          (json["targets"] as List<dynamic>)
              .map((e) => e.toString())
              .toList(),

      variants: (json["variants"] as List)
          .map((e) => ExerciseVariant.fromJson(e))
          .toList(),

          );

  }

  Map<String,dynamic> toJson(){

    return {

      "exerciseId": exerciseId,

      "name": name,

      "type": type.name,

      "targets": targets,

      "variants":
          variants
              .map((e) => e.toJson())
              .toList(),

    };

  }

}