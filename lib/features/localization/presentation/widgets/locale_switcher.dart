import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/localization/presentation/locale_provider.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class LocaleSwitcher extends ConsumerWidget {
  const LocaleSwitcher({
    super.key,
    this.compact = false,
  });

  final bool compact;

  Future<void> _changeLocale(WidgetRef ref, Locale newLocale) async {
    await ref.read(localeProvider.notifier).setLocale(newLocale);

    // If a user profile is active, refresh notifications with the new locale translations
    try {
      final user = await ref.read(profileProvider.future);
      await NotificationScheduler.rescheduleAll(
        user,
        force: true,
        locale: newLocale,
      );
    } catch (_) {
      // User might not be logged in yet
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isEs = currentLocale.languageCode == 'es';

    if (compact) {
      return IconButton(
        tooltip: isEs ? 'Cambiar a inglés' : 'Switch to Spanish',
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            isEs ? 'ES' : 'EN',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        onPressed: () {
          final next = isEs ? const Locale('en') : const Locale('es');
          _changeLocale(ref, next);
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.softGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageSegment(
            label: 'ES',
            selected: isEs,
            onTap: () => _changeLocale(ref, const Locale('es')),
          ),
          const SizedBox(width: 4),
          _LanguageSegment(
            label: 'EN',
            selected: !isEs,
            onTap: () => _changeLocale(ref, const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _LanguageSegment extends StatelessWidget {
  const _LanguageSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
