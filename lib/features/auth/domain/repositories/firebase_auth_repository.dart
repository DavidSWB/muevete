import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


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

  // ─── Social sign-in ────────────────────────────────────────────────────────

  @override
  Future<User?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    // User cancelled the picker.
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  @override
  Future<User?> signInWithApple() async {
    // Generate a nonce to prevent replay attacks.
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);

    // Apple only supplies display name on first sign-in.
    final user = userCredential.user;
    final givenName = appleCredential.givenName;
    final familyName = appleCredential.familyName;
    if (user != null && givenName != null) {
      final displayName = [givenName, familyName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      if (displayName.isNotEmpty && (user.displayName?.isEmpty ?? true)) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
    }

    return _auth.currentUser;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Generates a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the SHA-256 hash of [input] as a hex string.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}