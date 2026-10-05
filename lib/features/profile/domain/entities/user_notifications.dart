class UserNotifications {
  final bool enabled;
  final bool trainingReminderEnabled;
  final bool activeBreakReminderEnabled;
  final String? activeBreakStartTime;
  final String? activeBreakEndTime;
  final int? activeBreakIntervalMinutes;

  const UserNotifications({
    this.enabled = true,
    this.trainingReminderEnabled = true,
    this.activeBreakReminderEnabled = false,
    this.activeBreakStartTime,
    this.activeBreakEndTime,
    this.activeBreakIntervalMinutes,
  });

  factory UserNotifications.fromJson(Map<String, dynamic> json) {
    final trainingReminder = json['trainingReminder'] as Map<String, dynamic>?;
    final activeBreak = json['activeBreakReminder'] as Map<String, dynamic>?;

    return UserNotifications(
      enabled: json['enabled'] ?? true,
      trainingReminderEnabled: trainingReminder?['enabled'] ?? true,
      activeBreakReminderEnabled: activeBreak?['enabled'] ?? false,
      activeBreakStartTime: activeBreak?['startTime'] as String?,
      activeBreakEndTime: activeBreak?['endTime'] as String?,
      activeBreakIntervalMinutes: activeBreak?['intervalMinutes'] as int?,
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
        if (activeBreakStartTime != null) 'startTime': activeBreakStartTime,
        if (activeBreakEndTime != null) 'endTime': activeBreakEndTime,
        if (activeBreakIntervalMinutes != null)
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
}
