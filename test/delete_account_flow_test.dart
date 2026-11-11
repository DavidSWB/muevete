import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/account/domain/account_deletion_service.dart';
import 'package:muevete/features/account/presentation/account_providers.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
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

  testWidgets('cancelling the first warning deletes nothing', (tester) async {
    final auth = _Auth(ReauthMethod.password);
    await _pumpSettings(tester, auth);

    await _openDeletion(tester);
    expect(
      find.byKey(const ValueKey('delete-account-warning')),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('delete-account-confirm')), findsNothing);
    expect(auth.log, isEmpty);
  });

  testWidgets('deletion needs the word and the password, then signs out', (
    tester,
  ) async {
    final auth = _Auth(ReauthMethod.password);
    await _pumpSettings(tester, auth);

    await _openDeletion(tester);
    await tester.tap(find.byKey(const ValueKey('delete-account-continue')));
    await tester.pumpAndSettle();

    final confirm = find.byKey(const ValueKey('delete-account-confirm-button'));
    bool enabled() => tester.widget<TextButton>(confirm).onPressed != null;
    expect(enabled(), isFalse);

    await tester.enterText(
      find.byKey(const ValueKey('delete-account-word')),
      'delete',
    );
    await tester.pump();
    expect(enabled(), isFalse, reason: 'password still missing');

    await tester.enterText(
      find.byKey(const ValueKey('delete-account-password')),
      'secret',
    );
    await tester.pump();
    expect(enabled(), isTrue);

    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(auth.log, ['reauth:secret', 'data', 'deleteUser']);
    expect(find.text('login page'), findsOneWidget);
    expect(find.text('Your account and data were deleted.'), findsOneWidget);
  });

  testWidgets('social accounts are not asked for a password', (tester) async {
    final auth = _Auth(ReauthMethod.google);
    await _pumpSettings(tester, auth);

    await _openDeletion(tester);
    await tester.tap(find.byKey(const ValueKey('delete-account-continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('delete-account-password')), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('delete-account-word')),
      'DELETE',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('delete-account-confirm-button')),
    );
    await tester.pumpAndSettle();

    expect(auth.log, ['reauth:null', 'data', 'deleteUser']);
  });

  testWidgets('a wrong password is reported and nothing is deleted', (
    tester,
  ) async {
    final auth = _Auth(
      ReauthMethod.password,
      reauthError: FirebaseAuthException(code: 'wrong-password'),
    );
    await _pumpSettings(tester, auth);
    await _confirmWithPassword(tester);

    expect(auth.log, ['reauth:secret']);
    expect(
      find.text('The password is incorrect. Nothing was deleted.'),
      findsOneWidget,
    );
    expect(find.text('login page'), findsNothing);
  });

  testWidgets('a partial failure offers a retry that finishes the deletion', (
    tester,
  ) async {
    final auth = _Auth(ReauthMethod.password, deleteFailures: 1);
    await _pumpSettings(tester, auth);
    await _confirmWithPassword(tester);

    expect(
      find.byKey(const ValueKey('delete-account-partial')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('delete-account-retry')));
    await tester.pumpAndSettle();

    expect(auth.log, [
      'reauth:secret',
      'data',
      'reauth:secret',
      'data',
      'deleteUser',
    ]);
    expect(find.text('login page'), findsOneWidget);
  });
}

Future<void> _openDeletion(WidgetTester tester) async {
  final tile = find.byKey(const ValueKey('settings-delete-account'));
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

Future<void> _confirmWithPassword(WidgetTester tester) async {
  await _openDeletion(tester);
  await tester.tap(find.byKey(const ValueKey('delete-account-continue')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey('delete-account-word')),
    'DELETE',
  );
  await tester.enterText(
    find.byKey(const ValueKey('delete-account-password')),
    'secret',
  );
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey('delete-account-confirm-button')));
  await tester.pumpAndSettle();
}

Future<void> _pumpSettings(WidgetTester tester, _Auth auth) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('login page')),
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
        accountDeletionServiceProvider.overrideWithValue(
          AccountDeletionService(
            auth: auth,
            data: _Data(auth.log),
            local: _Local(),
          ),
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
}

class _User extends Fake implements User {
  @override
  String get uid => 'u';
}

class _Auth extends Fake implements AuthRepository {
  _Auth(this.method, {this.reauthError, this.deleteFailures = 0});

  final ReauthMethod method;
  final Object? reauthError;
  int deleteFailures;
  final List<String> log = [];

  @override
  User? get currentUser => _User();

  @override
  ReauthMethod? get reauthMethod => method;

  @override
  Future<ReauthResult> reauthenticate({String? password}) async {
    log.add('reauth:$password');
    if (reauthError != null) throw reauthError!;
    return const ReauthResult.done();
  }

  @override
  Future<void> deleteCurrentUser() async {
    if (deleteFailures > 0) {
      deleteFailures--;
      throw FirebaseAuthException(code: 'network-request-failed');
    }
    log.add('deleteUser');
  }
}

class _Data implements AccountDataRepository {
  _Data(this.log);

  final List<String> log;

  @override
  Future<void> deleteUserData(String uid) async => log.add('data');
}

class _Local implements LocalAccountDataCleaner {
  @override
  Future<void> clear(String uid) async {}
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
