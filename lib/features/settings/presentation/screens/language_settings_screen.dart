import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/localization/presentation/locale_provider.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  Future<void> _selectLanguage(BuildContext context, WidgetRef ref, Locale locale) async {
    await ref.read(localeProvider.notifier).setLocale(locale);

    try {
      final user = await ref.read(profileProvider.future);
      await NotificationScheduler.rescheduleAll(
        user,
        force: true,
        locale: locale,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    final languages = [
      {'locale': const Locale('es'), 'label': l10n.languageSpanish, 'native': 'Español'},
      {'locale': const Locale('en'), 'label': l10n.languageEnglish, 'native': 'English'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageTitle),
        elevation: 0,
      ),
      backgroundColor: AppColors.surface,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: languages.asMap().entries.map((entry) {
                final index = entry.key;
                final lang = entry.value;
                final locale = lang['locale'] as Locale;
                final isSelected = currentLocale.languageCode == locale.languageCode;

                return Column(
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: index == 0 ? const Radius.circular(16) : Radius.zero,
                          bottom: index == languages.length - 1
                              ? const Radius.circular(16)
                              : Radius.zero,
                        ),
                      ),
                      title: Text(
                        lang['label'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primaryDark : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        lang['native'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : const Icon(Icons.radio_button_unchecked, color: AppColors.textMuted),
                      onTap: () => _selectLanguage(context, ref, locale),
                    ),
                    if (index < languages.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
