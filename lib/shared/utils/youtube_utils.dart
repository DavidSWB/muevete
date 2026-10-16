/// Extracts a YouTube video ID from a given [url].
///
/// Supported formats:
/// - `https://youtu.be/<id>`
/// - `https://www.youtube.com/watch?v=<id>`
/// - `https://www.youtube.com/shorts/<id>`
/// - `https://www.youtube.com/embed/<id>`
///
/// Query parameters like `si`, `t`, `start` are ignored.
/// Returns `null` for empty, null, invalid, or non-YouTube values.
String? extractYouTubeId(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');

  if (host == 'youtu.be') {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      return _cleanId(segments.first);
    }
    return null;
  }

  if (host == 'youtube.com' || host == 'm.youtube.com') {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    final firstSegment = segments.first;

    if (firstSegment == 'watch') {
      return _cleanId(uri.queryParameters['v']);
    }

    if (firstSegment == 'shorts' ||
        firstSegment == 'embed' ||
        firstSegment == 'live') {
      if (segments.length >= 2) {
        return _cleanId(segments[1]);
      }
    }
  }

  return null;
}

/// Returns the YouTube thumbnail URL for [videoId] using `hqdefault.jpg`.
String youtubeThumbnailUrl(String videoId) =>
    'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

/// Validates that [raw] conforms to the standard 11-character YouTube video ID format.
String? _cleanId(String? raw) {
  if (raw == null) return null;
  final cleaned = raw.trim();
  if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(cleaned)) {
    return cleaned;
  }
  return null;
}
