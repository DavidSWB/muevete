import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/gamification/domain/joint_level.dart';
import 'package:muevete/features/gamification/domain/reward_rules.dart';
import 'package:muevete/features/gamification/presentation/gamification_providers.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// Movement XP and the joint progression levels, on Progress. Separate from
/// the assessment's joint stats, which still choose exercise variants.
class MovementProgressSection extends ConsumerWidget {
  const MovementProgressSection({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final thresholds =
        (ref.watch(rewardRulesProvider).asData?.value ?? RewardRules.defaults)
            .levelThresholds;
    final joints = [
      ('shoulder', l10n.progressShoulder),
      ('hip', l10n.progressHip),
      ('knee', l10n.progressKnee),
      ('ankle', l10n.progressAnkle),
    ];

    return Column(
      key: const ValueKey('movement-progress'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressMovementTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.warningSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.progressMovementXp(user.movementXp),
                      key: const ValueKey('movement-xp'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.progressMovementXpHint,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textMuted,
                  ),
                ),
                const Divider(height: 28),
                for (final (key, name) in joints)
                  _JointLevelRow(
                    jointKey: key,
                    name: name,
                    level: JointLevel.fromPoints(
                      user.jointProgress[key] ?? 0,
                      thresholds,
                    ),
                  ),
                Text(
                  l10n.progressJointHint,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JointLevelRow extends StatelessWidget {
  const _JointLevelRow({
    required this.jointKey,
    required this.name,
    required this.level,
  });

  final String jointKey;
  final String name;
  final JointLevel level;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final next = level.nextLevelAt;
    final label = next == null
        ? l10n.progressJointMaxLevelLabel(name, level.level)
        : l10n.progressJointLevelLabel(name, level.level, level.points, next);

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Padding(
        key: ValueKey('joint-level-$jointKey'),
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  l10n.progressJointLevel(level.level),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  next == null
                      ? l10n.progressJointMaxLevel
                      : l10n.progressJointPoints(level.points, next),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: level.progress,
                minHeight: 6,
                backgroundColor: AppColors.softGrey,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
