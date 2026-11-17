import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// Home's notice after a minor policy update, followed by [spacing]. Takes
/// no room when there is nothing to announce. It never blocks the app and
/// never counts as accepting the new version.
class PrivacyPolicyNoticeSlot extends ConsumerWidget {
  const PrivacyPolicyNoticeSlot({super.key, this.spacing = 18});

  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(privacyPolicyNoticeProvider).asData?.value;
    if (version == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    Future<void> dismiss() async {
      final uid = ref.read(profileProvider).asData?.value.id;
      if (uid != null) {
        await ref.read(policyNoticeStoreProvider).dismiss(uid, version);
      }
      ref.invalidate(privacyPolicyNoticeProvider);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Container(
        key: const ValueKey('privacy-policy-notice'),
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.privacyNoticeText,
                    style: const TextStyle(
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                children: [
                  TextButton(
                    key: const ValueKey('privacy-policy-notice-view'),
                    onPressed: () => context.push('/privacy-policy'),
                    child: Text(l10n.privacyNoticeView),
                  ),
                  TextButton(
                    key: const ValueKey('privacy-policy-notice-dismiss'),
                    onPressed: dismiss,
                    child: Text(l10n.privacyNoticeDismiss),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
