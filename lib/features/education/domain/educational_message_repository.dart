import 'package:muevete/features/education/domain/educational_message.dart';

abstract interface class EducationalMessageRepository {
  /// The messages marked active, in no particular order.
  Future<List<EducationalMessage>> getActiveMessages();
}
