import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository{

  FirestoreProfileRepository({
    required FirebaseFirestore firestore,  
    required FirebaseAuth auth,

  }): _auth = auth,
  _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserModel> getProfile() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User not authenticated.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!snapshot.exists) {
      throw Exception('Profile not found.');
    }

    return UserModel.fromJson(
      id: currentUser.uid,
      json: snapshot.data()!,
    );
  }

  @override
  Future<void> saveProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User not authenticated.');
    }

    // update() fails if the profile does not exist instead of creating a
    // partial one.
    await _firestore.collection('users').doc(currentUser.uid).update({
      'username': info.username,
      'age': info.age,
      'height': info.height,
      'weight': info.weight,
      'sex': info.sex.storedValue,
      'medicalConditions': info.medicalConditions,
    });
  }

  @override
  Future<void> createProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(
          {
            ...user.toJson(),
            'completedWorkouts': <String>[],
            'completedActiveBreaks': <String>[],
            'streak': UserStreak.empty.toJson(),
            'consistencyTrackedSince': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User not authenticated.');
    }

    final field = switch (kind) {
      ActivityKind.workout => 'completedWorkouts',
      ActivityKind.activeBreak => 'completedActiveBreaks',
    };

    // Local wall-clock time without offset, the format already stored.
    await _firestore.collection('users').doc(currentUser.uid).update({
      field: FieldValue.arrayUnion([completedAt.toIso8601String()]),
      'streak': streak.toJson(),
    });
  }
}
