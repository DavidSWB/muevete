import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
import 'package:muevete/shared/widgets/my_heading_two.dart';
import 'package:muevete/shared/widgets/my_textinputfield.dart';
import 'package:muevete/shared/widgets/social_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const int _minPasswordLength = 6;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? errorMessage;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateCredentials(
    String email,
    String password,
    AppLocalizations l10n,
  ) {
    if (email.isEmpty || password.isEmpty) {
      return l10n.valEmptyEmailPassword;
    }
    if (password.length < _minPasswordLength) {
      return l10n.valPasswordMinLength;
    }
    if (!email.contains('@') || !email.contains('.')) {
      return l10n.valInvalidEmail;
    }
    return null;
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final validationError = _validateCredentials(email, password, l10n);
    if (validationError != null) {
      setState(() => errorMessage = validationError);
      return;
    }

    setState(() {
      errorMessage = null;
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signIn(
            email: email,
            password: password,
          );
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => errorMessage = _mapFirebaseError(e, l10n));
    } catch (_) {
      if (mounted) {
        setState(
          () => errorMessage = AppLocalizations.of(context)!.errUnexpected,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await _runSocialSignIn(
      onStart: () => _isGoogleLoading = true,
      onComplete: () => _isGoogleLoading = false,
      action: () => ref.read(authProvider.notifier).signInWithGoogle(),
    );
  }

  Future<void> _handleAppleSignIn() async {
    await _runSocialSignIn(
      onStart: () => _isAppleLoading = true,
      onComplete: () => _isAppleLoading = false,
      action: () => ref.read(authProvider.notifier).signInWithApple(),
    );
  }

  Future<void> _runSocialSignIn({
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required Future<bool> Function() action,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      errorMessage = null;
      onStart();
    });
    try {
      final success = await action();
      if (!success && mounted) {
        setState(() => errorMessage = l10n.errSignInCancelled);
      } else if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => errorMessage = _mapFirebaseError(e, l10n));
    } catch (_) {
      if (mounted) setState(() => errorMessage = l10n.errUnexpected);
    } finally {
      if (mounted) setState(onComplete);
    }
  }

  String _mapFirebaseError(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.errInvalidCredentials;
      case 'invalid-email':
        return l10n.errInvalidEmailFormat;
      case 'user-disabled':
        return l10n.errUserDisabled;
      case 'too-many-requests':
        return l10n.errTooManyRequests;
      case 'network-request-failed':
        return l10n.errNetwork;
      case 'account-exists-with-different-credential':
        return l10n.errAccountExistsOtherProvider;
      default:
        return e.message ?? l10n.errAuthFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAnyLoading = _isLoading || _isGoogleLoading || _isAppleLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LocaleSwitcher(compact: true),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.cardBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 32,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 20),
                MyHeadingTwo(text: l10n.authLogin),
                const SizedBox(height: 20),

                if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                  _AuthErrorBanner(message: errorMessage!),
                  const SizedBox(height: 16),
                ],

                MyTextinputfield(
                  controller: _emailController,
                  hintText: l10n.authEmailHint,
                  prefixIcon: Icons.email_outlined,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _passwordController,
                  hintText: l10n.authPasswordHint,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                MyButton(
                  text: l10n.authEnter,
                  onTap: _handleLogin,
                  enabled: !isAnyLoading,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          l10n.authOrDivider,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SocialSignInButton(
                  label: l10n.authSignInWithGoogle,
                  isLoading: _isGoogleLoading,
                  onTap: isAnyLoading ? null : _handleGoogleSignIn,
                  iconWidget: Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.login, size: 22),
                  ),
                ),
                const SizedBox(height: 12),

                if (Platform.isIOS) ...[
                  SocialSignInButton(
                    label: l10n.authSignInWithApple,
                    isLoading: _isAppleLoading,
                    onTap: isAnyLoading ? null : _handleAppleSignIn,
                    iconWidget: const Icon(
                      Icons.apple,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 4),
                MyButtonSecondarytext(
                  text: l10n.authCreateAccountPrompt,
                  onTap: () => context.go('/signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
