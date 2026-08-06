import 'package:muevete/features/profile/domain/entities/userstats.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
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

  final List<DateTime> completedWorkouts;

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
    this.completedWorkouts = const [],
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
            : DateTime.parse(json["createdAt"]),

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

        completedWorkouts:
        (json["completedWorkouts"] as List<dynamic>? ?? [])
          .map((e) {
            if (e is Timestamp) {
              return e.toDate();
            }

            if (e is String) {
              return DateTime.parse(e);
            }

            throw Exception("Formato de fecha no soportado: ${e.runtimeType}");
          })
          .toList(),
      );
    }catch (e, s) {
    print(e);
    print(s);
    rethrow;
  }
  }

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
      "completedWorkouts":
          completedWorkouts.map((e) => e.toIso8601String()).toList(),
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
    List<DateTime>? completedWorkouts,
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
      completedWorkouts:
          completedWorkouts ?? this.completedWorkouts,
    );
  }
}