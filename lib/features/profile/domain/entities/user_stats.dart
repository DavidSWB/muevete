class UserStats {
  final double knee;
  final double hip;
  final double ankle;
  final double shoulder;

  const UserStats({
    required this.knee,
    required this.hip,
    required this.ankle,
    required this.shoulder,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      knee: (json["knee"] as num).toDouble(),
      hip: (json["hip"] as num).toDouble(),
      ankle: (json["ankle"] as num).toDouble(),
      shoulder: (json["shoulder"] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "knee": knee,
        "hip": hip,
        "ankle": ankle,
        "shoulder": shoulder,
      };
      
   double getStat(String target){
    switch(target){
      case 'ankle':
        return ankle;

      case 'knee':
        return knee;

      case 'hip':
        return hip;

      case 'shoulder':
        return shoulder;

      default:
        throw Exception("Invalid Target");     
    }
  }
  double get overallLevel =>
    (knee + hip + ankle + shoulder) / 4;
}