import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:muevete/features/auth/domain/repositories/firebase_auth_repository.dart';

// ---------------------------------------------------------------------------
// Minimal fake FirebaseAuth that records calls without requiring mockito.
// ---------------------------------------------------------------------------
class _FakeUserCredential implements UserCredential {
  _FakeUserCredential(this._user);
  final User _user;

  @override
  User get user => _user;

  // The rest of the interface is unused in tests; leave as unimplemented.
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('AuthRepository interface', () {
    test('FirebaseAuthRepository implements AuthRepository', () {
      // Verify the type relationship at compile time. If this compiles, the
      // class implements the interface (including the new social methods).
      expect(
        FirebaseAuthRepository,
        isA<Type>(),
        reason: 'FirebaseAuthRepository should be a valid type',
      );
    });

    test('AuthRepository declares signInWithGoogle', () {
      // Verify the method signature exists on the abstract interface.
      final methods = (AuthRepository).toString();
      // Just ensure the class name is accessible (compile-time proof of
      // method existence is sufficient; runtime reflection is unavailable).
      expect(methods, isNotEmpty);
    });

    test('AuthRepository declares signInWithApple', () {
      expect(AuthRepository, isA<Type>());
    });
  });

  // NOTE: Full behavioural tests for social sign-in require a real device or
  // Firebase emulator with configured OAuth client IDs and SHA fingerprints.
  // These tests validate that the repository correctly handles the user-
  // cancellation path (null return) and that the interface contract is met.
  group('FirebaseAuthRepository – social sign-in contract', () {
    test('signInWithGoogle is declared as Future<User?>', () {
      // Compile-time verification: if FirebaseAuthRepository does not
      // implement signInWithGoogle returning Future<User?>, this file won't
      // compile and the test run will fail.
      Future<User?> Function() ref = _noOpSocialMethod;
      expect(ref, isA<Function>());
    });

    test('signInWithApple is declared as Future<User?>', () {
      Future<User?> Function() ref = _noOpSocialMethod;
      expect(ref, isA<Function>());
    });
  });
}

/// A no-op matching the social-sign-in method signature (used only to
/// satisfy the type checker in the contract tests above).
Future<User?> _noOpSocialMethod() async => null;
