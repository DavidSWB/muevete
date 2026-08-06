import 'package:muevete/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';

class DiagnosisCalculator{
  

  Diagnosis calculate(
    List<Question> questions,
    Map<String, int> answers,
  ){

    final Map<String, double> basicData  = {
      "shoulder": 0.0, 
      "hip": 0.0,
      "knee": 0.0,
      "ankle": 0.0,

    };
    final Map<String, double> totals  = Map.from(basicData);

    final Map<String, double> counts = Map.from(basicData);

    final Map<String, double> average = Map.from(basicData);

    for (var question in questions){

      final value = answers[question.id] ?? 0;
      
      for(var category in question.categories){

        if(totals.containsKey(category)){
          totals[category] = totals[category]! + value;
          counts[category] = counts[category]! + 1;
        }

      }

    }
    
    for (var category in totals.keys){

      average[category] =
        totals[category]! / counts[category]!;

    }

    return Diagnosis(

      ankle: average["ankle"]!,

      knee: average["knee"]!,

      hip: average["hip"]!,

      shoulder: average["shoulder"]!,

    );
  }

  
}