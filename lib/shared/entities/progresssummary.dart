class ProgressSummary {

  final int totalSessions;

  const ProgressSummary({
    required this.totalSessions,
  });

  factory ProgressSummary.fromJson(Map<String,dynamic> json){

    return ProgressSummary(
      totalSessions: json["totalSessions"] ?? 0,
    );

  }

  Map<String,dynamic> toJson(){

    return {
      "totalSessions": totalSessions,
    };

  }

}