import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/education/domain/tip_preferences.dart';
import 'package:muevete/features/education/presentation/providers/education_providers.dart';
import 'package:muevete/features/settings/presentation/widgets/settings_tile.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

String tipFrequencyLabel(AppLocalizations l10n, TipFrequency frequency) {
  return switch (frequency) {
    TipFrequency.daily => l10n.settingsTipsDaily,
    TipFrequency.everyOpen => l10n.settingsTipsEveryOpen,
    TipFrequency.off => l10n.settingsTipsOff,
  };
}

/// The Settings row that chooses how often Home shows a health tip.
class TipFrequencyTile extends ConsumerWidget {
  const TipFrequencyTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final frequency =
        ref.watch(tipPreferencesProvider).asData?.value.frequency ??
        TipPreferences.defaults.frequency;

    return SettingsTile(
      key: const ValueKey('settings-tips'),
      icon: Icons.lightbulb_outline_rounded,
      title: l10n.settingsTips,
      subtitle: tipFrequencyLabel(l10n, frequency),
      onTap: () async {
        final chosen = await showDialog<TipFrequency>(
          context: context,
          builder: (context) => _TipFrequencyDialog(current: frequency),
        );
        if (chosen != null && chosen != frequency) {
          await ref.read(tipPreferencesProvider.notifier).setFrequency(chosen);
        }
      },
    );
  }
}

class _TipFrequencyDialog extends StatelessWidget {
  const _TipFrequencyDialog({required this.current});

  final TipFrequency current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SimpleDialog(
      title: Text(l10n.settingsTips),
      children: [
        for (final frequency in TipFrequency.values)
          Semantics(
            selected: frequency == current,
            child: ListTile(
              key: ValueKey('tip-frequency-${frequency.name}'),
              title: Text(tipFrequencyLabel(l10n, frequency)),
              trailing: frequency == current
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryDark,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(frequency),
            ),
          ),
      ],
    );
  }
}
