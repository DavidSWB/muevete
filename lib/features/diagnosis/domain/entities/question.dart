class Question {
  const Question({
    required this.id,
    required this.question,
    required this.categories,
    required this.imagePath,
    required this.options,
    required this.order,
  });

  final String id;
  /// Localized text by language code, e.g. {'es': ..., 'en': ...}.
  final Map<String, String> question;
  final List<String> categories;
  final String imagePath;
  final List<QuestionOption> options;
  final int order;

  // --- CONSTRUCTOR FACTORY PARA FIREBASE ---
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      question: localizedText(json['question']),
      
      // Convertimos la lista dynamic de Firebase a List<String> de forma segura
      categories: List<String>.from(json['categories'] ?? []),
      
      imagePath: json['imagePath'] as String? ?? '',
      
      // Mapeamos la lista de mapas al modelo QuestionOption
      options: (json['options'] as List<dynamic>?)
              ?.map((optionJson) => QuestionOption.fromJson(optionJson as Map<String, dynamic>))
              .toList() ?? [],
              
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'categories': categories,
      'imagePath': imagePath,
      'options': options.map((option) => option.toJson()).toList(),
      'order': order,
    };
  }
}

class QuestionOption {
  const QuestionOption({
    required this.text, 
    required this.value,
  });
  
  /// Localized text by language code, e.g. {'es': ..., 'en': ...}.
  final Map<String, String> text;
  final int value;

  // --- CONSTRUCTOR FACTORY PARA OPCIONES ---
  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      text: localizedText(json['text']),
      value: json['value'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'value': value,
    };
  }
}

/// Reads a `{es, en}` map. A plain string, the format of the old `preguntas`
/// collection, is read as Spanish so older data still shows.
Map<String, String> localizedText(dynamic value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        if (entry.key is String && entry.value is String)
          entry.key as String: entry.value as String,
    };
  }
  if (value is String && value.isNotEmpty) return {'es': value};
  return const {};
}
