/// Where a tapped reminder takes the user.
enum NotificationTarget { training, activeBreaks }

/// Payloads written on scheduled reminders, read back when one is tapped.
abstract final class NotificationPayloads {
  static const String training = 'training';
  static const String activeBreak = 'active_break';
}

/// The destination for a tapped notification, or null when it has none.
///
/// Reminders scheduled before payloads existed carry none, so their ID range
/// decides: 1001..1007 are training reminders, 2001..2050 active breaks.
NotificationTarget? notificationTargetFor({int? id, String? payload}) {
  switch (payload) {
    case NotificationPayloads.training:
      return NotificationTarget.training;
    case NotificationPayloads.activeBreak:
      return NotificationTarget.activeBreaks;
    case null:
      break;
    default:
      return null;
  }
  if (id == null) return null;
  if (id >= 1001 && id <= 1007) return NotificationTarget.training;
  if (id >= 2001 && id <= 2050) return NotificationTarget.activeBreaks;
  return null;
}
