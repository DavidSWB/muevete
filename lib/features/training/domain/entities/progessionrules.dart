class ProgessionRules {
  final String id;
  final List<ProgressionStep> cycle;
  final String level;
  final bool reset;
  final String type;


  const ProgessionRules({
    required this.id,
    required this.cycle,
    required this.level,
    required this.reset,
    required this.type,

  });

  factory ProgessionRules.fromJson(Map<String, dynamic> json){
    return ProgessionRules(
      id: json['id'], 

      cycle: (json['cycle'] as List)
        .map((c)=> ProgressionStep.fromJson(c))
        .toList(), 

      level: json['level'], 
      reset: json['reset'], 
      type: json['type'],
    );
  }
  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'cycle': cycle,
      'level': level,
      'reset': reset,
      'type': type,

    };
  }
}

class ProgressionStep{
    final int week;
    final int sets;
    final int? reps;
    final int? duration;
    final int? rest;



  const ProgressionStep({
    required this.week,
    required this.sets,
    this.reps,
    this.duration,
    this.rest,
  });

  factory ProgressionStep.fromJson(Map<String, dynamic> json) {
    return ProgressionStep(
      week: json["week"],
      sets: json["sets"],
      reps: json["reps"],
      duration: json["duration"],
      rest: json["rest"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "week": week,
      "sets": sets,
      "reps": reps,
      "duration": duration,
      "rest": rest,
    };
  }
}