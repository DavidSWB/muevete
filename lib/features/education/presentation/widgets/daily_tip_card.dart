import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/education/domain/educational_message.dart';
import 'package:muevete/features/education/presentation/providers/education_providers.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a tip's source; returns whether it opened. Replaced in tests.
final tipLinkOpenerProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Home's health tip, followed by [spacing]. Takes no room while there is
/// no tip, while it loads, if it fails to load, or while the tour runs.
class DailyTipSlot extends ConsumerWidget {
  const DailyTipSlot({super.key, this.spacing = 18});

  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourActive = ref.watch(
      walkthroughControllerProvider.select((state) => state.isActive),
    );
    final tip = ref.watch(dailyTipProvider).asData?.value;
    if (tourActive || tip == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: DailyTipCard(
        message: tip,
        onDismiss: () =>
            ref.read(tipDismissedThisSessionProvider.notifier).dismiss(tip),
      ),
    );
  }
}

class DailyTipCard extends ConsumerWidget {
  const DailyTipCard({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  final EducationalMessage message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isEvidence = message.type == EducationalMessageType.evidence;
    final label = isEvidence ? l10n.tipTypeEvidence : l10n.tipTypeTip;
    final source = message.sourceLabel.localized(context);

    return Container(
      key: ValueKey('daily-tip-${message.messageId}'),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEvidence
                    ? Icons.menu_book_outlined
                    : Icons.lightbulb_outline_rounded,
                size: 18,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('daily-tip-dismiss'),
                tooltip: l10n.tipDismiss,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textMuted,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDismiss();
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              message.text.localized(context),
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            link: true,
            label: l10n.tipOpenSource(source),
            excludeSemantics: true,
            child: InkWell(
              key: const ValueKey('daily-tip-source'),
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openSource(context, ref, l10n),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  l10n.tipSource(source),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryDark,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSource(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final uri = Uri.parse(message.sourceUrl.localized(context));
    var opened = false;
    try {
      opened = await ref.read(tipLinkOpenerProvider)(uri);
    } catch (error) {
      debugPrint('Could not open the tip source: $error');
    }
    if (!opened) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.tipSourceFailed)));
    }
  }
}
