import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// The two consents the app asks for: the policy itself and, separately, the
/// express authorization for health data. Both start unchecked; the caller
/// keeps the values and refuses to continue until both are true.
class PrivacyConsentCheckboxes extends StatelessWidget {
  const PrivacyConsentCheckboxes({
    super.key,
    required this.policyAccepted,
    required this.healthDataAuthorized,
    required this.onPolicyChanged,
    required this.onHealthDataChanged,
    this.enabled = true,
  });

  final bool policyAccepted;
  final bool healthDataAuthorized;
  final ValueChanged<bool> onPolicyChanged;
  final ValueChanged<bool> onHealthDataChanged;
  final bool enabled;

  /// True when the user gave both consents.
  static bool complete({
    required bool policyAccepted,
    required bool healthDataAuthorized,
  }) => policyAccepted && healthDataAuthorized;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConsentRow(
            checkboxKey: const ValueKey('privacy-consent-checkbox'),
            value: policyAccepted,
            text: l10n.privacyConsentCheckbox,
            enabled: enabled,
            onChanged: onPolicyChanged,
          ),
          _ConsentRow(
            checkboxKey: const ValueKey('privacy-health-checkbox'),
            value: healthDataAuthorized,
            text: l10n.privacyHealthConsentCheckbox,
            enabled: enabled,
            onChanged: onHealthDataChanged,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: TextButton(
              key: const ValueKey('privacy-read-policy'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: AppColors.primaryDark,
              ),
              onPressed: () => context.push('/privacy-policy'),
              child: Text(l10n.privacyReadPolicy),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.checkboxKey,
    required this.value,
    required this.text,
    required this.enabled,
    required this.onChanged,
  });

  final Key checkboxKey;
  final bool value;
  final String text;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          key: checkboxKey,
          value: value,
          onChanged: enabled ? (checked) => onChanged(checked ?? false) : null,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: enabled ? () => onChanged(!value) : null,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
