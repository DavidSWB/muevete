import 'package:flutter/material.dart';
import 'package:muevete/features/profile/domain/entities/biological_sex.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// Male / Female choice used by sign-up and Edit Profile. Starts unselected
/// when [value] is null.
class BiologicalSexSelector extends StatelessWidget {
  const BiologicalSexSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final BiologicalSex? value;
  final ValueChanged<BiologicalSex> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              l10n.authSexLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<BiologicalSex>(
              key: const ValueKey('biological-sex-selector'),
              segments: [
                ButtonSegment(
                  value: BiologicalSex.male,
                  label: Text(l10n.sexMale),
                ),
                ButtonSegment(
                  value: BiologicalSex.female,
                  label: Text(l10n.sexFemale),
                ),
              ],
              selected: value == null ? const {} : {value!},
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              onSelectionChanged: enabled
                  ? (selection) {
                      if (selection.isNotEmpty) onChanged(selection.first);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
