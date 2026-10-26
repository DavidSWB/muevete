import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/auth/presentation/signup_screen.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/l10n/app_localizations.dart';

void main() {
  testWidgets('sign-up requires a sex and stores the chosen value', (
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
    await tester.enterText(fields.at(3), '28');
    await tester.enterText(fields.at(4), '60');
    await tester.enterText(fields.at(5), '165');

    final register = find.text('Register');
    await tester.ensureVisible(register);
    await tester.tap(register);
    await tester.pumpAndSettle();

    expect(find.text('Please select your biological sex.'), findsOneWidget);
    expect(profiles.created, isEmpty);

    await tester.tap(find.text('Female'));
    await tester.pump();
    await tester.tap(register);
    await tester.pumpAndSettle();

    expect(profiles.created.single.sex, 'Female');
    expect(profiles.created.single.id, 'new-uid');
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

  @override
  Future<void> createProfile(UserModel user) async => created.add(user);

  @override
  Future<UserModel> getProfile() => throw UnimplementedError();

  @override
  Future<void> saveProfile(UserModel user) => throw UnimplementedError();

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) =>
      throw UnimplementedError();

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
  }) => throw UnimplementedError();
}
