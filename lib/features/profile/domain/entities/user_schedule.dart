import 'package:flutter/foundation.dart';

class UserSchedule {
  final Map<int, int> days;
  final String? preferredTime;

  static const Map<String, int> _weekdayNameToNumber = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7,
  };

  const UserSchedule({
    required this.days,
    this.preferredTime,
  });

  factory UserSchedule.fromJson(Map<String, dynamic> json) {
    final days = <int, int>{};
    for (final entry in json.entries) {
      if (entry.key == 'preferredTime') continue;

      final key = entry.key.trim().toLowerCase();
      int? weekday;
      if (_weekdayNameToNumber.containsKey(key)) {
        weekday = _weekdayNameToNumber[key];
      } else {
        final parsed = int.tryParse(key);
        if (parsed != null && parsed >= 1 && parsed <= 7) {
          weekday = parsed;
        }
      }

      final val = entry.value;
      if (weekday != null && val != null) {
        if (val is num) {
          days[weekday] = val.toInt();
        } else if (val is String) {
          final parsedVal = int.tryParse(val);
          if (parsedVal != null) days[weekday] = parsedVal;
        }
      }
    }

    return UserSchedule(
      days: days,
      preferredTime: json['preferredTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'monday': days[1],
      'tuesday': days[2],
      'wednesday': days[3],
      'thursday': days[4],
      'friday': days[5],
      'saturday': days[6],
      'sunday': days[7],
    };
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSchedule &&
          runtimeType == other.runtimeType &&
          mapEquals(days, other.days) &&
          preferredTime == other.preferredTime;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(days.entries.map((e) => Object.hash(e.key, e.value))),
        preferredTime,
      );
}
