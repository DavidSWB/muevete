enum ExerciseLevel {
  beginner,
  intermediate,
  advanced;

  factory ExerciseLevel.fromString(String value) {
    switch (value) {
      case 'beginner':
        return ExerciseLevel.beginner;

      case 'intermediate':
        return ExerciseLevel.intermediate;

      case 'advanced':
        return ExerciseLevel.advanced;

      default:
        throw Exception('Nivel desconocido: $value');
    }
  }

  String get value {
    switch (this) {
      case ExerciseLevel.beginner:
        return 'beginner';

      case ExerciseLevel.intermediate:
        return 'intermediate';

      case ExerciseLevel.advanced:
        return 'advanced';
    }
  }
}