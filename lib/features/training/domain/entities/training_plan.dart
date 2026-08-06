import 'package:muevete/features/training/domain/entities/plan_day.dart';

class TrainingPlan{

  final String planId;

  final Map<String,String> name;

  final Map<String,String> description;

  final int daysPerWeek;

  final List<PlanDay> template;

  const TrainingPlan({

    required this.planId,

    required this.name,

    required this.description,

    required this.daysPerWeek,

    required this.template,

  });

  factory TrainingPlan.fromJson(
      Map<String,dynamic> json,
  ){

    return TrainingPlan(

      planId: json["planId"],

      name:
          Map<String,String>.from(
            json["name"],
          ),

      description:
          Map<String,String>.from(
            json["description"],
          ),

      daysPerWeek: json["daysPerWeek"],

      template:

          (json["template"] as List)

              .map(
                (e)=> PlanDay.fromJson(e),
              )

              .toList(),

    );

  }

  Map<String,dynamic> toJson(){

    return {

      "planId": planId,

      "name": name,

      "description": description,

      "daysPerWeek": daysPerWeek,

      "template":

          template

              .map((e)=>e.toJson())

              .toList(),

    };

  }

}