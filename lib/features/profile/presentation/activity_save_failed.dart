import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';

/// Tells the user a completion was not saved and they can try again.
void showActivitySaveFailed(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      content: Text(
        l10n?.activitySaveFailed ?? 'Could not save. Please try again.',
      ),
    ),
  );
}
