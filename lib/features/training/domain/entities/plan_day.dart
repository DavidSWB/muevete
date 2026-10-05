import 'package:muevete/features/training/domain/entities/exercise_reference.dart';

class PlanDay{

  final int day;

  final Map<String,String> name;

  final List<String> recoveryGroups;

  final List<ExerciseReference> exercises;

  const PlanDay({

    required this.day,

    required this.name,

    this.recoveryGroups = const [],

    required this.exercises,

  });

  factory PlanDay.fromJson(
      Map<String,dynamic> json,
  ){

    return PlanDay(

      day: json["day"],

      name:
          Map<String,String>.from(
            json["name"],
          ),

      recoveryGroups:
          (json["recoveryGroups"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],

      exercises:

          (json["exercises"] as List)

              .map(
                (e)=> ExerciseReference.fromJson(e),
              )

              .toList(),

    );

  }

  Map<String,dynamic> toJson(){

    return {

      "day": day,

      "name": name,

      "recoveryGroups": recoveryGroups,

      "exercises":
          exercises
              .map((e)=>e.toJson())
              .toList(),

    };

  }

}