import 'package:flutter/material.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/features/privacy/presentation/privacy_policy_content.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = privacyPolicySections(
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPrivacyPolicy)),
      body: SafeArea(
        child: ListView(
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
              l10n.privacyPolicyVersionLabel(currentPrivacyPolicyVersion),
              style: const TextStyle(color: AppColors.textMuted),
            ),
            for (final section in sections) ...[
              const SizedBox(height: 20),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              for (final paragraph in section.paragraphs)
                Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: paragraph.startsWith('• ') ? 8 : 0,
                  ),
                  child: Text(
                    paragraph,
                    style: const TextStyle(
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
