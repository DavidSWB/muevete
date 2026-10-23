import 'package:flutter/material.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_steps.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';

enum WalkthroughInviteChoice { start, later, never }

/// Asks a user who has not finished the tour whether they want it now.
/// "Not now" or closing the dialog asks again on a later launch; only
/// "Never ask again" stops it, and says the tour stays in Settings.
Future<void> offerWalkthrough(
  BuildContext context,
  WalkthroughController controller,
  WalkthroughState state,
) async {
  final l10n = AppLocalizations.of(context)!;
  final choice = await showDialog<WalkthroughInviteChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.tourInviteTitle),
      content: Text(l10n.tourInviteBody),
      actionsOverflowDirection: VerticalDirection.up,
      actionsOverflowButtonSpacing: 4,
      actions: [
        TextButton(
          key: const ValueKey('walkthrough-invite-never'),
          onPressed: () =>
              Navigator.of(context).pop(WalkthroughInviteChoice.never),
          child: Text(l10n.tourInviteNever),
        ),
        TextButton(
          key: const ValueKey('walkthrough-invite-later'),
          onPressed: () =>
              Navigator.of(context).pop(WalkthroughInviteChoice.later),
          child: Text(l10n.tourInviteLater),
        ),
        FilledButton(
          key: const ValueKey('walkthrough-invite-start'),
          onPressed: () =>
              Navigator.of(context).pop(WalkthroughInviteChoice.start),
          child: Text(l10n.tourInviteStart),
        ),
      ],
    ),
  );

  switch (choice) {
    case WalkthroughInviteChoice.start:
      if (context.mounted) await startWalkthrough(context, controller, state);
    case WalkthroughInviteChoice.never:
      controller.decline();
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(l10n.tourInviteNeverConfirm)));
      }
    case WalkthroughInviteChoice.later || null:
      break;
  }
}

/// Starts the tour. When an earlier tour was closed part way, asks whether
/// to continue it or start over; closing that dialog starts nothing.
Future<void> startWalkthrough(
  BuildContext context,
  WalkthroughController controller,
  WalkthroughState state,
) async {
  if (!state.canResume || !context.mounted) {
    controller.start();
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final savedIndex = walkthroughStepIndex(state.saved!.stepId);
  final resume = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.tourResumeTitle),
      content: Text(l10n.tourResumeBody(savedIndex + 1, state.stepCount)),
      actions: [
        TextButton(
          key: const ValueKey('walkthrough-start-over'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.tourStartOver),
        ),
        FilledButton(
          key: const ValueKey('walkthrough-resume'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.tourResume),
        ),
      ],
    ),
  );

  switch (resume) {
    case true:
      controller.resume();
    case false:
      controller.start();
    case null:
      break;
  }
}
