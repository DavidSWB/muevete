import 'package:flutter/material.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_copy.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// The card that explains the current step.
///
/// Informational steps get Previous and Next (Got it on the last step).
/// Gated steps get Previous and a hint to use the highlighted control; they
/// never get Next, because only the real action may move the tour on.
class WalkthroughCoachCard extends StatelessWidget {
  const WalkthroughCoachCard({
    super.key,
    required this.state,
    required this.targetMissing,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onRetry,
  });

  final WalkthroughState state;

  /// The step points at something that is not on screen.
  final bool targetMissing;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final step = state.step;
    final (title, body) = walkthroughStepCopy(l10n, step.id);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      key: const ValueKey('walkthrough-card'),
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.tourStepCounter(state.stepNumber, state.stepCount),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('walkthrough-close'),
                  tooltip: l10n.tourClose,
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textMuted,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  if (targetMissing) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.tourTargetMissing,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _Actions(
                state: state,
                targetMissing: targetMissing,
                onPrevious: onPrevious,
                onNext: onNext,
                onRetry: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.state,
    required this.targetMissing,
    required this.onPrevious,
    required this.onNext,
    required this.onRetry,
  });

  final WalkthroughState state;
  final bool targetMissing;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gated = state.step.isGated;

    final Widget forward;
    if (gated && targetMissing) {
      forward = FilledButton(
        key: const ValueKey('walkthrough-retry'),
        onPressed: onRetry,
        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
        child: Text(l10n.tourTryAgain),
      );
    } else if (gated) {
      forward = Flexible(
        child: Text(
          state.halfwayReached ? l10n.tourOneMoreBack : l10n.tourTapHighlighted,
          key: const ValueKey('walkthrough-hint'),
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      forward = FilledButton(
        key: const ValueKey('walkthrough-next'),
        onPressed: onNext,
        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryDark),
        child: Text(state.isLastStep ? l10n.tourDone : l10n.tourNext),
      );
    }

    return Row(
      children: [
        TextButton(
          key: const ValueKey('walkthrough-previous'),
          onPressed: state.canGoBack ? onPrevious : null,
          child: Text(l10n.tourPrevious),
        ),
        const SizedBox(width: 8),
        const Spacer(),
        forward,
      ],
    );
  }
}
