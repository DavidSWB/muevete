class UserSchedule {
  final Map<int, int> days;
  final String? preferredTime;

  const UserSchedule({
    required this.days,
    this.preferredTime,
  });

  factory UserSchedule.fromJson(Map<String, dynamic> json) {
    final days = <int, int>{};
    for (final entry in json.entries) {
      if (entry.key == 'preferredTime') continue;
      final intKey = int.tryParse(entry.key);
      if (intKey != null && entry.value is int) {
        days[intKey] = entry.value;
      }
    }
    return UserSchedule(
      days: days,
      preferredTime: json['preferredTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    for (final entry in days.entries) {
      json[entry.key.toString()] = entry.value;
    }
    if (preferredTime != null) {
      json['preferredTime'] = preferredTime;
    }
    return json;
  }

  UserSchedule copyWith({
    Map<int, int>? days,
    String? preferredTime,
  }) {
    return UserSchedule(
      days: days ?? this.days,
      preferredTime: preferredTime ?? this.preferredTime,
    );
  }
}
