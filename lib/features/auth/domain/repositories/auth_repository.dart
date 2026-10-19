import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {

  Future<User?> signIn(
    String email,
    String password,
  );

  Future<User?> signUp(
    String email,
    String password,
  );

  Future<void> signOut();

  User? get currentUser;

  Stream<User?> get authStateChanges;

  /// Signs in with Google. Returns [null] if the user cancelled.
  /// Throws [FirebaseAuthException] on auth failures.
  Future<User?> signInWithGoogle();

  /// Signs in with Apple. Returns [null] if the user cancelled.
  /// Throws [FirebaseAuthException] on auth failures.
  Future<User?> signInWithApple();
}