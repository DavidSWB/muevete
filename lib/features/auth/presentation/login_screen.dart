import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
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

  // ─── Email / Password ──────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = l10n.valEmptyEmailPassword);
      return;
    }
    if (password.length < 6) {
      setState(() => errorMessage = l10n.valPasswordMinLength);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => errorMessage = l10n.valInvalidEmail);
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
        setState(() => errorMessage = AppLocalizations.of(context)!.errUnexpected);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Google ────────────────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      errorMessage = null;
      _isGoogleLoading = true;
    });
    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();
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
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ─── Apple ─────────────────────────────────────────────────────────────────

  Future<void> _handleAppleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      errorMessage = null;
      _isAppleLoading = true;
    });
    try {
      final success = await ref.read(authProvider.notifier).signInWithApple();
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
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  // ─── Error mapping ─────────────────────────────────────────────────────────

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

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAnyLoading = _isLoading || _isGoogleLoading || _isAppleLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyHeadingTwo(text: l10n.authLogin),
                const SizedBox(height: 24),

                // Error message
                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),

                // Email field
                MyTextinputfield(
                  controller: _emailController,
                  hintText: l10n.authEmailHint,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password field
                MyTextinputfield(
                  controller: _passwordController,
                  hintText: l10n.authPasswordHint,
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // Email / Password button
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  MyButton(
                    text: l10n.authEnter,
                    onTap: isAnyLoading ? () {} : _handleLogin,
                    enabled: !isAnyLoading,
                  ),
                const SizedBox(height: 20),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          l10n.authOrDivider,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Google button
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

                // Apple button – iOS only
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

                // Create account link
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