import 'dart:developer' as developer;

import 'package:muevete/features/privacy/domain/policy_notice_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage errors are logged and never thrown: at worst the notice shows
/// again.
class SharedPreferencesPolicyNoticeStore implements PolicyNoticeStore {
  SharedPreferencesPolicyNoticeStore([Future<SharedPreferences>? prefs])
    : _prefs = prefs;

  Future<SharedPreferences>? _prefs;

  Future<SharedPreferences> get _instance =>
      _prefs ??= SharedPreferences.getInstance();

  static String keyFor(String uid) => 'privacy_notice_v1_$uid';

  @override
  Future<int?> dismissedVersion(String uid) async {
    try {
      return (await _instance).getInt(keyFor(uid));
    } catch (error, stackTrace) {
      _log('read', error, stackTrace);
      return null;
    }
  }

  @override
  Future<void> dismiss(String uid, int version) async {
    try {
      await (await _instance).setInt(keyFor(uid), version);
    } catch (error, stackTrace) {
      _log('write', error, stackTrace);
    }
  }

  void _log(String operation, Object error, StackTrace stackTrace) {
    developer.log(
      'Failed to $operation the dismissed policy notice',
      name: 'muevete.privacy',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
