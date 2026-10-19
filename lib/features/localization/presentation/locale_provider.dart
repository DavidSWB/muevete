import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefLocaleKey = 'user_selected_locale';

/// Supported locales in Muévete: Spanish ('es') and English ('en').
const List<Locale> supportedLocales = [
  Locale('es'),
  Locale('en'),
];

/// Fallback locale when device locale is unsupported or detection fails.
const Locale defaultAppLocale = Locale('es');

/// Detects the device locale and checks if it is supported ('es' or 'en').
/// Defaults to Spanish ('es') if unsupported.
Locale resolveDeviceLocale([Locale? deviceLocale]) {
  final candidate = deviceLocale ?? ui.PlatformDispatcher.instance.locale;
  final code = candidate.languageCode.toLowerCase();
  if (code == 'en') {
    return const Locale('en');
  }
  return const Locale('es');
}

/// Provides the active [Locale] for the application.
final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  SharedPreferences? _prefs;

  @override
  Locale build() {
    _initAndLoad();
    return resolveDeviceLocale();
  }

  Future<void> _initAndLoad() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final savedCode = _prefs?.getString(_prefLocaleKey);
      if (savedCode != null && (savedCode == 'es' || savedCode == 'en')) {
        state = Locale(savedCode);
        return;
      }
    } catch (_) {
      // Gracefully ignore local storage reading issues and keep initial state
    }
  }

  /// Manually selects a locale and persists the choice across restarts.
  Future<void> setLocale(Locale newLocale) async {
    final code = newLocale.languageCode.toLowerCase();
    final validLocale = (code == 'en') ? const Locale('en') : const Locale('es');
    state = validLocale;

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString(_prefLocaleKey, validLocale.languageCode);
    } catch (_) {
      // Persisting failed, state is still updated in-memory
    }
  }

  /// Toggles between Spanish and English.
  Future<void> toggleLocale() async {
    if (state.languageCode == 'es') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('es'));
    }
  }
}
