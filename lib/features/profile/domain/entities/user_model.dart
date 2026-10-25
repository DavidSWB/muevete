import 'dart:developer' as developer;

import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/shared/entities/progresssummary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;

  final String? sex;
  final int? age;
  final double? height;
  final double? weight;
  final DateTime? createdAt;

  final List<String>? medicalConditions;

  final UserStats? stats;
  final UserTraining? training;
  final ProgressSummary? progressSummary;
  final UserNotifications? notifications;

  /// Completed training-plan workouts. Entries older than
  /// [consistencyTrackedSince] may also include active breaks.
  final List<DateTime> completedWorkouts;

  /// Completed active-break routines and personal-timer breaks.
  final List<DateTime> completedActiveBreaks;

  final UserStreak? streak;

  /// From this moment workouts and active breaks are recorded separately.
  final DateTime? consistencyTrackedSince;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.sex,
    this.age,
    this.height,
    this.weight,
    this.createdAt,
    this.medicalConditions,
    this.stats,
    this.training,
    this.progressSummary,
    this.notifications,
    this.completedWorkouts = const [],
    this.completedActiveBreaks = const [],
    this.streak,
    this.consistencyTrackedSince,
  });

  factory UserModel.fromJson({
    required String id,
    required Map<String, dynamic> json,
  }) {
    try{
      
      return UserModel(
        id: id,
        email: json["email"] ?? "",
        username: json["username"] ?? "",

        sex: json["sex"],

        age: (json["age"] as num?)?.toInt(),

        height: (json["height"] as num?)?.toDouble(),

        weight: (json["weight"] as num?)?.toDouble(),

        createdAt: json["createdAt"] == null
            ? null
            : parseDateTime(json["createdAt"]),

        medicalConditions:
            (json["medicalConditions"] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),

        stats: json["stats"] == null
            ? null
            : UserStats.fromJson(json["stats"]),

        training: json["training"] == null
            ? null
            : UserTraining.fromJson(json["training"]),

        progressSummary: json["progressSummary"] == null
            ? null
            : ProgressSummary.fromJson(json["progressSummary"]),

        notifications: json["notifications"] == null
            ? null
            : UserNotifications.fromJson(json["notifications"]),

        completedWorkouts: _parseDateList(json["completedWorkouts"]),

        completedActiveBreaks: _parseDateList(json["completedActiveBreaks"]),

        streak: json["streak"] is Map
            ? UserStreak.fromJson(Map<String, dynamic>.from(json["streak"]))
            : null,

        consistencyTrackedSince: json["consistencyTrackedSince"] == null
            ? null
            : parseDateTime(json["consistencyTrackedSince"]),
      );
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  /// Skips entries that cannot be read, so one bad value does not stop the
  /// whole profile from loading.
  static List<DateTime> _parseDateList(dynamic value) {
    if (value is! List) return const [];
    final dates = <DateTime>[];
    for (final entry in value) {
      try {
        dates.add(parseDateTime(entry));
      } on FormatException catch (e) {
        developer.log(
          'Skipping unreadable activity date: $e',
          name: 'muevete.profile',
        );
      }
    }
    return dates;
  }

  static DateTime parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
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
    throw FormatException("Formato de fecha no soportado: $value");
  }

  /// Profile fields only. Activity history, the streak and
  /// [consistencyTrackedSince] are written by
  /// `ProfileRepository.recordCompletion` and `createProfile`, so saving a
  /// profile can never overwrite completions recorded meanwhile.
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "username": username,
      "sex": sex,
      "age": age,
      "height": height,
      "weight": weight,
      "createdAt": createdAt?.toIso8601String(),
      "medicalConditions": medicalConditions,
      "stats": stats?.toJson(),
      "training": training?.toJson(),
      "progressSummary": progressSummary?.toJson(),
      "notifications": notifications?.toJson(),
    };
  }

  UserModel copyWith({
    String? email,
    String? username,
    String? sex,
    int? age,
    double? height,
    double? weight,
    DateTime? createdAt,
    List<String>? medicalConditions,
    UserStats? stats,
    UserTraining? training,
    ProgressSummary? progressSummary,
    UserNotifications? notifications,
    List<DateTime>? completedWorkouts,
    List<DateTime>? completedActiveBreaks,
    UserStreak? streak,
    DateTime? consistencyTrackedSince,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      medicalConditions:
          medicalConditions ?? this.medicalConditions,
      stats: stats ?? this.stats,
      training: training ?? this.training,
      progressSummary:
          progressSummary ?? this.progressSummary,
      notifications: notifications ?? this.notifications,
      completedWorkouts:
          completedWorkouts ?? this.completedWorkouts,
      completedActiveBreaks:
          completedActiveBreaks ?? this.completedActiveBreaks,
      streak: streak ?? this.streak,
      consistencyTrackedSince:
          consistencyTrackedSince ?? this.consistencyTrackedSince,
    );
  }
}