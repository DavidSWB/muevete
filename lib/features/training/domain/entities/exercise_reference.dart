class ExerciseReference{

  final String exerciseId;

  const ExerciseReference({
    required this.exerciseId,
  });

  factory ExerciseReference.fromJson(
      Map<String,dynamic> json,
  ){

    return ExerciseReference(
      exerciseId: json["exerciseId"],
    );

  }

  Map<String,dynamic> toJson(){

    return {

      "exerciseId": exerciseId,

    };

  }

}