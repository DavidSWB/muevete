import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/gamification/domain/achievement.dart';
import 'package:muevete/features/gamification/presentation/gamification_providers.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// The badges of the catalogue, earned ones in color and the rest as empty
/// slots that say how to earn them, on Progress.
class MedalCaseSection extends ConsumerWidget {
  const MedalCaseSection({super.key, required this.user});

  final UserModel user;

  /// Placeholder slots while the catalogue loads.
  static const int _loadingSlots = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final catalogue = ref.watch(achievementsProvider);
    final owned = user.unlockedBadgeIds.toSet();
    final achievements = catalogue.asData?.value;

    return Column(
      key: const ValueKey('medal-case'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.progressMedalsTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (achievements != null && achievements.isNotEmpty)
              Text(
                l10n.progressMedalsCount(
                  achievements
                      .where((a) => owned.contains(a.achievementId))
                      .length,
                  achievements.length,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: catalogue.when(
              skipLoadingOnRefresh: false,
              loading: () => Semantics(
                label: l10n.progressMedalsLoading,
                child: _MedalGrid(
                  children: [
                    for (var i = 0; i < _loadingSlots; i++)
                      const _MedalPlaceholder(),
                  ],
                ),
              ),
              error: (_, _) => Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.progressMedalsError,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(achievementsProvider),
                    child: Text(l10n.notifRetry),
                  ),
                ],
              ),
              data: (achievements) => _MedalGrid(
                children: [
                  for (final achievement in achievements)
                    _MedalTile(
                      achievement: achievement,
                      unlocked: owned.contains(achievement.achievementId),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Two columns on phones, more as the width allows.
class _MedalGrid extends StatelessWidget {
  const _MedalGrid({required this.children});

  final List<Widget> children;

  static const double _spacing = 12;
  static const double _minTileWidth = 140;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = math.max(
          2,
          math.min(5, (constraints.maxWidth / _minTileWidth).floor()),
        );
        final tileWidth =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: _spacing,
          runSpacing: 18,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, child: child),
          ],
        );
      },
    );
  }
}

class _MedalTile extends StatelessWidget {
  const _MedalTile({required this.achievement, required this.unlocked});

  final Achievement achievement;
  final bool unlocked;

  static const Map<String, IconData> _icons = {
    'self_improvement': Icons.self_improvement_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'explore': Icons.explore_rounded,
    'directions_walk': Icons.directions_walk_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = achievement.name.localized(context);
    final hint = achievement.description.localized(context);

    return Semantics(
      container: true,
      label: unlocked
          ? l10n.progressMedalUnlockedLabel(name)
          : l10n.progressMedalLockedLabel(name, hint),
      excludeSemantics: true,
      child: Column(
        key: ValueKey(
          'medal-${achievement.achievementId}-${unlocked ? 'unlocked' : 'locked'}',
        ),
        children: [
          unlocked
              ? _Medal(
                  icon: _icons[achievement.icon] ?? Icons.emoji_events_rounded,
                )
              : const _EmptySlot(),
          const SizedBox(height: 8),
          Text(
            unlocked ? name : hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: unlocked ? 14 : 12,
              height: 1.3,
              fontWeight: unlocked ? FontWeight.w700 : FontWeight.w500,
              color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A gradient disc in a gold ring, with the badge's icon.
class _Medal extends StatelessWidget {
  const _Medal({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.warningSoft,
        boxShadow: [
          BoxShadow(
            color: Color(0x33D97706),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.warning, width: 2.5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primarySoft, AppColors.primaryDark],
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}

/// A grey dashed circle where a badge not yet earned will go.
class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: _DashedCirclePainter(),
        child: Center(
          child: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textDisabled,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _MedalPlaceholder extends StatelessWidget {
  const _MedalPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.softGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.softGrey,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter();

  static const int _dashes = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textDisabled
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - 1,
    );
    const sweep = 2 * math.pi / _dashes;
    for (var i = 0; i < _dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) => false;
}
