import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/shared/widgets/exercise_thumbnail.dart';
import 'package:muevete/shared/widgets/exercise_video_player.dart';

void main() {
  group('ExerciseThumbnail Widget', () {
    testWidgets('renders network image for YouTube visualPath', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseThumbnail(
              visualPath: 'https://youtu.be/LtTcXXgeRYo',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<NetworkImage>());
      final networkImage = image.image as NetworkImage;
      expect(
        networkImage.url,
        equals('https://img.youtube.com/vi/LtTcXXgeRYo/hqdefault.jpg'),
      );
    });

    testWidgets('renders placeholder icon for non-YouTube empty path', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseThumbnail(
              visualPath: '',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('renders placeholder icon for invalid URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseThumbnail(
              visualPath: 'https://other-site.com/video',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });
  });

  group('ExerciseVideoPlayer Widget', () {
    testWidgets('displays fallback card when visualPath has no YouTube ID', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseVideoPlayer(
              visualPath: 'https://other-site.com/video',
            ),
          ),
        ),
      );

      expect(find.text('Video unavailable in player'), findsOneWidget);
      expect(find.text('Open in YouTube'), findsOneWidget);
    });

    testWidgets('displays fallback without open button when visualPath is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseVideoPlayer(
              visualPath: '',
            ),
          ),
        ),
      );

      expect(find.text('Video unavailable in player'), findsOneWidget);
      expect(find.text('Open in YouTube'), findsNothing);
    });
  });
}
