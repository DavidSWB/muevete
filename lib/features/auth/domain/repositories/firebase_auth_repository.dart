import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';


class FirebaseAuthRepository implements AuthRepository {

  FirebaseAuthRepository({
    required FirebaseAuth auth,
  }) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<User?> signIn(
    String email,
    String password,
  ) async {

    final credential =
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

    return credential.user;
  }

  @override
  Future<User?> signUp(
    String email,
    String password,
  ) async {

    final credential =
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

    return credential.user;
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Stream<User?> get authStateChanges =>
    _auth.authStateChanges();

}