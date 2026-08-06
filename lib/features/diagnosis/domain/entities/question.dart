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
  final String question;
  final List<String> categories;
  final String imagePath;
  final List<QuestionOption> options;
  final int order;

  // --- CONSTRUCTOR FACTORY PARA FIREBASE ---
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      
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
  
  final String text;
  final int value;

  // --- CONSTRUCTOR FACTORY PARA OPCIONES ---
  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      text: json['text'] as String? ?? '',
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