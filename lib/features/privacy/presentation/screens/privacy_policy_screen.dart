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
          data: (policy) => _PolicyText(policy: policy),
        ),
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  const _PolicyText({required this.policy});

  final PrivacyPolicyVersion policy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
