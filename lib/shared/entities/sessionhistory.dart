class SessionHistory{
  final DateTime date;
  final bool completed;
  final double duration;

  SessionHistory({
    required this.date,
    required this.completed,
    required this.duration,
  });

factory SessionHistory.fromJson(Map<String,dynamic> json,){

  return SessionHistory(
    date:DateTime.parse(json["date"],),
    completed:json["completed"],
    duration:json["duration"].toDouble(),
  );
}

  Map<String,dynamic> toJson(){
    return{
      "date":date.toIso8601String(),
      "completed":completed,
      "duration":duration,
    };
  }
}