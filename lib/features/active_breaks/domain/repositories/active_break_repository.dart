import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';

abstract class ActiveBreakRepository {
  Future<List<ActiveBreak>> getActiveBreaks();
}
