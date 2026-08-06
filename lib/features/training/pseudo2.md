
  Workout buildWorkout(
    UserModel user,
    int day,
  ){

    final exerciseProvider = ref.read(exerciseProvider.notifier);
    final progressionProvider = ref.read(progressionProvider.notifier);
    final week = user.training.currentWeek;

    final userPlan = user.training?.activePlanId;
    final template = exerciseProvider.getPlan().template;

    List<WorkoutExercise> exercises = [];

    for (var exercise in template.exercises){

      final intensity = progressionProvider.firstWhere(
        (object) => obeject.week = week
      );

      final userStat = getLowestTargetStat(exercise, user.stats);
      final userLevel = calculateLevel(stat);

      final variant = findVariant(
        exercise,
        userLevel,
      );


      exercises : [...,{
        exercise: variant,
        sets: intensity.sets,
        reps: intensity.reps,
        duration: intensity.duration,
        }
      ]
    }
    

  }