import 'package:muevete/features/training/domain/entities/joint_type.dart';

class Diagnosis{
  final double ankle;
  final double knee;
  final double hip;
  final double shoulder;

  Diagnosis({
    required this.ankle,
    required this.knee,
    required this.hip,
    required this.shoulder,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json){
    return Diagnosis(
      ankle: json["ankle"].toDouble(), 
      knee: json["knee"].toDouble(), 
      hip: json["hip"].toDouble(), 
      shoulder: json["shoulder"].toDouble(),
    );
  }
  Map<String, dynamic> toJson(){
    return{
    "ankle": ankle,
    "knee": knee,
    "hip": hip,
    "shoulder": shoulder,
    };
  }

  double getStat(JointType joint) {

    switch (joint) {

      case JointType.knee:
        return knee;

      case JointType.hip:
        return hip;

      case JointType.ankle:
        return ankle;

      case JointType.shoulder:
        return shoulder;

    }
  }
}
