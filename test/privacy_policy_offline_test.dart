import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/privacy/data/bundled_privacy_policy.dart';
import 'package:muevete/features/privacy/data/firestore_privacy_policy_repository.dart';
import 'package:muevete/features/privacy/data/privacy_policy_codec.dart';
import 'package:muevete/features/privacy/domain/privacy_consent_repository.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_loader.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_repository.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/features/privacy/presentation/screens/privacy_consent_screen.dart';
import 'package:muevete/features/privacy/presentation/screens/privacy_policy_screen.dart';
import 'package:muevete/l10n/app_localizations.dart';

import 'helpers/privacy_policy_test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PrivacyPolicyVersion> bundled() => BundledPrivacyPolicy().load();

  group('choosing the policy to show', () {
    test(
      'Firestore read succeeds: the current version, from the server',
      () async {
        final loaded = await loadPrivacyPolicy(
          metadata: testPolicyMetadata(current: 3),
          repository: _FakeRepository(fetched: testPolicyVersion(3)),
          loadBundled: bundled,
        );
        expect(loaded.policy.version, 3);
        expect(loaded.source, PolicySource.server);
        expect(loaded.unavailableVersion, isNull);
      },
    );

    test('offline with a saved copy: that copy, marked as cached', () async {
      final loaded = await loadPrivacyPolicy(
        metadata: testPolicyMetadata(current: 3),
        repository: _FakeRepository(
          fetched: testPolicyVersion(3),
          fromCache: true,
        ),
        loadBundled: bundled,
      );
      expect(loaded.policy.version, 3);
      expect(loaded.source, PolicySource.cache);
    });

    test('no connection and no saved copy: the bundled version 2', () async {
      Object? reported;
      final loaded = await loadPrivacyPolicy(
        metadata: testPolicyMetadata(current: 2),
        repository: _FakeRepository(error: StateError('unavailable')),
        loadBundled: bundled,
        onFallback: (error, _) => reported = error,
      );
      expect(loaded.policy.version, 2);
      expect(loaded.source, PolicySource.bundled);
      expect(loaded.unavailableVersion, isNull);
      expect(reported, isA<StateError>());
    });

    test('the bundled copy is never shown as a newer version', () async {
      final loaded = await loadPrivacyPolicy(
        metadata: testPolicyMetadata(current: 4),
        repository: _FakeRepository(error: StateError('unavailable')),
        loadBundled: bundled,
      );
      expect(loaded.policy.version, 2);
      expect(loaded.unavailableVersion, 4);
    });

    test('policy text and both labels are never empty offline', () async {
      final loaded = await loadPrivacyPolicy(
        metadata: testPolicyMetadata(current: 2),
        repository: _FakeRepository(error: StateError('unavailable')),
        loadBundled: bundled,
      );
      for (final code in ['es', 'en']) {
        final sections = loaded.policy.sectionsFor(code);
        expect(sections, isNotEmpty);
        for (final section in sections) {
          expect(section.title.trim(), isNotEmpty);
          expect(section.blocks, isNotEmpty);
          for (final block in section.blocks) {
            expect(block.text.trim(), isNotEmpty);
          }
        }
        expect(loaded.policy.policyCheckbox[code]!.trim(), isNotEmpty);
        expect(loaded.policy.healthDataCheckbox[code]!.trim(), isNotEmpty);
      }
    });

    test(
      'without Firebase at all, the app still gets the bundled policy',
      () async {
        final container = ProviderContainer(
          overrides: [
            privacyPolicyRepositoryProvider.overrideWith(
              (ref) => throw StateError('No Firebase App'),
            ),
          ],
        );
        addTearDown(container.dispose);
      // Riverpod pauses providers nobody listens to.
      container.listen(currentPrivacyPolicyProvider, (_, _) {});

        final metadata = await container.read(
          privacyPolicyMetadataProvider.future,
        );
        expect(metadata.currentVersion, 2);
        expect(metadata.requiresReacceptance, isTrue);
        final loaded = await container.read(
          currentPrivacyPolicyProvider.future,
        );
        expect(loaded.policy.version, 2);
        expect(loaded.source, PolicySource.bundled);
      },
    );
  });

  group('Firestore reads', () {
    final v3 = PrivacyPolicyCodec.versionToMap(testPolicyVersion(3));

    test('a server read is marked as such', () async {
      final repository = FirestorePrivacyPolicyRepository(
        firestore: _VersionsFirestore(server: _Snap(v3, fromCache: false)),
      );
      final fetched = await repository.getVersion(3);
      expect(fetched.policy.version, 3);
      expect(fetched.fromCache, isFalse);
    });

    test('when the server read fails, the device cache is used', () async {
      final firestore = _VersionsFirestore(
        server: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        ),
        cache: _Snap(v3, fromCache: true),
      );
      final fetched = await FirestorePrivacyPolicyRepository(
        firestore: firestore,
      ).getVersion(3);
      expect(fetched.fromCache, isTrue);
      expect(firestore.sources, [null, Source.cache]);
    });

    test(
      'no server and nothing cached is an error, not an empty policy',
      () async {
        final repository = FirestorePrivacyPolicyRepository(
          firestore: _VersionsFirestore(
            server: FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
            ),
            cache: FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
            ),
          ),
        );
        await expectLater(
          repository.getVersion(3),
          throwsA(isA<FirebaseException>()),
        );
      },
    );

    test('a version that is not published is an error', () async {
      final repository = FirestorePrivacyPolicyRepository(
        firestore: _VersionsFirestore(server: _Snap(null, fromCache: false)),
      );
      await expectLater(repository.getVersion(3), throwsStateError);
    });
  });

  group('screens', () {
    Future<void> pump(
      WidgetTester tester,
      Widget screen,
      LoadedPrivacyPolicy loaded, {
      int metadataVersion = 2,
    }) async {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (context, state) => screen)],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentPrivacyPolicyProvider.overrideWith((ref) async => loaded),
            privacyPolicyMetadataProvider.overrideWith(
              (ref) =>
                  Stream.value(testPolicyMetadata(current: metadataVersion)),
            ),
            privacyConsentRepositoryProvider.overrideWithValue(_NoConsent()),
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
    }

    final note = find.byKey(const ValueKey('privacy-policy-source-note'));

    testWidgets('the live policy has no offline note', (tester) async {
      await pump(
        tester,
        const PrivacyPolicyScreen(),
        LoadedPrivacyPolicy(
          policy: testPolicyVersion(3),
          source: PolicySource.server,
        ),
      );
      expect(
        find.text('Versión 3 · vigente desde el 17 de noviembre de 2026'),
        findsOneWidget,
      );
      expect(note, findsNothing);
    });

    testWidgets('a saved copy says so', (tester) async {
      await pump(
        tester,
        const PrivacyPolicyScreen(),
        LoadedPrivacyPolicy(
          policy: testPolicyVersion(3),
          source: PolicySource.cache,
        ),
      );
      expect(
        find.text(
          'Sin conexión: estás viendo la copia guardada en tu teléfono (versión 3).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the bundled copy names its real version and the newer one', (
      tester,
    ) async {
      await pump(
        tester,
        const PrivacyPolicyScreen(),
        LoadedPrivacyPolicy(
          policy: testPolicyVersion(2),
          source: PolicySource.bundled,
          unavailableVersion: 3,
        ),
      );
      expect(
        find.text(
          'Sin conexión: estás viendo la copia incluida en la app (versión 2).',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('(versión 3) que no pudimos cargar'),
        findsOneWidget,
      );
      expect(
        find.text('Versión 2 · vigente desde el 17 de noviembre de 2026'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('privacy-policy-retry')),
        findsOneWidget,
      );
    });

    testWidgets('consent asks to retry instead of accepting an older text', (
      tester,
    ) async {
      await pump(
        tester,
        const PrivacyConsentScreen(),
        LoadedPrivacyPolicy(
          policy: testPolicyVersion(2),
          source: PolicySource.bundled,
          unavailableVersion: 3,
        ),
        metadataVersion: 3,
      );
      expect(
        find.byKey(const ValueKey('privacy-consent-unavailable')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('privacy-consent-checkbox')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('privacy-policy-retry')),
        findsOneWidget,
      );
    });

    testWidgets('consent with the bundled current version works offline', (
      tester,
    ) async {
      await pump(
        tester,
        const PrivacyConsentScreen(),
        LoadedPrivacyPolicy(
          policy: testPolicyVersion(2),
          source: PolicySource.bundled,
        ),
      );
      expect(
        find.byKey(const ValueKey('privacy-consent-unavailable')),
        findsNothing,
      );
      expect(find.text('Acepto la política v2.'), findsOneWidget);
      expect(find.text('Autorizo mis datos de salud v2.'), findsOneWidget);
    });
  });
}

class _FakeRepository implements PrivacyPolicyRepository {
  _FakeRepository({this.fetched, this.fromCache = false, this.error});

  final PrivacyPolicyVersion? fetched;
  final bool fromCache;
  final Object? error;

  @override
  Stream<PrivacyPolicyMetadata> watchMetadata() => const Stream.empty();

  @override
  Future<FetchedPolicyVersion> getVersion(int version) async {
    if (error != null) throw error!;
    return FetchedPolicyVersion(fetched!, fromCache: fromCache);
  }
}

class _NoConsent implements PrivacyConsentRepository {
  @override
  Future<void> acceptPolicy(int version) async {}
}

/// Answers `policies/privacy/versions/{n}` reads: [server] for a default
/// read, [cache] for a cache-only read. Each is a snapshot or an error.
class _VersionsFirestore extends Fake implements FirebaseFirestore {
  _VersionsFirestore({required this.server, this.cache});

  final Object server;
  final Object? cache;
  final List<Source?> sources = [];

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _Collection(this);
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _Collection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _Collection(this.store);

  final _VersionsFirestore store;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _Document(store);
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _Document extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _Document(this.store);

  final _VersionsFirestore store;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _Collection(store);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    store.sources.add(options?.source);
    final answer = options?.source == Source.cache ? store.cache : store.server;
    if (answer is DocumentSnapshot<Map<String, dynamic>>) return answer;
    throw answer!;
  }
}

// Test doubles: Firestore marks these @sealed for apps, not for tests.
// ignore: subtype_of_sealed_class
class _Snap extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  _Snap(this._data, {required bool fromCache})
    : _metadata = _Metadata(fromCache);

  final Map<String, dynamic>? _data;
  final SnapshotMetadata _metadata;

  @override
  bool get exists => _data != null;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  SnapshotMetadata get metadata => _metadata;
}

class _Metadata extends Fake implements SnapshotMetadata {
  _Metadata(this.isFromCache);

  @override
  final bool isFromCache;
}
