import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/utils/youtube_utils.dart';

class ExerciseThumbnail extends StatelessWidget {
  const ExerciseThumbnail({
    super.key,
    required this.visualPath,
    this.width = 64,
    this.height = 64,
    this.borderRadius = 12,
  });

  final String visualPath;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final videoId = extractYouTubeId(visualPath);

    Widget imageContent;

    if (videoId != null) {
      imageContent = Image.network(
        youtubeThumbnailUrl(videoId),
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _PlaceholderContainer(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _PlaceholderContainer(
            width: width,
            height: height,
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: AppColors.textMuted,
                size: 28,
              ),
            ),
          );
        },
      );
    } else if (visualPath.trim().startsWith('assets/')) {
      imageContent = Image.asset(
        visualPath.trim(),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _PlaceholderContainer(
            width: width,
            height: height,
            child: const Center(
              child: Icon(
                Icons.fitness_center,
                color: AppColors.textMuted,
                size: 28,
              ),
            ),
          );
        },
      );
    } else {
      imageContent = _PlaceholderContainer(
        width: width,
        height: height,
        child: const Center(
          child: Icon(
            Icons.fitness_center,
            color: AppColors.textMuted,
            size: 28,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: imageContent,
      ),
    );
  }
}

class _PlaceholderContainer extends StatelessWidget {
  const _PlaceholderContainer({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.disabledBg,
      child: child,
    );
  }
}
