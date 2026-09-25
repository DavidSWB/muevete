import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/settings/presentation/widgets/settings_tile.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      backgroundColor: AppColors.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          SettingsTile(
            title: 'Edit Profile',
            onTap: () {
              context.push('/edit-profile');
            },
          ),

          SettingsTile(
            title: 'Notifications',
            onTap: () {
              context.push('/notifications');
            },
          ),

          SettingsTile(
            title: 'Language',
            onTap: () {
              context.push('/language');
            },
          ),

          const SizedBox(height: 16),
          SettingsTile(
            title: 'Log Out',
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