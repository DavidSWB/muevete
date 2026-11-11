import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/auth/presentation/signup_screen.dart';
import 'package:muevete/l10n/app_localizations.dart';

/// A Google or Apple user reaches the sign-up form signed in but without a
/// profile; the form must still require both privacy consents.
void main() {
  for (final provider in ['google.com', 'apple.com']) {
    testWidgets('a $provider user cannot finish sign-up without consent', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: '/signup',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Text('home')),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignupScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _SocialAuthRepository(_SocialUser(provider)),
            ),
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

      // Social users have no password field: name and email only.
      expect(find.byType(TextField), findsNWidgets(3));
      await tester.tap(find.text('Female'));
      await tester.pump();

      final next = find.text('Next');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('How old are you?'), findsNothing);
      expect(find.textContaining('You must accept the policy'), findsOneWidget);

      for (final key in [
        'privacy-consent-checkbox',
        'privacy-health-checkbox',
      ]) {
        final box = find.byKey(ValueKey(key));
        await tester.ensureVisible(box);
        await tester.tap(box);
        await tester.pump();
      }
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('How old are you?'), findsOneWidget);
    });
  }
}

class _ProviderInfo extends Fake implements UserInfo {
  _ProviderInfo(this.providerId);

  @override
  final String providerId;
}

class _SocialUser extends Fake implements User {
  _SocialUser(this.provider);

  final String provider;

  @override
  String get uid => 'social-uid';

  @override
  String? get email => 'ana@example.com';

  @override
  String? get displayName => 'Ana';

  @override
  List<UserInfo> get providerData => [_ProviderInfo(provider)];
}

class _SocialAuthRepository extends Fake implements AuthRepository {
  _SocialAuthRepository(this.user);

  final User user;

  @override
  User? get currentUser => user;
}
