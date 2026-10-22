import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
import 'package:muevete/shared/widgets/my_heading_two.dart';
import 'package:muevete/shared/widgets/my_textinputfield.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  static const int _minPasswordLength = 6;
  static const int _maxValidAge = 120;
  static const double _maxValidWeightKg = 400;
  static const double _maxValidHeightCm = 300;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  String? errorMessage = '';
  bool _isLoading = false;

  /// True when the current Firebase user authenticated via a social provider
  /// (Google, Apple) and therefore does not need a password field.
  bool get _isSocialUser {
    final firebaseUser = ref.read(authRepositoryProvider).currentUser;
    if (firebaseUser == null) return false;
    return firebaseUser.providerData.every(
      (p) => p.providerId != 'password',
    );
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill name and email from the social-provider Firebase user when
    // the user arrived via Google / Apple.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firebaseUser = ref.read(authRepositoryProvider).currentUser;
      if (firebaseUser == null) return;

      final isSocial = firebaseUser.providerData.every(
        (p) => p.providerId != 'password',
      );
      if (!isSocial) return;

      if (firebaseUser.email != null && firebaseUser.email!.isNotEmpty) {
        _emailController.text = firebaseUser.email!;
      }
      if (firebaseUser.displayName != null &&
          firebaseUser.displayName!.isNotEmpty) {
        _nameController.text = firebaseUser.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  String? _validateInputs(AppLocalizations l10n) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final ageText = _ageController.text.trim();
    final weightText = _weightController.text.trim();
    final heightText = _heightController.text.trim();
    final social = _isSocialUser;

    if (name.isEmpty ||
        email.isEmpty ||
        (!social && password.isEmpty) ||
        ageText.isEmpty ||
        weightText.isEmpty ||
        heightText.isEmpty) {
      return l10n.valMandatoryFields;
    }

    if (!email.contains('@') || !email.contains('.')) {
      return l10n.valInvalidEmail;
    }

    if (!social && password.length < _minPasswordLength) {
      return l10n.valPasswordMinLength;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0 || age > _maxValidAge) {
      return l10n.valInvalidAge;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0 || weight > _maxValidWeightKg) {
      return l10n.valInvalidWeight;
    }

    final height = double.tryParse(heightText);
    if (height == null || height <= 0 || height > _maxValidHeightCm) {
      return l10n.valInvalidHeight;
    }

    return null;
  }

  Future<void> handleSignup() async {
    final l10n = AppLocalizations.of(context)!;
    var signupStage = 'input parsing';
    final validationError = _validateInputs(l10n);
    if (validationError != null) {
      setState(() {
        errorMessage = validationError;
      });
      return;
    }

    setState(() {
      errorMessage = '';
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final age = int.parse(_ageController.text.trim());
      final weight = double.parse(_weightController.text.trim());
      final height = double.parse(_heightController.text.trim());
      final medicalConditionsText = _medicalConditionsController.text.trim();

      String? uid;

      if (_isSocialUser) {
        // Social user: Firebase account already exists. Use the current UID.
        signupStage = 'resolving social Auth user ID';
        uid = ref.read(authRepositoryProvider).currentUser?.uid;
      } else {
        // Email/password: create the Firebase Auth account.
        signupStage = 'Firebase Auth account creation';
        final user = await _signUpOrRecoverMatchingSession(
          email: email,
          password: password,
        );

        signupStage = 'resolving Auth user ID';
        uid = user?.uid ?? ref.read(authRepositoryProvider).currentUser?.uid;
      }

      if (uid == null) {
        throw Exception('Could not retrieve user ID after registration.');
      }

      // Create initial user profile in Firestore.
      signupStage = 'Firestore profile construction';
      final initialUser = UserModel(
        id: uid,
        email: email,
        username: name,
        age: age,
        weight: weight,
        height: height,
        medicalConditions: medicalConditionsText.isNotEmpty
            ? [medicalConditionsText]
            : null,
        createdAt: DateTime.now(),
        completedWorkouts: const [],
        stats: null,
        training: null,
        progressSummary: null,
      );

      signupStage = 'Firestore profile save';
      await ref.read(profileRepositoryProvider).saveProfile(initialUser);

      signupStage = 'post-registration navigation';
      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Signup failed during $signupStage: FirebaseAuthException '
          'code=${e.code}',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
      if (mounted) {
        setState(() {
          errorMessage = _mapSignupFirebaseError(e, l10n);
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Signup failed during $signupStage (${e.runtimeType}).');
        if (e is FirebaseException) {
          debugPrint('Firebase error code: ${e.code}');
        }
        debugPrintStack(stackTrace: stackTrace);
      }
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

  String _mapSignupFirebaseError(
    FirebaseAuthException e,
    AppLocalizations l10n,
  ) {
    switch (e.code) {
      case 'email-already-in-use':
        return l10n.errEmailInUse;
      case 'invalid-email':
        return l10n.errInvalidEmailFormat;
      case 'weak-password':
        return l10n.errWeakPassword;
      case 'network-request-failed':
        return l10n.errNetwork;
      default:
        return e.message ?? l10n.errAuthFailed;
    }
  }

  Future<User?> _signUpOrRecoverMatchingSession({
    required String email,
    required String password,
  }) async {
    try {
      return await ref
          .read(authProvider.notifier)
          .signUp(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        rethrow;
      }

      final currentUser = ref.read(authRepositoryProvider).currentUser;
      final currentEmail = currentUser?.email?.trim().toLowerCase();
      if (currentEmail == email.trim().toLowerCase()) {
        return currentUser;
      }

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final social = _isSocialUser;

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
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyHeadingTwo(text: l10n.authCreateAccountTitle),
                const SizedBox(height: 16),

                if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                              errorMessage!,
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
                  ),
                  const SizedBox(height: 16),
                ],

                MyTextinputfield(
                  controller: _nameController,
                  hintText: l10n.authFullNameHint,
                  prefixIcon: Icons.person_outline_rounded,
                  obscureText: false,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                MyTextinputfield(
                  controller: _emailController,
                  hintText: l10n.authEmailHint,
                  prefixIcon: Icons.email_outlined,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  readOnly: social && _emailController.text.isNotEmpty,
                ),
                const SizedBox(height: 14),

                if (!social) ...[
                  MyTextinputfield(
                    controller: _passwordController,
                    hintText: l10n.authPasswordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                ],

                MyTextinputfield(
                  controller: _ageController,
                  hintText: l10n.authAgeHint,
                  prefixIcon: Icons.cake_outlined,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 14),

                MyTextinputfield(
                  controller: _weightController,
                  hintText: l10n.authWeightHint,
                  prefixIcon: Icons.monitor_weight_outlined,
                  obscureText: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                MyTextinputfield(
                  controller: _heightController,
                  hintText: l10n.authHeightHint,
                  prefixIcon: Icons.height_rounded,
                  obscureText: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                MyTextinputfield(
                  controller: _medicalConditionsController,
                  hintText: l10n.authMedicalConditionsHint,
                  prefixIcon: Icons.medical_information_outlined,
                  obscureText: false,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                MyButton(
                  text: l10n.authRegister,
                  onTap: handleSignup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 12),

                if (!social)
                  MyButtonSecondarytext(
                    text: l10n.authAlreadyHaveAccount,
                    onTap: () => context.go('/login'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
