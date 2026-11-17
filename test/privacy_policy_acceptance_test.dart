import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:muevete/features/privacy/data/firestore_privacy_consent_repository.dart';
import 'package:muevete/features/privacy/domain/consent_record.dart';
import 'package:muevete/features/privacy/domain/policy_notice_store.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/features/privacy/presentation/widgets/privacy_policy_notice.dart';
import 'package:muevete/features/profile/data/firestore_profile_repository.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/repositories/training_repository.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:muevete/l10n/app_localizations.dart';

import 'helpers/privacy_policy_test_data.dart';

const _v1 = ConsentRecord(version: 1);
const _v2 = ConsentRecord(version: 2);
const _v3 = ConsentRecord(version: 3);

void main() {
  group('version comparison', () {
    PrivacyPolicyStatus status(
      PrivacyPolicyMetadata metadata,
      ConsentRecord? policy,
      ConsentRecord? health,
    ) => evaluatePrivacyPolicyStatus(
      metadata: metadata,
      policyAccepted: policy,
      healthDataAuthorization: health,
    );

    test('accepted version equals the current one: continue', () {
      expect(
        status(testPolicyMetadata(current: 2), _v2, _v2),
        PrivacyPolicyStatus.upToDate,
      );
    });

    test('lower version and reacceptance required: blocked', () {
      expect(
        status(testPolicyMetadata(current: 3), _v2, _v2),
        PrivacyPolicyStatus.mustAccept,
      );
    });

    test('lower version and no reacceptance required: notice only', () {
      final minor = testPolicyMetadata(
        current: 3,
        minimum: 2,
        requiresReacceptance: false,
      );
      expect(status(minor, _v2, _v2), PrivacyPolicyStatus.updateNotice);
    });

    test('a skipped mandatory version still blocks after a minor one', () {
      // Version 3 was mandatory, version 4 is minor; the user is on 2.
      final minorAfterMandatory = testPolicyMetadata(
        current: 4,
        minimum: 3,
        requiresReacceptance: false,
      );
      expect(
        status(minorAfterMandatory, _v2, _v2),
        PrivacyPolicyStatus.mustAccept,
      );
      expect(
        status(minorAfterMandatory, _v3, _v3),
        PrivacyPolicyStatus.updateNotice,
      );
    });

    test('a missing or older health authorization blocks', () {
      final metadata = testPolicyMetadata(current: 2);
      expect(status(metadata, _v2, null), PrivacyPolicyStatus.mustAccept);
      expect(status(metadata, null, _v2), PrivacyPolicyStatus.mustAccept);
      expect(status(metadata, _v2, _v1), PrivacyPolicyStatus.mustAccept);
    });

    test('a record newer than the published version counts as accepted', () {
      // e.g. the bundled metadata (version 2) is in use while offline.
      expect(
        status(testPolicyMetadata(current: 2), _v3, _v3),
        PrivacyPolicyStatus.upToDate,
      );
    });
  });

  group('acceptance record serialization', () {
    test('reads a record with a Firestore timestamp', () {
      final record = ConsentRecord.fromJson({
        'version': 2,
        'date': Timestamp.fromDate(DateTime.utc(2026, 11, 17, 15)),
      });
      expect(record?.version, 2);
      expect(
        record?.date?.isAtSameMomentAs(DateTime.utc(2026, 11, 17, 15)),
        isTrue,
      );
    });

    test('a pending server timestamp leaves only the date empty', () {
      expect(ConsentRecord.fromJson({'version': 2, 'date': null}), _v2);
    });

    test('writes back version and date', () {
      final record = ConsentRecord(version: 3, date: DateTime(2027, 1, 2));
      expect(record.toJson(), {'version': 3, 'date': DateTime(2027, 1, 2)});
      expect(ConsentRecord.fromJson(record.toJson()), record);
    });

    test('anything unreadable counts as no consent', () {
      for (final value in [
        null,
        '2026-11-10',
        <String, dynamic>{},
        {'version': '2'},
        {'version': 0},
      ]) {
        expect(ConsentRecord.fromJson(value), isNull, reason: '$value');
      }
    });

    test('the profile reads both records independently', () {
      final user = UserModel.fromJson(
        id: 'u',
        json: {
          'email': 'ana@example.com',
          'username': 'Ana',
          policyAcceptedField: {'version': 3},
          healthDataAuthorizationField: {'version': 2},
        },
      );
      expect(user.policyAccepted, _v3);
      expect(user.healthDataAuthorization, _v2);
      // Saving a profile never writes consent records.
      expect(user.toJson().keys, isNot(contains(policyAcceptedField)));
      expect(user.toJson().keys, isNot(contains(healthDataAuthorizationField)));
    });

    test('a profile from before versioned policies has no records', () {
      final user = UserModel.fromJson(
        id: 'u',
        json: {'privacyPolicyVersion': '2026-11-10'},
      );
      expect(user.policyAccepted, isNull);
      expect(user.healthDataAuthorization, isNull);
    });
  });

  group('saving acceptance records', () {
    test('sign-up saves both records with the version shown', () async {
      final firestore = _RecordingFirestore();
      await FirestoreProfileRepository(
        firestore: firestore,
        auth: _FakeAuth(),
      ).createProfile(
        const UserModel(id: 'uid-1', email: 'a@b.co', username: 'Ana'),
        acceptedPolicyVersion: 2,
      );

      final written = firestore.writes.single;
      expect(written.path, 'users/uid-1');
      _expectServerRecord(written.data[policyAcceptedField], 2);
      _expectServerRecord(written.data[healthDataAuthorizationField], 2);
      expect(written.data, isNot(contains('privacyPolicyVersion')));
    });

    test('reaccepting saves both records and nothing else', () async {
      final firestore = _RecordingFirestore();
      await FirestorePrivacyConsentRepository(
        firestore: firestore,
        auth: _FakeAuth(),
      ).acceptPolicy(3);

      final written = firestore.writes.single;
      expect(written.path, 'users/uid-1');
      expect(written.update, isTrue);
      expect(written.data.keys, {
        policyAcceptedField,
        healthDataAuthorizationField,
      });
      _expectServerRecord(written.data[policyAcceptedField], 3);
      _expectServerRecord(written.data[healthDataAuthorizationField], 3);
      expect(
        identical(
          written.data[policyAcceptedField],
          written.data[healthDataAuthorizationField],
        ),
        isFalse,
        reason: 'two separate records',
      );
    });

    test('reaccepting without a signed-in user writes nothing', () async {
      final firestore = _RecordingFirestore();
      await expectLater(
        FirestorePrivacyConsentRepository(
          firestore: firestore,
          auth: _FakeAuth(signedIn: false),
        ).acceptPolicy(2),
        throwsException,
      );
      expect(firestore.writes, isEmpty);
    });
  });

  group('startup gate', () {
    late StreamController<User?> auth;
    late StreamController<DocumentSnapshot<Map<String, dynamic>>> userDoc;
    late StreamController<PrivacyPolicyMetadata> metadata;
    late ProviderContainer container;

    ProviderContainer start() {
      final c = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => auth.stream),
          firebaseFirestoreProvider.overrideWithValue(
            _GateFirestore(userDoc.stream),
          ),
          trainingRepositoryProvider.overrideWithValue(_NoPlans()),
          privacyPolicyMetadataProvider.overrideWith((ref) => metadata.stream),
        ],
      );
      c.listen(onboardingStatusProvider, (_, _) {});
      return c;
    }

    setUp(() {
      auth = StreamController<User?>.broadcast();
      userDoc = StreamController.broadcast();
      metadata = StreamController.broadcast();
      container = start();
    });

    tearDown(() {
      container.dispose();
      auth.close();
      userDoc.close();
      metadata.close();
    });

    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    OnboardingStatus? gate() => container.read(onboardingStatusProvider).value;

    Future<void> signIn(
      Map<String, dynamic> profile,
      PrivacyPolicyMetadata m,
    ) async {
      auth.add(_FakeUser());
      await settle();
      metadata.add(m);
      await settle();
      userDoc.add(_FakeSnapshot(profile));
      await settle();
    }

    final acceptedV2 = {
      policyAcceptedField: {'version': 2},
      healthDataAuthorizationField: {'version': 2},
    };

    test('a user who accepted the current version continues', () async {
      await signIn(acceptedV2, testPolicyMetadata(current: 2));
      expect(gate(), OnboardingStatus.noDiagnosis);
    });

    test('a profile with only the old date field must accept', () async {
      await signIn({
        'privacyPolicyVersion': '2026-11-10',
      }, testPolicyMetadata());
      expect(gate(), OnboardingStatus.noPrivacyConsent);
    });

    test('a minor update does not block', () async {
      await signIn(
        acceptedV2,
        testPolicyMetadata(current: 3, minimum: 2, requiresReacceptance: false),
      );
      expect(gate(), OnboardingStatus.noDiagnosis);
    });

    test('a mandatory version published while the app runs blocks', () async {
      await signIn(acceptedV2, testPolicyMetadata(current: 2));
      expect(gate(), OnboardingStatus.noDiagnosis);

      metadata.add(testPolicyMetadata(current: 3));
      await settle();
      userDoc.add(_FakeSnapshot(acceptedV2));
      await settle();
      expect(gate(), OnboardingStatus.noPrivacyConsent);

      // Accepting updates the profile, and the gate lets the user in.
      userDoc.add(
        _FakeSnapshot({
          policyAcceptedField: {'version': 3},
          healthDataAuthorizationField: {'version': 3},
        }),
      );
      await settle();
      expect(gate(), OnboardingStatus.noDiagnosis);
    });

    test('after a restart or session restore the check runs again', () async {
      await signIn(acceptedV2, testPolicyMetadata(current: 3));
      expect(gate(), OnboardingStatus.noPrivacyConsent);

      // A new app start: fresh providers, the user is already signed in.
      container.dispose();
      for (final c in [auth, userDoc, metadata]) {
        await c.close();
      }
      auth = StreamController<User?>.broadcast();
      userDoc = StreamController.broadcast();
      metadata = StreamController.broadcast();
      container = start();
      await settle();
      await signIn(acceptedV2, testPolicyMetadata(current: 3));
      expect(gate(), OnboardingStatus.noPrivacyConsent);
    });
  });

  group('minor update notice', () {
    Future<_MemoryNoticeStore> pumpNotice(
      WidgetTester tester, {
      required PrivacyPolicyMetadata metadata,
      required ConsentRecord? accepted,
      _MemoryNoticeStore? store,
    }) async {
      final notices = store ?? _MemoryNoticeStore();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: PrivacyPolicyNoticeSlot()),
          ),
          GoRoute(
            path: '/privacy-policy',
            builder: (context, state) => const Text('policy screen'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            privacyPolicyMetadataProvider.overrideWith(
              (ref) => Stream.value(metadata),
            ),
            profileProvider.overrideWith(() => _FakeProfile(accepted)),
            policyNoticeStoreProvider.overrideWithValue(notices),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return notices;
    }

    final minor = testPolicyMetadata(
      current: 3,
      minimum: 2,
      requiresReacceptance: false,
    );
    final notice = find.byKey(const ValueKey('privacy-policy-notice'));

    testWidgets('shows after a minor update and opens the policy', (
      tester,
    ) async {
      await pumpNotice(tester, metadata: minor, accepted: _v2);
      expect(notice, findsOneWidget);
      expect(
        find.text(
          'Actualizamos la política de privacidad. Puedes revisar los cambios cuando quieras.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('privacy-policy-notice-view')),
      );
      await tester.pumpAndSettle();
      expect(find.text('policy screen'), findsOneWidget);
    });

    testWidgets('dismissing hides it for that version on this device', (
      tester,
    ) async {
      final store = await pumpNotice(tester, metadata: minor, accepted: _v2);
      await tester.tap(
        find.byKey(const ValueKey('privacy-policy-notice-dismiss')),
      );
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
      expect(store.dismissed, {'uid-1': 3});
    });

    testWidgets('stays hidden once dismissed', (tester) async {
      await pumpNotice(
        tester,
        metadata: minor,
        accepted: _v2,
        store: _MemoryNoticeStore()..dismissed['uid-1'] = 3,
      );
      expect(notice, findsNothing);
    });

    testWidgets('no notice when up to date or when acceptance is required', (
      tester,
    ) async {
      await pumpNotice(
        tester,
        metadata: testPolicyMetadata(current: 3),
        accepted: _v3,
      );
      expect(notice, findsNothing);
      await pumpNotice(
        tester,
        metadata: testPolicyMetadata(current: 3),
        accepted: _v2,
      );
      expect(notice, findsNothing);
    });
  });
}

void _expectServerRecord(Object? value, int version) {
  expect(value, isA<Map>());
  final record = value as Map;
  expect(record.keys, {'version', 'date'});
  expect(record['version'], version);
  expect(record['date'], FieldValue.serverTimestamp());
}

class _FakeProfile extends Profile {
  _FakeProfile(this.accepted);

  final ConsentRecord? accepted;

  @override
  Future<UserModel> build() async => UserModel(
    id: 'uid-1',
    email: 'ana@example.com',
    username: 'Ana',
    policyAccepted: accepted,
    healthDataAuthorization: accepted,
  );
}

class _MemoryNoticeStore implements PolicyNoticeStore {
  final Map<String, int> dismissed = {};

  @override
  Future<int?> dismissedVersion(String uid) async => dismissed[uid];

  @override
  Future<void> dismiss(String uid, int version) async =>
      dismissed[uid] = version;
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';
}

class _FakeAuth extends Fake implements FirebaseAuth {
  _FakeAuth({this.signedIn = true});

  final bool signedIn;

  @override
  User? get currentUser => signedIn ? _FakeUser() : null;
}

class _NoPlans extends Fake implements TrainingRepository {}

class _Write {
  _Write(this.path, this.data, {required this.update});

  final String path;
  final Map<String, dynamic> data;
  final bool update;
}

class _RecordingFirestore extends Fake implements FirebaseFirestore {
  final List<_Write> writes = [];

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _RecordingCollection(this, path);
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _RecordingCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _RecordingCollection(this.store, this.path);

  final _RecordingFirestore store;
  @override
  final String path;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) =>
      _RecordingDocument(store, '$path/$id');
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _RecordingDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _RecordingDocument(this.store, this.path);

  final _RecordingFirestore store;
  @override
  final String path;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async =>
      store.writes.add(_Write(path, data, update: false));

  @override
  Future<void> update(Map<Object, Object?> data) async => store.writes.add(
    _Write(path, Map<String, dynamic>.from(data), update: true),
  );
}

class _GateFirestore extends Fake implements FirebaseFirestore {
  _GateFirestore(this.userDoc);

  final Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'users');
    return _GateCollection(userDoc);
  }
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _GateCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _GateCollection(this.userDoc);

  final Stream<DocumentSnapshot<Map<String, dynamic>>> userDoc;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _GateDocument(userDoc);
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _GateDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _GateDocument(this.userDoc);

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
