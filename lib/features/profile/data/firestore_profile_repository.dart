import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
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
}