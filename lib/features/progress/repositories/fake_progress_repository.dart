import 'package:muevete/features/progress/repositories/progress_repository.dart';
import 'package:muevete/shared/entities/sessionhistory.dart';

class FakeProgressRepository implements ProgressRepository{

  Future <SessionHistory> getProgress() async{
    return SessionHistory(
      date: DateTime.now(), 
      completed: true, 
      duration: 30,
      );
  }
} 
