import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/education/presentation/widgets/tip_frequency_tile.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/settings/presentation/widgets/settings_tile.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_dialogs.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: const [
          WalkthroughAnchor(
            id: 'settings.language',
            child: LocaleSwitcher(compact: true),
          ),
          SizedBox(width: 8),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (profileAsync.asData?.value != null) ...[
            _ProfileSummaryCard(user: profileAsync.asData!.value),
            const SizedBox(height: 24),
          ],
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              l10n.settingsAccount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n.settingsEditProfile,
                  onTap: () => context.push('/edit-profile'),
                ),
                const Divider(indent: 68),
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.settingsNotifications,
                  onTap: () => context.push('/notifications'),
                ),
                const Divider(indent: 68),
                const TipFrequencyTile(),
                const Divider(indent: 68),
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: l10n.settingsLanguage,
                  onTap: () => context.push('/language'),
                ),
                const Divider(indent: 68),
                SettingsTile(
                  icon: Icons.fitness_center_rounded,
                  title: l10n.settingsChangeProgram,
                  onTap: () => context.push('/program-setup'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          WalkthroughAnchor(
            id: 'settings.replay',
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: SettingsTile(
                key: const ValueKey('settings-replay-tour'),
                icon: Icons.tour_outlined,
                title: l10n.settingsReplayTour,
                subtitle: l10n.settingsReplayTourSubtitle,
                onTap: () => startWalkthrough(
                  context,
                  ref.read(walkthroughControllerProvider.notifier),
                  ref.read(walkthroughControllerProvider),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: SettingsTile(
              icon: Icons.logout_rounded,
              title: l10n.settingsLogOut,
              isDestructive: true,
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final initial = user.username.trim().isNotEmpty
        ? user.username.trim()[0].toUpperCase()
        : 'M';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.cardBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (user.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
