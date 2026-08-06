import 'package:muevete/features/training/domain/entities/exercise_level.dart';

class ExerciseVariant {
  final String variantId;

  final Map<String, String> name;

  final Map<String, String> description;

  final String visualPath;

  final ExerciseLevel requiredLevel;

  const ExerciseVariant({
    required this.variantId,
    required this.name,
    required this.description,
    required this.visualPath,
    required this.requiredLevel,
  });

  factory ExerciseVariant.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExerciseVariant(
      variantId: json["variantId"],

      name: Map<String, String>.from(
        json["name"],
      ),

      description: Map<String, String>.from(
        json["description"],
      ),

      visualPath: json["visualPath"],

      requiredLevel: ExerciseLevel.values.firstWhere(
        (e) => e.name == json["requiredLevel"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "variantId": variantId,
      "name": name,
      "description": description,
      "visualPath": visualPath,
      "requiredLevel": requiredLevel.name,
    };
  }

  ExerciseVariant copyWith({
    String? variantId,
    Map<String, String>? name,
    Map<String, String>? description,
    String? visualPath,
    ExerciseLevel? requiredLevel,
  }) {
    return ExerciseVariant(
      variantId: variantId ?? this.variantId,
      name: name ?? this.name,
      description: description ?? this.description,
      visualPath: visualPath ?? this.visualPath,
      requiredLevel: requiredLevel ?? this.requiredLevel,
    );
  }
}