import 'package:muevete/shared/entities/sessionhistory.dart';

abstract class ProgressRepository {
  Future<SessionHistory> getProgress();
}