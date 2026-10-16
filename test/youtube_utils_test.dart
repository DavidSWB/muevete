import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/shared/utils/youtube_utils.dart';

void main() {
  group('extractYouTubeId', () {
    test('extracts ID from youtu.be short URL', () {
      expect(extractYouTubeId('https://youtu.be/LtTcXXgeRYo'), equals('LtTcXXgeRYo'));
      expect(extractYouTubeId('https://youtu.be/aobuJU4ALyY'), equals('aobuJU4ALyY'));
    });

    test('extracts ID from youtube.com/watch?v= URL', () {
      expect(
        extractYouTubeId('https://www.youtube.com/watch?v=LtTcXXgeRYo'),
        equals('LtTcXXgeRYo'),
      );
      expect(
        extractYouTubeId('https://m.youtube.com/watch?v=aobuJU4ALyY'),
        equals('aobuJU4ALyY'),
      );
    });

    test('extracts ID from youtube.com/shorts/ URL', () {
      expect(
        extractYouTubeId('https://www.youtube.com/shorts/LtTcXXgeRYo'),
        equals('LtTcXXgeRYo'),
      );
    });

    test('extracts ID from youtube.com/embed/ URL', () {
      expect(
        extractYouTubeId('https://www.youtube.com/embed/LtTcXXgeRYo'),
        equals('LtTcXXgeRYo'),
      );
    });

    test('extracts ID from youtube.com/live/ URL', () {
      expect(
        extractYouTubeId('https://www.youtube.com/live/LtTcXXgeRYo'),
        equals('LtTcXXgeRYo'),
      );
    });

    test('ignores query parameters like si, t, start', () {
      expect(
        extractYouTubeId('https://youtu.be/LtTcXXgeRYo?si=abc123xyz&t=42'),
        equals('LtTcXXgeRYo'),
      );
      expect(
        extractYouTubeId('https://www.youtube.com/watch?v=LtTcXXgeRYo&t=10s&feature=shared'),
        equals('LtTcXXgeRYo'),
      );
      expect(
        extractYouTubeId('https://www.youtube.com/shorts/LtTcXXgeRYo?si=123'),
        equals('LtTcXXgeRYo'),
      );
    });

    test('handles whitespace around URL', () {
      expect(
        extractYouTubeId('   https://youtu.be/LtTcXXgeRYo   '),
        equals('LtTcXXgeRYo'),
      );
    });

    test('returns null for null, empty or invalid strings', () {
      expect(extractYouTubeId(null), isNull);
      expect(extractYouTubeId(''), isNull);
      expect(extractYouTubeId('   '), isNull);
      expect(extractYouTubeId('not a url'), isNull);
      expect(extractYouTubeId('assets/images/workout.png'), isNull);
      expect(extractYouTubeId('https://vimeo.com/123456789'), isNull);
      expect(extractYouTubeId('https://youtube.com'), isNull);
      expect(extractYouTubeId('https://youtube.com/watch'), isNull);
      expect(extractYouTubeId('https://youtu.be/'), isNull);
      expect(extractYouTubeId('https://youtu.be/short'), isNull); // not 11 chars
    });
  });

  group('youtubeThumbnailUrl', () {
    test('builds correct hqdefault thumbnail URL', () {
      expect(
        youtubeThumbnailUrl('LtTcXXgeRYo'),
        equals('https://img.youtube.com/vi/LtTcXXgeRYo/hqdefault.jpg'),
      );
    });
  });
}
