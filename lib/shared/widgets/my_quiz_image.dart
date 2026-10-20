import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/utils/youtube_utils.dart';
import 'package:muevete/shared/widgets/exercise_video_player.dart';

class MyQuizImage extends StatelessWidget {
  const MyQuizImage({
    super.key,
    required this.imagePath,
    this.aspectRatio = 16 / 9,
  });

  final String imagePath;
  final double aspectRatio;

  Widget _buildFallback() {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        color: AppColors.softGrey,
        child: const Center(
          child: Icon(
            Icons.fitness_center,
            size: 48,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath.trim();
    Widget content;

    if (extractYouTubeId(trimmed) != null) {
      content = ExerciseVideoPlayer(
        visualPath: trimmed,
        aspectRatio: aspectRatio,
      );
    } else if (trimmed.startsWith('assets/')) {
      content = AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.asset(
          trimmed,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    } else if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://')) {
      content = AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.network(
          trimmed,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    } else {
      content = _buildFallback();
    }

    return ClipRRect(
      key: const ValueKey('diagnosis-exercise-visual'),
      borderRadius: BorderRadius.circular(20),
      child: content,
    );
  }
}
