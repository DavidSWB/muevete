import 'dart:convert';
import 'dart:developer' as developer;

import 'package:muevete/features/education/domain/tip_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores one JSON string per user. Storage errors are logged and never
/// thrown, so tips can never break the app.
class SharedPreferencesTipPreferencesStore implements TipPreferencesStore {
  SharedPreferencesTipPreferencesStore([Future<SharedPreferences>? prefs])
    : _prefs = prefs;

  Future<SharedPreferences>? _prefs;

  Future<SharedPreferences> get _instance =>
      _prefs ??= SharedPreferences.getInstance();

  static String keyFor(String uid) => 'tips_v1_$uid';

  @override
  Future<TipPreferences> load(String uid) async {
    try {
      final raw = (await _instance).getString(keyFor(uid));
      if (raw == null) return TipPreferences.defaults;
      return TipPreferences.fromJson(jsonDecode(raw));
    } catch (error, stackTrace) {
      _log('read', error, stackTrace);
      return TipPreferences.defaults;
    }
  }

  @override
  Future<void> save(String uid, TipPreferences preferences) async {
    try {
      await (await _instance).setString(
        keyFor(uid),
        jsonEncode(preferences.toJson()),
      );
    } catch (error, stackTrace) {
      _log('write', error, stackTrace);
    }
  }

  void _log(String operation, Object error, StackTrace stackTrace) {
    developer.log(
      'Failed to $operation tip preferences',
      name: 'muevete.education',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
