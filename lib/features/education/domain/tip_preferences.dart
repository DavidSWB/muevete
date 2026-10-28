/// How often Home shows a health tip.
enum TipFrequency {
  /// One tip a day; once dismissed, the next one comes tomorrow.
  daily,

  /// A tip on every app launch, until it is dismissed.
  everyOpen,

  /// No tips.
  off;

  static TipFrequency fromName(Object? name) => TipFrequency.values.firstWhere(
    (frequency) => frequency.name == name,
    orElse: () => TipPreferences.defaults.frequency,
  );
}

/// What is kept on the device, per user, about health tips.
class TipPreferences {
  const TipPreferences({
    required this.frequency,
    this.lastDismissedId,
    this.lastDismissedOn,
  });

  static const defaults = TipPreferences(frequency: TipFrequency.daily);

  final TipFrequency frequency;

  /// The tip the user closed last; the rotation continues after it.
  final String? lastDismissedId;

  /// Local calendar date (midnight) of that dismissal.
  final DateTime? lastDismissedOn;

  TipPreferences copyWith({
    TipFrequency? frequency,
    String? lastDismissedId,
    DateTime? lastDismissedOn,
  }) {
    return TipPreferences(
      frequency: frequency ?? this.frequency,
      lastDismissedId: lastDismissedId ?? this.lastDismissedId,
      lastDismissedOn: lastDismissedOn ?? this.lastDismissedOn,
    );
  }

  Map<String, Object?> toJson() => {
    'frequency': frequency.name,
    'lastDismissedId': lastDismissedId,
    'lastDismissedOn': lastDismissedOn == null
        ? null
        : '${lastDismissedOn!.year.toString().padLeft(4, '0')}-'
              '${lastDismissedOn!.month.toString().padLeft(2, '0')}-'
              '${lastDismissedOn!.day.toString().padLeft(2, '0')}',
  };

  /// Defaults for anything missing or unreadable.
  static TipPreferences fromJson(Object? json) {
    if (json is! Map) return defaults;
    final id = json['lastDismissedId'];
    final rawDate = json['lastDismissedOn'];
    final match = rawDate is String
        ? RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(rawDate)
        : null;
    return TipPreferences(
      frequency: TipFrequency.fromName(json['frequency']),
      lastDismissedId: id is String ? id : null,
      lastDismissedOn: match == null
          ? null
          : DateTime(
              int.parse(match.group(1)!),
              int.parse(match.group(2)!),
              int.parse(match.group(3)!),
            ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TipPreferences &&
      other.frequency == frequency &&
      other.lastDismissedId == lastDismissedId &&
      other.lastDismissedOn == lastDismissedOn;

  @override
  int get hashCode => Object.hash(frequency, lastDismissedId, lastDismissedOn);
}

/// Keeps each user's tip preferences on this device.
abstract interface class TipPreferencesStore {
  /// [TipPreferences.defaults] when nothing usable is stored.
  Future<TipPreferences> load(String uid);

  Future<void> save(String uid, TipPreferences preferences);
}
