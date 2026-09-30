import 'package:muevete/features/training/domain/entities/training_plan.dart';

abstract class TrainingRepository {

  Future <TrainingPlan> getPlan(String id);

  Future<List<TrainingPlan>> getPlans();

}
