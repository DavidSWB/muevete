class UserNotifications {
  final bool enabled;
  final bool trainingReminderEnabled;
  final bool activeBreakReminderEnabled;
  final String activeBreakStartTime;
  final String activeBreakEndTime;
  final int activeBreakIntervalMinutes;

  static const List<int> supportedIntervals = [60, 120, 180];
  static const String defaultStartTime = '08:00';
  static const String defaultEndTime = '18:00';
  static const int defaultIntervalMinutes = 120;

  const UserNotifications({
    this.enabled = true,
    this.trainingReminderEnabled = true,
    this.activeBreakReminderEnabled = false,
    String? activeBreakStartTime,
    String? activeBreakEndTime,
    int? activeBreakIntervalMinutes,
  })  : activeBreakStartTime = activeBreakStartTime ?? defaultStartTime,
        activeBreakEndTime = activeBreakEndTime ?? defaultEndTime,
        activeBreakIntervalMinutes =
            activeBreakIntervalMinutes ?? defaultIntervalMinutes;

  factory UserNotifications.fromJson(Map<String, dynamic> json) {
    final trainingReminder = json['trainingReminder'] as Map<String, dynamic>?;
    final activeBreak = json['activeBreakReminder'] as Map<String, dynamic>?;

    return UserNotifications(
      enabled: json['enabled'] as bool? ?? true,
      trainingReminderEnabled: trainingReminder?['enabled'] as bool? ?? true,
      activeBreakReminderEnabled: activeBreak?['enabled'] as bool? ?? false,
      activeBreakStartTime:
          activeBreak?['startTime'] as String? ?? defaultStartTime,
      activeBreakEndTime:
          activeBreak?['endTime'] as String? ?? defaultEndTime,
      activeBreakIntervalMinutes:
          (activeBreak?['intervalMinutes'] as num?)?.toInt() ??
              defaultIntervalMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'trainingReminder': {
        'enabled': trainingReminderEnabled,
      },
      'activeBreakReminder': {
        'enabled': activeBreakReminderEnabled,
        'startTime': activeBreakStartTime,
        'endTime': activeBreakEndTime,
        'intervalMinutes': activeBreakIntervalMinutes,
      },
    };
  }

  UserNotifications copyWith({
    bool? enabled,
    bool? trainingReminderEnabled,
    bool? activeBreakReminderEnabled,
    String? activeBreakStartTime,
    String? activeBreakEndTime,
    int? activeBreakIntervalMinutes,
  }) {
    return UserNotifications(
      enabled: enabled ?? this.enabled,
      trainingReminderEnabled:
          trainingReminderEnabled ?? this.trainingReminderEnabled,
      activeBreakReminderEnabled:
          activeBreakReminderEnabled ?? this.activeBreakReminderEnabled,
      activeBreakStartTime: activeBreakStartTime ?? this.activeBreakStartTime,
      activeBreakEndTime: activeBreakEndTime ?? this.activeBreakEndTime,
      activeBreakIntervalMinutes:
          activeBreakIntervalMinutes ?? this.activeBreakIntervalMinutes,
    );
  }

  static bool isValidTimeFormat(String? timeStr) {
    if (timeStr == null) return false;
    final parts = timeStr.trim().split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  static int? timeToMinutes(String? timeStr) {
    if (!isValidTimeFormat(timeStr)) return null;
    final parts = timeStr!.trim().split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  bool get isValidActiveBreakRange {
    final startMin = timeToMinutes(activeBreakStartTime);
    final endMin = timeToMinutes(activeBreakEndTime);
    if (startMin == null || endMin == null) return false;
    return endMin > startMin;
  }

  bool get isValidInterval {
    return supportedIntervals.contains(activeBreakIntervalMinutes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserNotifications &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          trainingReminderEnabled == other.trainingReminderEnabled &&
          activeBreakReminderEnabled == other.activeBreakReminderEnabled &&
          activeBreakStartTime == other.activeBreakStartTime &&
          activeBreakEndTime == other.activeBreakEndTime &&
          activeBreakIntervalMinutes == other.activeBreakIntervalMinutes;

  @override
  int get hashCode => Object.hash(
        enabled,
        trainingReminderEnabled,
        activeBreakReminderEnabled,
        activeBreakStartTime,
        activeBreakEndTime,
        activeBreakIntervalMinutes,
      );
}
