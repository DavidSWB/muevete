import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/features/privacy/presentation/widgets/privacy_consent_checkbox.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
import 'package:muevete/shared/widgets/my_heading_two.dart';

/// Shown by the auth gate to a signed-in user whose profile has not accepted
/// the current policy. The app stays here until they accept or sign out.
class PrivacyConsentScreen extends ConsumerStatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  ConsumerState<PrivacyConsentScreen> createState() =>
      _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends ConsumerState<PrivacyConsentScreen> {
  bool _policyAccepted = false;
  bool _healthDataAuthorized = false;
  bool _saving = false;
  bool _failed = false;

  Future<void> _accept() async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      // The gate moves on as soon as the profile shows the acceptance, so
      // this screen may be gone when the write finishes.
      await ref.read(privacyConsentRepositoryProvider).acceptCurrentPolicy();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    size: 48,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(height: 12),
                  MyHeadingTwo(text: l10n.privacyConsentTitle),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.privacyConsentBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_failed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Text(
                        l10n.privacyConsentSaveFailed,
                        key: const ValueKey('privacy-consent-error'),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  PrivacyConsentCheckboxes(
                    policyAccepted: _policyAccepted,
                    healthDataAuthorized: _healthDataAuthorized,
                    enabled: !_saving,
                    onPolicyChanged: (value) =>
                        setState(() => _policyAccepted = value),
                    onHealthDataChanged: (value) =>
                        setState(() => _healthDataAuthorized = value),
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    key: const ValueKey('privacy-consent-accept'),
                    text: l10n.privacyConsentAccept,
                    enabled: PrivacyConsentCheckboxes.complete(
                      policyAccepted: _policyAccepted,
                      healthDataAuthorized: _healthDataAuthorized,
                    ),
                    isLoading: _saving,
                    onTap: _accept,
                  ),
                  const SizedBox(height: 12),
                  MyButtonSecondarytext(
                    text: l10n.settingsLogOut,
                    onTap: () => ref.read(authProvider.notifier).signOut(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
