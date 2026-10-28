enum EducationalMessageType {
  /// Practical advice.
  tip,

  /// A fact backed by a guideline or study.
  evidence,
}

/// A short health message from the `educational_messages` collection.
/// Every text is a `{es, en}` map, read with `LocalizedMapX`.
class EducationalMessage {
  const EducationalMessage({
    required this.messageId,
    required this.type,
    required this.order,
    required this.text,
    required this.sourceLabel,
    required this.sourceUrl,
  });

  final String messageId;
  final EducationalMessageType type;

  /// Position in the rotation; lower comes first.
  final int order;

  final Map<String, String> text;

  /// Short citation shown on the card, such as "OMS · Comunicado, nov. 2020".
  final Map<String, String> sourceLabel;

  /// The page the citation links to, per language.
  final Map<String, String> sourceUrl;
}
