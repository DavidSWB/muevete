import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';

/// Removes everything the app stores in Firestore for one user.
abstract class AccountDataRepository {
  /// Deletes `users/{uid}`. Deleting a document that no longer exists
  /// succeeds, so a retry after a partial failure is safe.
  Future<void> deleteUserData(String uid);
}

/// Removes what the app keeps on this phone for one user: scheduled
/// reminders, guided-tour progress and tip preferences. Never throws.
abstract class LocalAccountDataCleaner {
  Future<void> clear(String uid);
}

/// Where a deletion stopped.
enum AccountDeletionStage {
  /// Nothing was deleted: identity could not be verified.
  reauthentication,

  /// Nothing was deleted: the app data could not be removed.
  data,

  /// The app data was removed but the sign-in account was not.
  authAccount,
}

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.stage, this.cause);

  final AccountDeletionStage stage;
  final Object cause;

  /// True when some data was already deleted.
  bool get isPartial => stage == AccountDeletionStage.authAccount;

  @override
  String toString() => 'AccountDeletionException($stage, $cause)';
}

/// The user closed the identity check; nothing was deleted.
class AccountDeletionCancelled implements Exception {
  const AccountDeletionCancelled();
}

/// Deletes the signed-in account in an order that never leaves data behind
/// without a way to remove it:
///
/// 1. reauthenticate, so the last step does not fail for an old sign-in;
/// 2. delete `users/{uid}` while the user can still pass the security rules;
/// 3. clear what is stored on the phone;
/// 4. revoke the Apple token, when Apple was used;
/// 5. delete the Firebase Authentication account.
///
/// If step 5 fails, the data is already gone and the user stays signed in;
/// calling [deleteAccount] again repeats every step safely.
class AccountDeletionService {
  AccountDeletionService({
    required AuthRepository auth,
    required AccountDataRepository data,
    required LocalAccountDataCleaner local,
  }) : _auth = auth,
       _data = data,
       _local = local;

  final AuthRepository _auth;
  final AccountDataRepository _data;
  final LocalAccountDataCleaner _local;

  /// How the user will be asked to verify their identity.
  ReauthMethod? get reauthMethod => _auth.reauthMethod;

  Future<void> deleteAccount({String? password}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw AccountDeletionException(
        AccountDeletionStage.reauthentication,
        StateError('No signed-in user.'),
      );
    }

    final ReauthResult reauth;
    try {
      reauth = await _auth.reauthenticate(password: password);
    } catch (error) {
      throw AccountDeletionException(
        AccountDeletionStage.reauthentication,
        error,
      );
    }
    if (reauth.cancelled) throw const AccountDeletionCancelled();

    try {
      await _data.deleteUserData(uid);
    } catch (error) {
      throw AccountDeletionException(AccountDeletionStage.data, error);
    }

    await _local.clear(uid);

    final appleCode = reauth.appleAuthorizationCode;
    if (appleCode != null) {
      try {
        await _auth.revokeAppleToken(appleCode);
      } catch (_) {
        // Deleting the account must not depend on Apple's revocation
        // endpoint; the account and its data are removed either way.
      }
    }

    try {
      await _auth.deleteCurrentUser();
    } catch (error) {
      throw AccountDeletionException(AccountDeletionStage.authAccount, error);
    }
  }
}
