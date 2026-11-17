import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/features/privacy/presentation/widgets/privacy_consent_checkbox.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
import 'package:muevete/shared/widgets/my_heading_two.dart';

/// Shown by the auth gate to a signed-in user whose profile has not accepted
/// the current mandatory policy version. The app stays here until they tick
/// both boxes (always unticked at first) and accept, or sign out.
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

  Future<void> _accept(PrivacyPolicyVersion policy) async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      // The gate moves on as soon as the profile shows the acceptance, so
      // this screen may be gone when the write finishes.
      await ref
          .read(privacyConsentRepositoryProvider)
          .acceptPolicy(policy.version);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loaded = ref.watch(currentPrivacyPolicyProvider).asData?.value;
    // Accepting an older text than the one required would not let the user
    // in, so ask them to retry instead of showing the boxes.
    final unavailableVersion = loaded?.unavailableVersion;
    final policy = unavailableVersion == null ? loaded?.policy : null;
    final languageCode = Localizations.localeOf(context).languageCode;
    // Ticks given for one version's text never carry over to another.
    ref.listen(currentPrivacyPolicyProvider, (previous, next) {
      if (previous?.asData?.value.policy.version !=
          next.asData?.value.policy.version) {
        setState(() {
          _policyAccepted = false;
          _healthDataAuthorized = false;
        });
      }
    });

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
                  if (policy != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        key: const ValueKey('privacy-consent-changes'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.privacyConsentChangesTitle(policy.version),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              policy.changeSummary.localizedWithCode(
                                languageCode,
                              ),
                              style: const TextStyle(
                                height: 1.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (unavailableVersion != null)
                    _PolicyUnavailable(
                      version: unavailableVersion,
                      onRetry: () => retryPrivacyPolicy(ref),
                    ),
                  if (_failed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Text(
                        l10n.privacyConsentSaveFailed,
                        key: const ValueKey('privacy-consent-error'),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  if (unavailableVersion == null)
                    PrivacyConsentCheckboxes(
                      policy: policy,
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
                    enabled:
                        policy != null &&
                        PrivacyConsentCheckboxes.complete(
                          policyAccepted: _policyAccepted,
                          healthDataAuthorized: _healthDataAuthorized,
                        ),
                    isLoading: _saving,
                    onTap: () {
                      if (policy != null) _accept(policy);
                    },
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

/// Shown instead of the checkboxes when the version the user must accept
/// is published but its text cannot be loaded right now.
class _PolicyUnavailable extends StatelessWidget {
  const _PolicyUnavailable({required this.version, required this.onRetry});

  final int version;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      key: const ValueKey('privacy-consent-unavailable'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.privacyPolicyNewerUnavailable(version),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          TextButton(
            key: const ValueKey('privacy-policy-retry'),
            onPressed: onRetry,
            child: Text(l10n.notifRetry),
          ),
        ],
      ),
    );
  }
}
