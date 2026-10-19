import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/shared/widgets/my_button.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
import 'package:muevete/shared/widgets/my_heading_two.dart';
import 'package:muevete/shared/widgets/my_textinputfield.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = l10n.valEmptyEmailPassword;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = l10n.valPasswordMinLength;
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        errorMessage = l10n.valInvalidEmail;
      });
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

      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = l10n.errInvalidCredentials;
          break;
        case 'invalid-email':
          message = l10n.errInvalidEmailFormat;
          break;
        case 'user-disabled':
          message = l10n.errUserDisabled;
          break;
        case 'too-many-requests':
          message = l10n.errTooManyRequests;
          break;
        case 'network-request-failed':
          message = l10n.errNetwork;
          break;
        default:
          message = e.message ?? l10n.errAuthFailed;
      }

      if (mounted) {
        setState(() {
          errorMessage = message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage = l10n.errUnexpected;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LocaleSwitcher(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyHeadingTwo(text: l10n.authLogin),
                const SizedBox(height: 24),
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
                MyTextinputfield(
                  controller: _emailController,
                  hintText: l10n.authEmailHint,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                MyTextinputfield(
                  controller: _passwordController,
                  hintText: l10n.authPasswordHint,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  MyButton(
                    text: l10n.authEnter,
                    onTap: handleLogin,
                  ),
                const SizedBox(height: 15),
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