import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/auth/presentation/signup_screen.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/l10n/app_localizations.dart';

import 'helpers/privacy_policy_test_data.dart';

void main() {
  testWidgets('sign-up asks for sex, then age, weight and height in turn', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final profiles = _RecordingProfileRepository();
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
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(profiles),
          ...privacyPolicyOverrides(version: 2),
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

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ana');
    await tester.enterText(fields.at(1), 'ana@example.com');
    await tester.enterText(fields.at(2), 'secret123');

    final next = find.text('Next');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();

    // The account form asks for a sex before moving on.
    expect(find.text('Please select your biological sex.'), findsOneWidget);
    expect(find.text('How old are you?'), findsNothing);

    await tester.tap(find.text('Female'));
    await tester.pump();
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();

    // Registration also needs both privacy consents, starting unchecked.
    expect(
      find.text(
        'You must accept the policy and authorize the processing of your '
        'health data to continue.',
      ),
      findsOneWidget,
    );
    expect(find.text('How old are you?'), findsNothing);
    // The labels are the ones of the policy version that will be stored.
    expect(find.text('I accept policy v2.'), findsOneWidget);
    expect(find.text('I authorize my health data v2.'), findsOneWidget);

    final policyBox = find.byKey(const ValueKey('privacy-consent-checkbox'));
    await tester.ensureVisible(policyBox);
    await tester.tap(policyBox);
    await tester.pump();
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('How old are you?'), findsNothing);

    final healthBox = find.byKey(const ValueKey('privacy-health-checkbox'));
    await tester.ensureVisible(healthBox);
    await tester.tap(healthBox);
    await tester.pump();
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();

    // Age, then weight, then height, one screen each.
    final stepButton = find.byKey(const ValueKey('signup-step-next'));
    expect(find.text('How old are you?'), findsOneWidget);
    await tester.tap(find.text('31'));
    await tester.pumpAndSettle();
    await tester.tap(stepButton);
    await tester.pumpAndSettle();

    expect(find.text('How much do you weigh?'), findsOneWidget);
    await tester.tap(find.text('lbs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('155'));
    await tester.pumpAndSettle();
    await tester.tap(stepButton);
    await tester.pumpAndSettle();

    expect(find.text('How tall are you?'), findsOneWidget);
    // Back keeps what was picked.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('How much do you weigh?'), findsOneWidget);
    await tester.tap(stepButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('169'));
    await tester.pumpAndSettle();
    expect(find.text('Register'), findsOneWidget);
    await tester.tap(stepButton);
    await tester.pumpAndSettle();

    final created = profiles.created.single;
    expect(created.id, 'new-uid');
    expect(created.sex, 'Female');
    expect(created.age, 31);
    // 155 lbs, stored in kilograms.
    expect(created.weight, 70.3);
    expect(created.height, 169);
    // The acceptance is stored with the profile, in the same write.
    expect(profiles.acceptedVersions.single, 2);
  });
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'new-uid';

  @override
  String? get email => 'ana@example.com';

  @override
  List<UserInfo> get providerData => const [];
}

class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  User? get currentUser => null;

  @override
  Future<User?> signUp(String email, String password) async => _FakeUser();
}

class _RecordingProfileRepository implements ProfileRepository {
  final List<UserModel> created = [];
  final List<int?> acceptedVersions = [];

  @override
  Future<void> createProfile(
    UserModel user, {
    int? acceptedPolicyVersion,
  }) async {
    created.add(user);
    acceptedVersions.add(acceptedPolicyVersion);
  }

  @override
  Future<UserModel> getProfile() => throw UnimplementedError();

  @override
  Future<void> saveProfile(UserModel user) => throw UnimplementedError();

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) =>
      throw UnimplementedError();

  @override

  Future<void> unlockBadges(Set<String> badgeIds) async {}


  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) => throw UnimplementedError();
}
