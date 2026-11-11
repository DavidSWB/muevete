import 'package:muevete/features/profile/domain/services/joint_stat_range.dart';

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

  /// Values above 5, saved before the 1–5 limit, are read as 5.
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      knee: clampJointStat((json["knee"] as num).toDouble()),
      hip: clampJointStat((json["hip"] as num).toDouble()),
      ankle: clampJointStat((json["ankle"] as num).toDouble()),
      shoulder: clampJointStat((json["shoulder"] as num).toDouble()),
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