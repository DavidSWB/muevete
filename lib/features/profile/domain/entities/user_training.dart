import 'package:muevete/features/profile/domain/entities/user_schedule.dart';

class UserTraining {

  final String activePlanId;

  final DateTime planStartDate;

  final UserSchedule? schedule;

  const UserTraining({

    required this.activePlanId,

    required this.planStartDate,

    this.schedule,

  });

  factory UserTraining.fromJson(
    Map<String,dynamic> json){

    final startDate = json["planStartDate"];

    return UserTraining(

      activePlanId:
          json["activePlanId"],

      planStartDate: startDate == null 
        ? DateTime.now()
        : DateTime.parse(startDate),

      schedule: json["schedule"] == null
          ? null
          : UserSchedule.fromJson(json["schedule"]),

    );

  }

  Map<String,dynamic> toJson(){

    return{

      "activePlanId":activePlanId,

      "planStartDate":
          planStartDate.toIso8601String(),

      if (schedule != null) "schedule": schedule!.toJson(),

    };

  }

  UserTraining copyWith({

    String? activePlanId,

    DateTime? planStartDate,

    UserSchedule? schedule,

  }){

    return UserTraining(

      activePlanId:
          activePlanId ??
          this.activePlanId,

      planStartDate:
          planStartDate ??
          this.planStartDate,

      schedule: schedule ?? this.schedule,

    );

  }

}