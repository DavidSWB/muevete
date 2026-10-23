import 'dart:convert';
import 'dart:developer' as developer;

import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores one JSON string per user. Storage errors are logged and never
/// thrown, so the tour can never break the app.
class SharedPreferencesWalkthroughStore implements WalkthroughStore {
  SharedPreferencesWalkthroughStore([Future<SharedPreferences>? prefs])
    : _prefs = prefs;

  Future<SharedPreferences>? _prefs;

  Future<SharedPreferences> get _instance =>
      _prefs ??= SharedPreferences.getInstance();

  static String keyFor(String uid) => 'walkthrough_v1_$uid';

  @override
  Future<WalkthroughProgress?> load(String uid) async {
    try {
      final raw = (await _instance).getString(keyFor(uid));
      if (raw == null) return null;
      return WalkthroughProgress.fromJson(jsonDecode(raw));
    } catch (error, stackTrace) {
      _log('read', error, stackTrace);
      return null;
    }
  }

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async {
    try {
      await (await _instance).setString(
        keyFor(uid),
        jsonEncode(progress.toJson()),
      );
    } catch (error, stackTrace) {
      _log('write', error, stackTrace);
    }
  }

  @override
  Future<void> clear(String uid) async {
    try {
      await (await _instance).remove(keyFor(uid));
    } catch (error, stackTrace) {
      _log('clear', error, stackTrace);
    }
  }

  void _log(String operation, Object error, StackTrace stackTrace) {
    developer.log(
      'Failed to $operation tour progress',
      name: 'muevete.walkthrough',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
