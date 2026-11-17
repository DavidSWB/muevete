import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/account/data/device_account_data_cleaner.dart';
import 'package:muevete/features/account/domain/account_deletion_service.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:muevete/features/education/data/shared_preferences_tip_preferences_store.dart';
import 'package:muevete/features/walkthrough/data/shared_preferences_walkthrough_store.dart';
import 'package:muevete/features/privacy/data/shared_preferences_policy_notice_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<String> log;

  setUp(() => log = []);

  AccountDeletionService service(FakeAuth auth, {FakeData? data}) =>
      AccountDeletionService(
        auth: auth,
        data: data ?? FakeData(log),
        local: FakeLocal(log),
      );

  test(
    'verifies identity, then deletes data, phone data and the account',
    () async {
      final auth = FakeAuth(log);
      await service(auth).deleteAccount(password: 'secret');

      expect(log, ['reauth:secret', 'data:uid-1', 'local:uid-1', 'deleteUser']);
    },
  );

  test('a cancelled identity check deletes nothing', () async {
    final auth = FakeAuth(log, reauth: const ReauthResult.cancelled());

    await expectLater(
      service(auth).deleteAccount(),
      throwsA(isA<AccountDeletionCancelled>()),
    );
    expect(log, ['reauth:null']);
  });

  test('a rejected password deletes nothing', () async {
    final auth = FakeAuth(
      log,
      reauthError: FirebaseAuthException(code: 'wrong-password'),
    );

    await expectLater(
      service(auth).deleteAccount(password: 'bad'),
      throwsA(
        isA<AccountDeletionException>()
            .having(
              (e) => e.stage,
              'stage',
              AccountDeletionStage.reauthentication,
            )
            .having((e) => e.isPartial, 'isPartial', isFalse),
      ),
    );
    expect(log, ['reauth:bad']);
  });

  test('a failed data deletion keeps the account and the phone data', () async {
    final auth = FakeAuth(log);

    await expectLater(
      service(auth, data: FakeData(log, fail: true)).deleteAccount(),
      throwsA(
        isA<AccountDeletionException>().having(
          (e) => e.stage,
          'stage',
          AccountDeletionStage.data,
        ),
      ),
    );
    expect(log, ['reauth:null', 'data:uid-1']);
  });

  test('a failed account deletion after the data is reported as partial, '
      'and retrying repeats every step', () async {
    final auth = FakeAuth(log, deleteFailures: 1);
    final deletion = service(auth);

    await expectLater(
      deletion.deleteAccount(),
      throwsA(
        isA<AccountDeletionException>()
            .having((e) => e.stage, 'stage', AccountDeletionStage.authAccount)
            .having((e) => e.isPartial, 'isPartial', isTrue),
      ),
    );

    log.clear();
    await deletion.deleteAccount();
    expect(log, ['reauth:null', 'data:uid-1', 'local:uid-1', 'deleteUser']);
  });

  test(
    'Apple accounts revoke the Apple token before the account is deleted',
    () async {
      final auth = FakeAuth(
        log,
        reauth: const ReauthResult.done(appleAuthorizationCode: 'apple-code'),
      );
      await service(auth).deleteAccount();

      expect(log, [
        'reauth:null',
        'data:uid-1',
        'local:uid-1',
        'revoke:apple-code',
        'deleteUser',
      ]);
    },
  );

  test('a failed Apple revocation does not stop the deletion', () async {
    final auth = FakeAuth(
      log,
      reauth: const ReauthResult.done(appleAuthorizationCode: 'apple-code'),
      failRevoke: true,
    );
    await service(auth).deleteAccount();

    expect(log.last, 'deleteUser');
  });

  group('phone data', () {
    test('cancels reminders and clears the tour and tip preferences', () async {
      const uid = 'uid-1';
      SharedPreferences.setMockInitialValues({
        SharedPreferencesWalkthroughStore.keyFor(uid): '{}',
        SharedPreferencesTipPreferencesStore.keyFor(uid): '{}',
        SharedPreferencesTipPreferencesStore.keyFor('other'): '{}',
        SharedPreferencesPolicyNoticeStore.keyFor(uid): 3,
        'locale': 'es',
      });
      var cancelled = 0;

      await DeviceAccountDataCleaner(
        walkthroughStore: SharedPreferencesWalkthroughStore(),
        cancelReminders: () async => cancelled++,
      ).clear(uid);

      final prefs = await SharedPreferences.getInstance();
      expect(cancelled, 1);
      expect(prefs.getKeys(), {
        SharedPreferencesTipPreferencesStore.keyFor('other'),
        'locale',
      });
    });

    test('a failing step does not stop the others', () async {
      const uid = 'uid-1';
      SharedPreferences.setMockInitialValues({
        SharedPreferencesTipPreferencesStore.keyFor(uid): '{}',
      });

      await DeviceAccountDataCleaner(
        walkthroughStore: SharedPreferencesWalkthroughStore(),
        cancelReminders: () async => throw StateError('plugin missing'),
      ).clear(uid);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });
  });
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';
}

class FakeAuth extends Fake implements AuthRepository {
  FakeAuth(
    this.log, {
    this.reauth = const ReauthResult.done(),
    this.reauthError,
    this.deleteFailures = 0,
    this.failRevoke = false,
  });

  final List<String> log;
  final ReauthResult reauth;
  final Object? reauthError;
  int deleteFailures;
  final bool failRevoke;

  @override
  User? get currentUser => FakeUser();

  @override
  ReauthMethod? get reauthMethod => ReauthMethod.password;

  @override
  Future<ReauthResult> reauthenticate({String? password}) async {
    log.add('reauth:$password');
    if (reauthError != null) throw reauthError!;
    return reauth;
  }

  @override
  Future<void> revokeAppleToken(String authorizationCode) async {
    log.add('revoke:$authorizationCode');
    if (failRevoke) throw StateError('revocation failed');
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

class FakeData implements AccountDataRepository {
  FakeData(this.log, {this.fail = false});

  final List<String> log;
  final bool fail;

  @override
  Future<void> deleteUserData(String uid) async {
    log.add('data:$uid');
    if (fail) throw StateError('permission-denied');
  }
}

class FakeLocal implements LocalAccountDataCleaner {
  FakeLocal(this.log);

  final List<String> log;

  @override
  Future<void> clear(String uid) async => log.add('local:$uid');
}
