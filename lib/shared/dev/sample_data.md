import 'package:muevete/shared/entities/user_model.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';

final exampleUser = UserModel.fromJson({
  "id":"test123",
  "email":"test@gmail.com",
  "username":"GG",
  "age":22,
  "weight":67.0,
  "height":177.0,
  "createdAt":DateTime.now(),
});



final exampleTraining =

TrainingPlan(

  planId:"plan_2d_fullbody",
  daysPerWeek:2,
  template:[

    PlanDay(
      day:1,
      name:{'en': "Full Body A",},
      exercises:
      [],
    ),

    PlanDay(
      day:2,
      name:{'en': "Full Body B",},
      exercises:
      [],
    ),
  ],
);