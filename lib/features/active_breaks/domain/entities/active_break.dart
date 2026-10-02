class ActiveBreak {
  const ActiveBreak({
    required this.activeBreakId,
    required this.name,
    required this.durationMinutes,
    required this.description,
    required this.templates,
  });

  final String activeBreakId;
  final Map<String, String> name;
  final int durationMinutes;
  final Map<String, String> description;
  final List<ActiveBreakTemplate> templates;

  ActiveBreakTemplate get firstTemplate => templates.first;
}

class ActiveBreakTemplate {
  const ActiveBreakTemplate({
    required this.session,
    required this.name,
    required this.exercises,
  });

  final int session;
  final Map<String, String> name;
  final List<ActiveBreakExerciseReference> exercises;
}

class ActiveBreakExerciseReference {
  const ActiveBreakExerciseReference({
    required this.exerciseId,
    required this.variantId,
    required this.type,
    required this.durationSeconds,
  });

  final String exerciseId;
  final String variantId;
  final String type;
  final int durationSeconds;
}
