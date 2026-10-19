import 'package:flutter/widgets.dart';

extension LocalizedMapX on Map<String, String>? {
  /// Resolves the localized string according to the active [BuildContext].
  ///
  /// Precedence:
  /// 1. Current locale language code (e.g. 'es' or 'en')
  /// 2. Spanish ('es')
  /// 3. English ('en')
  /// 4. First non-empty value
  /// 5. [fallback]
  String localized(BuildContext context, {String fallback = ''}) {
    if (this == null || this!.isEmpty) return fallback;
    final locale = Localizations.localeOf(context).languageCode;
    return localizedWithCode(locale, fallback: fallback);
  }

  /// Resolves the localized string using an explicit [languageCode].
  String localizedWithCode(String languageCode, {String fallback = ''}) {
    if (this == null || this!.isEmpty) return fallback;
    final map = this!;
    if (map.containsKey(languageCode) && map[languageCode]!.trim().isNotEmpty) {
      return map[languageCode]!;
    }
    if (map.containsKey('es') && map['es']!.trim().isNotEmpty) {
      return map['es']!;
    }
    if (map.containsKey('en') && map['en']!.trim().isNotEmpty) {
      return map['en']!;
    }
    for (final val in map.values) {
      if (val.trim().isNotEmpty) return val;
    }
    return fallback;
  }
}
