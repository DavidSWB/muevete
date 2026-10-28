import 'package:muevete/features/education/domain/educational_message.dart';
import 'package:muevete/features/education/domain/tip_preferences.dart';

/// The tip Home should show now, or null for none.
///
/// Tips rotate in [EducationalMessage.order]: each one comes after the last
/// one the user dismissed, so every tip is seen before any repeats. With
/// [TipFrequency.daily], a tip dismissed today hides tips until tomorrow.
EducationalMessage? selectTip({
  required List<EducationalMessage> messages,
  required TipPreferences preferences,
  required DateTime now,
}) {
  if (preferences.frequency == TipFrequency.off || messages.isEmpty) {
    return null;
  }

  final today = DateTime(now.year, now.month, now.day);
  if (preferences.frequency == TipFrequency.daily &&
      preferences.lastDismissedOn == today) {
    return null;
  }

  final sorted = [...messages]
    ..sort((a, b) {
      final byOrder = a.order.compareTo(b.order);
      return byOrder != 0 ? byOrder : a.messageId.compareTo(b.messageId);
    });
  final last = sorted.indexWhere(
    (message) => message.messageId == preferences.lastDismissedId,
  );
  return sorted[(last + 1) % sorted.length];
}
