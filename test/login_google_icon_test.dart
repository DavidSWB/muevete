import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/auth/presentation/login_screen.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/widgets/social_sign_in_button.dart';

/// The Google button shows a local icon: it used to download an SVG that
/// Image cannot decode, which logged an error every time the login opened.
void main() {
  testWidgets('the Google button loads nothing from the network', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final google = find.ancestor(
      of: find.text('Continue with Google'),
      matching: find.byType(SocialSignInButton),
    );
    expect(google, findsOneWidget);
    expect(
      find.descendant(of: google, matching: find.byIcon(Icons.login)),
      findsOneWidget,
    );
    final networkImages = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is NetworkImage);
    expect(networkImages, isEmpty);
  });
}
