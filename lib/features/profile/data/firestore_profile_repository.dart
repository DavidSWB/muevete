import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
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
  Future<void> createProfile(
    UserModel user, {
    String? privacyPolicyVersion,
  }) async {
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
            // The same starting point existing users were given.
            'movementXp': 0,
            'jointProgress': {for (final joint in progressionJoints) joint: 0},
            'unlockedBadgeIds': <String>[],
            if (privacyPolicyVersion != null) ...{
              privacyPolicyVersionField: privacyPolicyVersion,
              privacyAcceptedAtField: FieldValue.serverTimestamp(),
            },
          },
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
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
    final entry = completedAt.toIso8601String();
    final ref = _firestore.collection('users').doc(currentUser.uid);

    // A transaction, so the history it checks is the one it writes to: a
    // retry of a completion that was already saved changes nothing.
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final rawHistory = snapshot.data()?[field];
      final history = rawHistory is List ? rawHistory : const [];
      if (history.contains(entry)) return;

      final earned = reward?.call(_readDates(history)) ?? ActivityReward.none;
      transaction.update(ref, {
        field: FieldValue.arrayUnion([entry]),
        'streak': streak.toJson(),
        if (earned.xp > 0) 'movementXp': FieldValue.increment(earned.xp),
        for (final joint in earned.jointPoints.entries)
          'jointProgress.${joint.key}': FieldValue.increment(joint.value),
      });
    });
  }

  @override
  Future<void> unlockBadges(Set<String> badgeIds) async {
    if (badgeIds.isEmpty) return;
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated.');
    }
    await _firestore.collection('users').doc(currentUser.uid).update({
      'unlockedBadgeIds': FieldValue.arrayUnion(badgeIds.toList()),
    });
  }

  static List<DateTime> _readDates(List<dynamic> history) {
    final dates = <DateTime>[];
    for (final value in history) {
      try {
        dates.add(UserModel.parseDateTime(value));
      } on FormatException {
        // An unreadable entry cannot count toward a daily limit.
      }
    }
    return dates;
  }
}
