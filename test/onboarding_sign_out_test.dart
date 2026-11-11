import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/features/training/domain/repositories/training_repository.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';

/// The onboarding gate listens to users/{uid}. On sign-out Firestore can
/// still send that listener a permission error after the gate stopped
/// listening; it must not surface as an unhandled exception.
void main() {
  late StreamController<User?> auth;
  late StreamController<DocumentSnapshot<Map<String, dynamic>>> userDoc;
  late ProviderContainer container;

  setUp(() {
    auth = StreamController<User?>.broadcast();
    userDoc = StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
    container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => auth.stream),
        firebaseFirestoreProvider.overrideWithValue(_FakeFirestore(userDoc.stream)),
        trainingRepositoryProvider.overrideWithValue(_NoPlans()),
      ],
    );
    // Stands in for AuthGate, which watches the gate while signed in.
    container.listen(onboardingStatusProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    auth.close();
    userDoc.close();
  });

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  OnboardingStatus? status() => container.read(onboardingStatusProvider).value;

  Future<void> signInWithConsent() async {
    auth.add(_FakeUser());
    await settle();
    userDoc.add(
      _FakeSnapshot({privacyPolicyVersionField: currentPrivacyPolicyVersion}),
    );
    await settle();
    expect(status(), OnboardingStatus.noDiagnosis);
  }

  final permissionDenied = FirebaseException(
    plugin: 'cloud_firestore',
    code: 'permission-denied',
  );

  test('a permission error after signing out is ignored', () async {
    await signInWithConsent();

    auth.add(null);
    await settle();
    expect(status(), OnboardingStatus.unauthenticated);

    // An unhandled error here would fail the test.
    userDoc.addError(permissionDenied);
    await settle();
    expect(status(), OnboardingStatus.unauthenticated);
  });

  test('a permission error while signed in still reaches the gate', () async {
    await signInWithConsent();

    userDoc.addError(permissionDenied);
    await settle();

    final gate = container.read(onboardingStatusProvider);
    expect(gate.hasError, isTrue);
    expect(gate.error, permissionDenied);
  });
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';
}

class _FakeFirestore extends Fake implements FirebaseFirestore {
  _FakeFirestore(this.userDoc);

  final Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'users');
    return _FakeCollection(userDoc);
  }
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _FakeCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _FakeCollection(this.userDoc);

  final Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    expect(path, 'uid-1');
    return _FakeDocument(userDoc);
  }
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _FakeDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _FakeDocument(this.userDoc);

  final Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc;

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => userDoc;
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _FakeSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeSnapshot(this._data);

  final Map<String, dynamic> _data;

  @override
  bool get exists => true;

  @override
  Map<String, dynamic>? data() => _data;
}

class _NoPlans extends Fake implements TrainingRepository {}
