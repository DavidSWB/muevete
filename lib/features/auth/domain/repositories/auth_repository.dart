import 'package:firebase_auth/firebase_auth.dart';

/// How the signed-in user proves their identity again before a sensitive
/// action, such as deleting the account.
enum ReauthMethod { password, google, apple }

/// Outcome of [AuthRepository.reauthenticate].
class ReauthResult {
  const ReauthResult.done({this.appleAuthorizationCode}) : cancelled = false;
  const ReauthResult.cancelled()
    : cancelled = true,
      appleAuthorizationCode = null;

  /// True when the user closed the provider's prompt.
  final bool cancelled;

  /// Apple's single-use code, needed to revoke the Apple token when the
  /// account is deleted. Null for other providers.
  final String? appleAuthorizationCode;
}

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

  /// The method used to reauthenticate the signed-in user, or null when
  /// nobody is signed in or no supported provider is linked.
  ReauthMethod? get reauthMethod;

  /// Proves the signed-in user's identity again with [reauthMethod].
  /// [password] is required for [ReauthMethod.password] and is never stored.
  /// Throws [FirebaseAuthException] when the provider rejects it.
  Future<ReauthResult> reauthenticate({String? password});

  /// Revokes the Apple tokens issued to this app, as Apple requires when an
  /// account is deleted.
  Future<void> revokeAppleToken(String authorizationCode);

  /// Deletes the signed-in user's Firebase Authentication account and signs
  /// them out of the provider. Throws [FirebaseAuthException] on failure.
  Future<void> deleteCurrentUser();
}
