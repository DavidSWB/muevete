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
    final variantId = _requiredString(json["variantId"], "variantId");
    final requiredLevelName =
        _requiredString(json["requiredLevel"], "requiredLevel");
    final requiredLevel = ExerciseLevel.values.firstWhere(
      (e) => e.name == requiredLevelName,
      orElse: () => throw FormatException(
        'Invalid requiredLevel "$requiredLevelName" in variant "$variantId"',
      ),
    );

    return ExerciseVariant(
      variantId: variantId,

      name: Map<String, String>.from(
        json["name"],
      ),

      description: Map<String, String>.from(
        json["description"],
      ),

      visualPath: json["visualPath"],

      requiredLevel: requiredLevel,
    );
  }

  static String _requiredString(dynamic value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Missing $field in exercise variant');
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
