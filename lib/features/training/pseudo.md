ExerciseVariant getAppropiateExerciseVariant(Exercise exercise, Diagnosis userStats){

    ExerciseVariant exerciseVariant = exercise.variants.firstWhere(
        (v) => v.requiredLevel == 'begginer';
    );

    int minStat = 5;


    for each (target in exercise.targets){
        String level;

        final currentStat = userStats.firstWhere(
            (s)=> s == target
        );
        
        if(currentStat < minStat) minStat = currentStat;
    }
    
    if(minStat >4){
        level = 'advanced';
    }else if (minStat <=4 && minStat > 2 ){
        level = 'intermediate';
    }else{
        level = 'basic';
    }
    
    ExerciseVariant appropiateExerciseVariant(){

        exerciseVariant = exercise.variants.firstWhere(
            (v) => v.requiredLevel == level;
        );
    }

    return exerciseVariant;
}