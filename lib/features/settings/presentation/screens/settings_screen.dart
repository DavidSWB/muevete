import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/features/settings/presentation/widgets/settings_tile.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: const [
          LocaleSwitcher(compact: true),
          SizedBox(width: 8),
        ],
      ),
      backgroundColor: AppColors.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsAccount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          SettingsTile(
            title: l10n.settingsEditProfile,
            onTap: () {
              context.push('/edit-profile');
            },
          ),

          SettingsTile(
            title: l10n.settingsNotifications,
            onTap: () {
              context.push('/notifications');
            },
          ),

          SettingsTile(
            title: l10n.settingsLanguage,
            onTap: () {
              context.push('/language');
            },
          ),

          SettingsTile(
            title: l10n.settingsChangeProgram,
            onTap: () {
              context.push('/program-setup');
            },
          ),

          const SizedBox(height: 16),
          SettingsTile(
            title: l10n.settingsLogOut,
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
