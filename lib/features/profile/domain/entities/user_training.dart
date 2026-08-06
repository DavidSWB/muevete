class UserTraining {

  final String activePlanId;

  final DateTime planStartDate;

  const UserTraining({

    required this.activePlanId,

    required this.planStartDate,

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

    );

  }

  Map<String,dynamic> toJson(){

    return{

      "activePlanId":activePlanId,

      "planStartDate":
          planStartDate.toIso8601String(),

    };

  }

  UserTraining copyWith({

    String? activePlanId,

    DateTime? planStartDate,

  }){

    return UserTraining(

      activePlanId:
          activePlanId ??
          this.activePlanId,

      planStartDate:
          planStartDate ??
          this.planStartDate,

    );

  }

}