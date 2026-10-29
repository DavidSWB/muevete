import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/education/presentation/widgets/daily_tip_card.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/services/weekly_activity.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/services/training_schedule_service.dart';
import 'package:muevete/features/training/presentation/providers/next_training_provider.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/screens/error_screen.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// The current time as Home sees it; tests override it to fix the date.
final homeClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const int _estimatedMinutesPerSession = 35;
  static const int _defaultWeeklyGoalSessions = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);
    final nextTraining = ref.watch(nextTrainingProvider);

    return profile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorScreen(
        l10n.homeCouldNotLoadProfile,
        onRetry: () => ref.invalidate(profileProvider),
        retryLabel: l10n.notifRetry,
      ),
      data: (user) {
        void openTab(int index) {
          HapticFeedback.lightImpact();
          ref.read(mainNavIndexProvider.notifier).setIndex(index);
        }

        const schedule = TrainingScheduleService();
        final now = ref.read(homeClockProvider)();
        final isRestDay = schedule.isRestDay(user: user, now: now);
        final doneEarly =
            !isRestDay && schedule.wasDoneEarly(user: user, now: now);

        final completedThisWeek = countThisWeek(user.completedWorkouts, now);
        final plannedDaysPerWeek =
            user.training!.schedule?.days.length ?? _defaultWeeklyGoalSessions;
        final targetSessions = plannedDaysPerWeek > 0
            ? plannedDaysPerWeek
            : _defaultWeeklyGoalSessions;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeGreetingHeader(
                  username: user.username,
                  activeBreaksThisWeek: countThisWeek(
                    user.completedActiveBreaks,
                    now,
                  ),
                  onAvatarTap: () => openTab(MainScreen.settingsTab),
                ),
                const SizedBox(height: 22),
                const DailyTipSlot(),
                _NextWorkoutHeroCard(
                  user: user,
                  nextTraining: nextTraining,
                  isRestDay: isRestDay,
                  doneEarly: doneEarly,
                  onStartWorkout: () => openTab(MainScreen.trainingTab),
                  onActiveBreak: () {
                    HapticFeedback.lightImpact();
                    context.push('/active-breaks');
                  },
                ),
                const SizedBox(height: 18),
                WalkthroughAnchor(
                  id: 'home.weeklyStats',
                  child: _WeeklyStatsRow(
                    completedSessions: completedThisWeek,
                    targetSessions: targetSessions,
                    minutesTrained:
                        completedThisWeek * _estimatedMinutesPerSession,
                    targetMinutes: targetSessions * _estimatedMinutesPerSession,
                    onTap: () => openTab(MainScreen.progressTab),
                  ),
                ),
                const SizedBox(height: 26),
                const _ActiveBreaksSection(),
                const SizedBox(height: 18),
                WalkthroughAnchor(
                  id: 'home.health',
                  child: _HealthInsightCard(
                    onTap: () => openTab(MainScreen.progressTab),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeGreetingHeader extends StatelessWidget {
  const _HomeGreetingHeader({
    required this.username,
    required this.activeBreaksThisWeek,
    required this.onAvatarTap,
  });

  final String username;
  final int activeBreaksThisWeek;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final initial = username.trim().isNotEmpty
        ? username.trim()[0].toUpperCase()
        : 'A';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeGreeting(username),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              _WeeklyBreakGoal(count: activeBreaksThisWeek),
            ],
          ),
        ),
        const SizedBox(width: 12),
        WalkthroughAnchor(
          id: 'home.profile',
          child: InkWell(
            onTap: onAvatarTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Progress toward [weeklyActiveBreakGoal] this week, as a small ring. The
/// count keeps going past the goal; the ring turns green once it is met.
class _WeeklyBreakGoal extends StatelessWidget {
  const _WeeklyBreakGoal({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const goal = weeklyActiveBreakGoal;
    final reached = count >= goal;
    final color = reached ? AppColors.success : AppColors.primaryDark;

    return Semantics(
      key: const ValueKey('home-weekly-break-goal'),
      container: true,
      label: l10n.homeWeeklyBreaksLabel(count, goal),
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: math.min(count / goal, 1.0),
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.softGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Icon(
                  reached
                      ? Icons.check_rounded
                      : Icons.self_improvement_rounded,
                  size: 20,
                  color: color,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.homeWeeklyBreaksCount(count, goal),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.homeWeeklyBreaksCaption,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextWorkoutHeroCard extends StatelessWidget {
  const _NextWorkoutHeroCard({
    required this.user,
    required this.nextTraining,
    required this.isRestDay,
    required this.doneEarly,
    required this.onStartWorkout,
    required this.onActiveBreak,
  });

  final UserModel user;
  final AsyncValue<PlanDay> nextTraining;

  /// Shows the light-day message and its two actions instead of the session.
  final bool isRestDay;

  /// Today's session was already done on a rest day.
  final bool doneEarly;

  /// Opens the Training tab, which shows today's or the next session.
  final VoidCallback onStartWorkout;
  final VoidCallback onActiveBreak;

  String _resolveLevelLabel(BuildContext context, double? overallLevel) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    if (overallLevel == null || overallLevel < 2.2) {
      return isSpanish ? 'Principiante' : 'Beginner';
    }
    if (overallLevel < 3.8) {
      return isSpanish ? 'Intermedio' : 'Intermediate';
    }
    return isSpanish ? 'Avanzado' : 'Advanced';
  }

  int _resolveDurationMinutes(PlanDay? day) {
    if (day == null || day.exercises.isEmpty) return 35;
    final estimated = day.exercises.length * 7;
    return estimated.clamp(20, 60);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final badgeText =
        isRestDay ? l10n.homeRestDayBadge : l10n.homeTodayWorkoutBadge;
    final descriptionText = isRestDay
        ? l10n.homeRestDayDescription
        : l10n.homeWorkoutDescription;

    final planDay = nextTraining.asData?.value;
    final workoutTitle = isRestDay
        ? l10n.homeRestDayTitle
        : nextTraining.when(
            loading: () => '...',
            error: (_, __) => 'Full Body A',
            data: (day) => day.name.localized(context, fallback: 'Full Body A'),
          );
    final durationMinutes = _resolveDurationMinutes(planDay);
    final levelLabel = _resolveLevelLabel(context, user.stats?.overallLevel);

    return Container(
      key: const ValueKey('home-workout-card'),
      // Full width, so the card doesn't shrink to its text and leave an empty
      // strip beside it.
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF8FF), Color(0xFFDDF0FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const Positioned(
              right: -28,
              bottom: -24,
              child: _WorkoutHeroIllustration(),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EEFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    workoutTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (!isRestDay) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _HeroMeta(
                          icon: Icons.access_time_rounded,
                          label: '$durationMinutes min',
                          tabularFigures: true,
                        ),
                        _HeroMeta(
                          icon: Icons.bar_chart_rounded,
                          label: levelLabel,
                        ),
                        if (doneEarly)
                          _HeroMeta(
                            key: const ValueKey('home-done-early'),
                            icon: Icons.check_circle_rounded,
                            iconColor: AppColors.success,
                            label: l10n.homeDoneEarly,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 215),
                    child: Text(
                      descriptionText,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isRestDay)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroPillButton(
                            key: const ValueKey('home-rest-active-break'),
                            label: l10n.homeRestDayActiveBreak,
                            onTap: onActiveBreak,
                          ),
                          const SizedBox(height: 10),
                          // Same destination as the training-day CTA, so the
                          // tour step on it works on rest days too.
                          WalkthroughAnchor(
                            id: 'home.startWorkout',
                            child: _HeroPillButton(
                              key: const ValueKey('home-rest-advance'),
                              label: l10n.homeRestDayAdvance,
                              onTap: onStartWorkout,
                              outlined: true,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    WalkthroughAnchor(
                      id: 'home.startWorkout',
                      child: _HeroPillButton(
                        label: l10n.homeStartWorkoutCta,
                        onTap: onStartWorkout,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppColors.textMuted,
    this.tabularFigures = false,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final bool tabularFigures;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            fontFeatures:
                tabularFigures ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
      ],
    );
  }
}

/// The hero card's pill action. Filled is the card's primary action;
/// [outlined] marks a secondary one beside it.
class _HeroPillButton extends StatelessWidget {
  const _HeroPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.textAlign = TextAlign.start,
  });

  static const Color _blue = Color(0xFF0077C2);

  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final foreground = outlined ? _blue : Colors.white;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
      side: outlined
          ? const BorderSide(color: _blue, width: 1.5)
          : BorderSide.none,
    );

    return Material(
      color: outlined ? Colors.white : _blue,
      shape: shape,
      elevation: outlined ? 0 : 2,
      shadowColor: _blue.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: textAlign,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Icon(Icons.arrow_forward_rounded, color: foreground, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutHeroIllustration extends StatelessWidget {
  const _WorkoutHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFCCE7FF).withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            right: 22,
            bottom: 24,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: const Color(0xFFB8DFFF).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Rolled fitness mat
          Positioned(
            right: 16,
            bottom: 58,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: 72,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          // Sport water bottle
          Positioned(
            right: 52,
            bottom: 62,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0369A1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  width: 28,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Hexagonal dumbbell in foreground
          Positioned(
            left: 36,
            bottom: 42,
            child: Transform.rotate(
              angle: math.pi / 7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 8,
                    color: const Color(0xFF64748B),
                  ),
                  Container(
                    width: 18,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStatsRow extends StatelessWidget {
  const _WeeklyStatsRow({
    required this.completedSessions,
    required this.targetSessions,
    required this.minutesTrained,
    required this.targetMinutes,
    required this.onTap,
  });

  final int completedSessions;
  final int targetSessions;
  final int minutesTrained;
  final int targetMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final sessionsTitle = isSpanish
        ? 'Sesiones\ncompletadas'
        : 'Completed\nsessions';
    final timeTitle = isSpanish ? 'Tiempo entrenado\n' : 'Time trained\n';
    final weekSubtitle = isSpanish ? 'Esta semana' : 'This week';

    final sessionProgress = (completedSessions / targetSessions).clamp(
      0.0,
      1.0,
    );
    final timeProgress = (minutesTrained / targetMinutes).clamp(0.0, 1.0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _WeeklyStatCard(
              icon: Icons.check_rounded,
              badgeColor: const Color(0xFF10B981),
              title: sessionsTitle,
              subtitle: weekSubtitle,
              value: '$completedSessions',
              progress: sessionProgress,
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _WeeklyStatCard(
              icon: Icons.access_time_rounded,
              badgeColor: const Color(0xFF0077C2),
              title: timeTitle,
              subtitle: weekSubtitle,
              value: '$minutesTrained',
              unit: 'min',
              progress: timeProgress,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStatCard extends StatelessWidget {
  const _WeeklyStatCard({
    required this.icon,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.progress,
    required this.onTap,
    this.unit,
  });

  final IconData icon;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final String value;
  final String? unit;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        unit!,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthInsightCard extends StatelessWidget {
  const _HealthInsightCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final title = isSpanish
        ? 'Tu salud también cuenta'
        : 'Your health matters too';
    final description = isSpanish
        ? 'Mantenerte activo mejora tu energía, tu estado de ánimo y tu bienestar.'
        : 'Staying active boosts your energy, mood, and overall wellbeing.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveBreaksSection extends StatelessWidget {
  const _ActiveBreaksSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final sectionTitle = isSpanish
        ? 'Muévete también durante el día'
        : 'Keep moving throughout the day';
    final sectionSubtitle = isSpanish
        ? 'Pequeñas rutinas, grandes resultados.'
        : 'Small routines, big results.';
    final cardDescription = isSpanish
        ? 'Rutinas cortas para estirar\ny recargar energía.'
        : l10n.homeActiveBreaksDesc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sectionSubtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        WalkthroughAnchor(
          id: 'home.activeBreaks',
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/active-breaks');
                },
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.directions_walk_rounded,
                          size: 28,
                          color: Color(0xFF0077C2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeActiveBreaks,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cardDescription,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
