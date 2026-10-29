import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/gamification/presentation/medal_case_section.dart';
import 'package:muevete/features/gamification/presentation/movement_progress_section.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/progress/presentation/widgets/progress_calendar.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/screens/error_screen.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profile.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => ErrorScreen(
            l10n.errGeneric(err.toString()),
            onRetry: () => ref.invalidate(profileProvider),
            retryLabel: l10n.notifRetry,
          ),
          data: (user) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.progressTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${user.completedWorkouts.length}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  WalkthroughAnchor(
                    id: 'progress.calendar',
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProgressCalendar(
                          completedWorkouts: user.completedWorkouts,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  WalkthroughAnchor(
                    id: 'progress.jointStats',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.progressMobilityStats,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: l10n.progressShoulder,
                                value: user.stats?.shoulder ?? 0,
                                icon: Icons.accessibility_new_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: l10n.progressHip,
                                value: user.stats?.hip ?? 0,
                                icon: Icons.directions_walk_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: l10n.progressKnee,
                                value: user.stats?.knee ?? 0,
                                icon: Icons.directions_run_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: l10n.progressAnkle,
                                value: user.stats?.ankle ?? 0,
                                icon: Icons.do_not_step_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  WalkthroughAnchor(
                    id: 'progress.retake',
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push('/diagnosis');
                        },
                        icon: const Icon(Icons.assignment_outlined, size: 20),
                        label: Text(l10n.progressRetake),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  MovementProgressSection(user: user),
                  const SizedBox(height: 28),
                  MedalCaseSection(user: user),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  static const double _maxMobilityLevel = 5.0;

  final String title;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = (value / _maxMobilityLevel).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cardBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatValue(value),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/ 5',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalizedProgress,
              minHeight: 6,
              backgroundColor: AppColors.softGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatValue(double value) {
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
