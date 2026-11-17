import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.watch(currentPrivacyPolicyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPrivacyPolicy)),
      body: SafeArea(
        child: policy.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.privacyPolicyLoadFailed,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (loaded) => _PolicyText(
            loaded: loaded,
            onRetry: () => retryPrivacyPolicy(ref),
          ),
        ),
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  const _PolicyText({required this.loaded, required this.onRetry});

  final LoadedPrivacyPolicy loaded;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final policy = loaded.policy;
    final unavailableVersion = loaded.unavailableVersion;
    final sourceNote = switch (loaded.source) {
      PolicySource.server => null,
      PolicySource.cache => l10n.privacyPolicySavedCopy(policy.version),
      PolicySource.bundled => l10n.privacyPolicyBundledCopy(policy.version),
    };
    final locale = Localizations.localeOf(context);
    final effectiveFrom = DateFormat.yMMMMd(
      locale.toLanguageTag(),
    ).format(policy.effectiveFrom);

    return ListView(
      key: const ValueKey('privacy-policy-list'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          l10n.privacyPolicyTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.privacyPolicyVersionLabel(policy.version, effectiveFrom),
          key: const ValueKey('privacy-policy-version'),
          style: const TextStyle(color: AppColors.textMuted),
        ),
        if (sourceNote != null || unavailableVersion != null) ...[
          const SizedBox(height: 12),
          Container(
            key: const ValueKey('privacy-policy-source-note'),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sourceNote != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(sourceNote),
                  ),
                if (unavailableVersion != null)
                  Text(l10n.privacyPolicyNewerUnavailable(unavailableVersion)),
                TextButton(
                  key: const ValueKey('privacy-policy-retry'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: onRetry,
                  child: Text(l10n.notifRetry),
                ),
              ],
            ),
          ),
        ],
        for (final section in policy.sectionsFor(locale.languageCode)) ...[
          const SizedBox(height: 20),
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          for (final block in section.blocks)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: block.type == PolicyBlockType.bullet
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '• ${block.text}',
                        style: const TextStyle(
                          height: 1.45,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : Text(
                      block.text,
                      style: const TextStyle(
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
        ],
      ],
    );
  }
}
