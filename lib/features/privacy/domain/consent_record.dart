import 'package:cloud_firestore/cloud_firestore.dart';

/// Fields of `users/{uid}` that record what the user agreed to. Each one is
/// a [ConsentRecord] and is written on its own, so either can change
/// without touching the other.
const String policyAcceptedField = 'policyAccepted';
const String healthDataAuthorizationField = 'healthDataAuthorization';

/// One consent: the policy version it refers to and when it was given.
class ConsentRecord {
  const ConsentRecord({required this.version, this.date});

  final int version;

  /// Server time of the acceptance. Null only while a fresh write has not
  /// reached the server yet.
  final DateTime? date;

  /// The record stored at [value], or null when there is none or it cannot
  /// be read, which counts as not having consented.
  static ConsentRecord? fromJson(Object? value) {
    if (value is! Map) return null;
    final version = value['version'];
    if (version is! int || version < 1) return null;
    final date = value['date'];
    return ConsentRecord(
      version: version,
      date: switch (date) {
        Timestamp() => date.toDate(),
        DateTime() => date,
        String() => DateTime.tryParse(date),
        _ => null,
      },
    );
  }

  Map<String, dynamic> toJson() => {'version': version, 'date': date};

  @override
  bool operator ==(Object other) =>
      other is ConsentRecord && other.version == version && other.date == date;

  @override
  int get hashCode => Object.hash(version, date);
}
