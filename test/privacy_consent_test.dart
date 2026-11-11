import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/privacy/domain/privacy_consent_repository.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/features/privacy/presentation/privacy_policy_content.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/features/privacy/presentation/screens/privacy_consent_screen.dart';
import 'package:muevete/features/privacy/presentation/screens/privacy_policy_screen.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/settings/presentation/screens/settings_screen.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('policy version', () {
    test('only the current version counts as accepted', () {
      expect(hasAcceptedCurrentPrivacyPolicy({}), isFalse);
      expect(
        hasAcceptedCurrentPrivacyPolicy({
          privacyPolicyVersionField: '2025-01-01',
        }),
        isFalse,
      );
      expect(
        hasAcceptedCurrentPrivacyPolicy({
          privacyPolicyVersionField: currentPrivacyPolicyVersion,
        }),
        isTrue,
      );
      expect(currentPrivacyPolicyVersion, '2026-11-10');
    });

    test('both languages name the controller and the contact channel', () {
      for (final code in ['es', 'en']) {
        final text = privacyPolicySections(code)
            .expand((section) => [section.title, ...section.paragraphs])
            .join('\n');
        expect(text, contains('David Camilo Eraso Oñate'));
        expect(text, contains(privacyPolicyContactEmail));
        expect(text, contains('Calle 18 No. 34-104'));
        expect(text, contains('nam5'));
        expect(text, contains(currentPrivacyPolicyVersion));
      }
    });
  });

  group('consent screen', () {
    testWidgets('accept stays disabled until both boxes are ticked', (
      tester,
    ) async {
      final consent = _RecordingConsentRepository();
      await _pumpConsentScreen(tester, consent);

      final accept = find.byKey(const ValueKey('privacy-consent-accept'));
      await tester.tap(accept);
      await tester.pump();
      expect(consent.calls, 0);

      await tester.tap(find.byKey(const ValueKey('privacy-consent-checkbox')));
      await tester.pump();
      await tester.tap(accept);
      await tester.pump();
      expect(consent.calls, 0, reason: 'health data not authorized yet');

      await tester.tap(find.byKey(const ValueKey('privacy-health-checkbox')));
      await tester.pump();
      await tester.tap(accept);
      await tester.pumpAndSettle();
      expect(consent.calls, 1);
      expect(find.byKey(const ValueKey('privacy-consent-error')), findsNothing);
    });

    testWidgets('a failed save shows an error and allows a retry', (
      tester,
    ) async {
      final consent = _RecordingConsentRepository(failFirst: true);
      await _pumpConsentScreen(tester, consent);

      await tester.tap(find.byKey(const ValueKey('privacy-consent-checkbox')));
      await tester.tap(find.byKey(const ValueKey('privacy-health-checkbox')));
      await tester.pump();
      final accept = find.byKey(const ValueKey('privacy-consent-accept'));
      await tester.tap(accept);
      await tester.pumpAndSettle();

      expect(consent.calls, 1);
      expect(
        find.byKey(const ValueKey('privacy-consent-error')),
        findsOneWidget,
      );

      await tester.tap(accept);
      await tester.pumpAndSettle();
      expect(consent.calls, 2);
      expect(find.byKey(const ValueKey('privacy-consent-error')), findsNothing);
    });

    testWidgets('the link opens the full policy', (tester) async {
      await _pumpConsentScreen(tester, _RecordingConsentRepository());

      await tester.tap(find.byKey(const ValueKey('privacy-read-policy')));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(find.text('Current version: 2026-11-10'), findsOneWidget);
    });
  });

  testWidgets('Settings opens the privacy policy', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SettingsScreen()),
        GoRoute(
          path: '/privacy-policy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(_FakeProfile.new),
          walkthroughStoreProvider.overrideWithValue(_MemoryStore()),
          walkthroughUserIdProvider.overrideWithValue('u'),
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

    final tile = find.byKey(const ValueKey('settings-privacy-policy'));
    await tester.ensureVisible(tile);
    expect(find.text('Política de privacidad'), findsOneWidget);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.text('1. Responsable del tratamiento'), findsOneWidget);
  });
}

Future<void> _pumpConsentScreen(
  WidgetTester tester,
  PrivacyConsentRepository consent, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PrivacyConsentScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        privacyConsentRepositoryProvider.overrideWithValue(consent),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _RecordingConsentRepository implements PrivacyConsentRepository {
  _RecordingConsentRepository({this.failFirst = false});

  final bool failFirst;
  int calls = 0;

  @override
  Future<void> acceptCurrentPolicy() async {
    calls++;
    if (failFirst && calls == 1) throw Exception('permission-denied');
  }
}

class _FakeProfile extends Profile {
  @override
  Future<UserModel> build() async => UserModel(
    id: 'u',
    email: 'user@example.com',
    username: 'user',
    completedWorkouts: const [],
  );
}

class _MemoryStore implements WalkthroughStore {
  final Map<String, WalkthroughProgress> data = {};

  @override
  Future<WalkthroughProgress?> load(String uid) async => data[uid];

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async =>
      data[uid] = progress;

  @override
  Future<void> clear(String uid) async => data.remove(uid);
}
