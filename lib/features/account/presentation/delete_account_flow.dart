import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/account/domain/account_deletion_service.dart';
import 'package:muevete/features/account/presentation/account_providers.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// Asks twice before deleting the signed-in account: once to explain what is
/// lost, then to type a confirmation word (and the password, for email
/// accounts). Nothing is deleted if the user backs out at any point.
Future<void> startAccountDeletion(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final service = ref.read(accountDeletionServiceProvider);

  final proceed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('delete-account-warning'),
      title: Text(l10n.deleteAccountTitle),
      content: Text(l10n.deleteAccountBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          key: const ValueKey('delete-account-continue'),
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n.deleteAccountContinue),
        ),
      ],
    ),
  );
  if (proceed != true || !context.mounted) return;

  final needsPassword = service.reauthMethod == ReauthMethod.password;
  final password = await showDialog<String>(
    context: context,
    builder: (_) => _ConfirmDeletionDialog(needsPassword: needsPassword),
  );
  if (password == null || !context.mounted) return;

  await _runDeletion(
    context,
    ref,
    service,
    password: needsPassword ? password : null,
  );
}

Future<void> _runDeletion(
  BuildContext context,
  WidgetRef ref,
  AccountDeletionService service, {
  String? password,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final navigator = Navigator.of(context, rootNavigator: true);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        key: const ValueKey('delete-account-progress'),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(l10n.deleteAccountInProgress)),
          ],
        ),
      ),
    ),
  );

  void showMessage(String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));

  try {
    await service.deleteAccount(password: password);
    navigator.pop();
    showMessage(l10n.deleteAccountDone);
    router.go('/login');
  } on AccountDeletionCancelled {
    navigator.pop();
    showMessage(l10n.deleteAccountCancelled);
  } on AccountDeletionException catch (error) {
    navigator.pop();
    if (!error.isPartial) {
      showMessage(_nothingDeletedMessage(error, l10n));
      return;
    }
    if (!context.mounted) return;
    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        key: const ValueKey('delete-account-partial'),
        title: Text(l10n.deleteAccountPartialTitle),
        content: Text(l10n.deleteAccountPartialBody(privacyPolicyContactEmail)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.settingsLogOut),
          ),
          TextButton(
            key: const ValueKey('delete-account-retry'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAccountRetry),
          ),
        ],
      ),
    );
    if (retry == true && context.mounted) {
      await _runDeletion(context, ref, service, password: password);
    } else {
      await ref.read(authProvider.notifier).signOut();
      router.go('/login');
    }
  }
}

String _nothingDeletedMessage(
  AccountDeletionException error,
  AppLocalizations l10n,
) {
  final cause = error.cause;
  if (error.stage == AccountDeletionStage.reauthentication &&
      cause is FirebaseAuthException) {
    switch (cause.code) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'missing-password':
        return l10n.deleteAccountWrongPassword;
      case 'user-mismatch':
        return l10n.deleteAccountWrongAccount;
    }
  }
  return l10n.deleteAccountFailed;
}

/// Pops the typed password ('' when none is needed) once the confirmation
/// word matches, or null when cancelled.
class _ConfirmDeletionDialog extends StatefulWidget {
  const _ConfirmDeletionDialog({required this.needsPassword});

  final bool needsPassword;

  @override
  State<_ConfirmDeletionDialog> createState() => _ConfirmDeletionDialogState();
}

class _ConfirmDeletionDialogState extends State<_ConfirmDeletionDialog> {
  final _word = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _word.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _canConfirm(String expectedWord) =>
      _word.text.trim().toUpperCase() == expectedWord &&
      (!widget.needsPassword || _password.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expectedWord = l10n.deleteAccountWord;

    return AlertDialog(
      key: const ValueKey('delete-account-confirm'),
      title: Text(l10n.deleteAccountConfirmTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteAccountReauthNote),
            const SizedBox(height: 12),
            Text(l10n.deleteAccountTypeWord(expectedWord)),
            TextField(
              key: const ValueKey('delete-account-word'),
              controller: _word,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
            if (widget.needsPassword) ...[
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('delete-account-password'),
                controller: _password,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: l10n.deleteAccountPasswordHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          key: const ValueKey('delete-account-confirm-button'),
          onPressed: _canConfirm(expectedWord)
              ? () => Navigator.of(context).pop(_password.text)
              : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n.deleteAccountConfirmButton),
        ),
      ],
    );
  }
}
