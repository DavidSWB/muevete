import 'package:flutter/foundation.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';

class UserTraining {
  final String activePlanId;
  final DateTime planStartDate;
  final int? currentWeek;
  final UserSchedule? schedule;
  final Map<String, dynamic> extraFields;

  const UserTraining({
    required this.activePlanId,
    required this.planStartDate,
    this.currentWeek,
    this.schedule,
    this.extraFields = const {},
  });

  factory UserTraining.fromJson(Map<String, dynamic> json) {
    final startDate = json["planStartDate"];
    final extra = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!const {'activePlanId', 'planStartDate', 'currentWeek', 'schedule'}.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }

    return UserTraining(
      activePlanId: json["activePlanId"] ?? "",
      planStartDate: startDate == null 
        ? DateTime.now()
        : _parseDate(startDate),
      currentWeek: (json["currentWeek"] as num?)?.toInt(),
      schedule: json["schedule"] == null
          ? null
          : UserSchedule.fromJson(Map<String, dynamic>.from(json["schedule"])),
      extraFields: extra,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
      final regex = RegExp(
        r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[T ](\d{1,2}):(\d{1,2})(?::(\d{1,2})(?:\.(\d+))?)?)?',
      );
      final match = regex.firstMatch(value.trim());
      if (match != null) {
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        final hour = match.group(4) != null ? int.parse(match.group(4)!) : 0;
        final minute = match.group(5) != null ? int.parse(match.group(5)!) : 0;
        final second = match.group(6) != null ? int.parse(match.group(6)!) : 0;
        final microsecondStr = match.group(7);
        int microsecond = 0;
        if (microsecondStr != null) {
          final padded = microsecondStr.padRight(6, '0').substring(0, 6);
          microsecond = int.parse(padded);
        }
        return DateTime(year, month, day, hour, minute, second, 0, microsecond);
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      ...extraFields,
      "activePlanId": activePlanId,
      "planStartDate": planStartDate.toIso8601String(),
      if (currentWeek != null) "currentWeek": currentWeek,
      if (schedule != null) "schedule": schedule!.toJson(),
    };
  }

  UserTraining copyWith({
    String? activePlanId,
    DateTime? planStartDate,
    int? currentWeek,
    UserSchedule? schedule,
    Map<String, dynamic>? extraFields,
  }) {
    return UserTraining(
      activePlanId: activePlanId ?? this.activePlanId,
      planStartDate: planStartDate ?? this.planStartDate,
      currentWeek: currentWeek ?? this.currentWeek,
      schedule: schedule ?? this.schedule,
      extraFields: extraFields ?? this.extraFields,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTraining &&
          runtimeType == other.runtimeType &&
          activePlanId == other.activePlanId &&
          planStartDate == other.planStartDate &&
          currentWeek == other.currentWeek &&
          schedule == other.schedule &&
          mapEquals(extraFields, other.extraFields);

  @override
  int get hashCode => Object.hash(
        activePlanId,
        planStartDate,
        currentWeek,
        schedule,
        Object.hashAll(extraFields.entries.map((e) => Object.hash(e.key, e.value))),
      );
}