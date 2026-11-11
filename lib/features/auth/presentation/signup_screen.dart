import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/features/privacy/presentation/widgets/privacy_consent_checkbox.dart';
import 'package:muevete/features/profile/domain/entities/biological_sex.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/services/body_measure_options.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/profile/presentation/widgets/biological_sex_selector.dart';
import 'package:muevete/features/profile/presentation/widgets/body_measure_wheels.dart';
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

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  BiologicalSex? _sex;
  bool _privacyAccepted = false;
  bool _healthDataAuthorized = false;

  // Picked on their own screens after the account details.
  int _age = BodyMeasureOptions.defaultAge;
  double _weightKg = BodyMeasureOptions.defaultWeightKg;
  double _heightCm = BodyMeasureOptions.defaultHeightCm.toDouble();

  /// 0 is the account form; 1, 2 and 3 pick age, weight and height.
  int _step = 0;
  static const int _lastStep = 3;

  String? errorMessage = '';
  bool _isLoading = false;

  /// True when the current Firebase user authenticated via a social provider
  /// (Google, Apple) and therefore does not need a password field.
  bool get _isSocialUser {
    final firebaseUser = ref.read(authRepositoryProvider).currentUser;
    if (firebaseUser == null) return false;
    return firebaseUser.providerData.every((p) => p.providerId != 'password');
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
    _medicalConditionsController.dispose();
    super.dispose();
  }

  /// Checks the account form. Age, weight and height come from pickers
  /// limited to valid values.
  String? _validateAccount(AppLocalizations l10n) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final social = _isSocialUser;

    if (name.isEmpty || email.isEmpty || (!social && password.isEmpty)) {
      return l10n.valMandatoryFields;
    }

    if (!email.contains('@') || !email.contains('.')) {
      return l10n.valInvalidEmail;
    }

    if (!social && password.length < _minPasswordLength) {
      return l10n.valPasswordMinLength;
    }

    if (_sex == null) {
      return l10n.valSelectSex;
    }

    if (!PrivacyConsentCheckboxes.complete(
      policyAccepted: _privacyAccepted,
      healthDataAuthorized: _healthDataAuthorized,
    )) {
      return l10n.valPrivacyRequired;
    }

    return null;
  }

  void _next() {
    final l10n = AppLocalizations.of(context)!;
    if (_step == 0) {
      final validationError = _validateAccount(l10n);
      if (validationError != null) {
        setState(() => errorMessage = validationError);
        return;
      }
    }
    if (_step == _lastStep) {
      handleSignup();
      return;
    }
    setState(() {
      errorMessage = '';
      _step++;
    });
  }

  void _back() {
    if (_step == 0 || _isLoading) return;
    setState(() {
      errorMessage = '';
      _step--;
    });
  }

  Future<void> handleSignup() async {
    final l10n = AppLocalizations.of(context)!;
    var signupStage = 'input parsing';
    final validationError = _validateAccount(l10n);
    if (validationError != null) {
      setState(() {
        errorMessage = validationError;
        _step = 0;
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
      final age = _age;
      final weight = _weightKg;
      final height = _heightCm;
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
        sex: _sex!.storedValue,
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
      await ref
          .read(profileRepositoryProvider)
          .createProfile(
            initialUser,
            privacyPolicyVersion: currentPrivacyPolicyVersion,
          );

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
          // These are about the email or password, on the first screen.
          if (const {
            'email-already-in-use',
            'invalid-email',
            'weak-password',
          }.contains(e.code)) {
            _step = 0;
          }
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

  bool get _hasError => errorMessage != null && errorMessage!.isNotEmpty;

  Widget _errorBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final social = _isSocialUser;

    return PopScope(
      // Back from a picker returns to the previous step, not out of sign-up.
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: _step > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: _back,
                )
              : null,
          centerTitle: true,
          title: _StepDashes(count: _lastStep + 1, current: _step),
          actions: const [LocaleSwitcher(compact: true), SizedBox(width: 12)],
        ),
        body: SafeArea(
          child: _step == 0 ? _accountForm(l10n, social) : _measureStep(l10n),
        ),
      ),
    );
  }

  Widget _accountForm(AppLocalizations l10n, bool social) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyHeadingTwo(text: l10n.authCreateAccountTitle),
            const SizedBox(height: 16),
            if (_hasError) _errorBanner(),
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

            BiologicalSexSelector(
              value: _sex,
              enabled: !_isLoading,
              onChanged: (sex) => setState(() => _sex = sex),
            ),
            const SizedBox(height: 14),

            MyTextinputfield(
              controller: _medicalConditionsController,
              hintText: l10n.authMedicalConditionsHint,
              prefixIcon: Icons.medical_information_outlined,
              obscureText: false,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),

            PrivacyConsentCheckboxes(
              policyAccepted: _privacyAccepted,
              healthDataAuthorized: _healthDataAuthorized,
              enabled: !_isLoading,
              onPolicyChanged: (value) =>
                  setState(() => _privacyAccepted = value),
              onHealthDataChanged: (value) =>
                  setState(() => _healthDataAuthorized = value),
            ),
            const SizedBox(height: 16),

            MyButton(text: l10n.commonNext, onTap: _next),
            const SizedBox(height: 12),

            if (!social)
              MyButtonSecondarytext(
                text: l10n.authAlreadyHaveAccount,
                onTap: () => context.go('/login'),
              ),
          ],
        ),
      ),
    );
  }

  /// One number per screen, picked on a wheel.
  Widget _measureStep(AppLocalizations l10n) {
    final (title, wheel) = switch (_step) {
      1 => (
        l10n.measureAgeTitle,
        AgeWheel(value: _age, onChanged: (value) => _age = value),
      ),
      2 => (
        l10n.measureWeightTitle,
        WeightWheel(
          valueKg: _weightKg,
          onChanged: (value) => _weightKg = value,
        ),
      ),
      _ => (
        l10n.measureHeightTitle,
        HeightWheel(
          valueCm: _heightCm,
          onChanged: (value) => _heightCm = value,
        ),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              // A new wheel per step, starting at that step's value.
              child: KeyedSubtree(key: ValueKey(_step), child: wheel),
            ),
          ),
        ),
        if (_hasError) _errorBanner(),
        MyButton(
          key: const ValueKey('signup-step-next'),
          text: _step == _lastStep ? l10n.authRegister : l10n.commonNext,
          onTap: _next,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// The sign-up progress: one dash per screen, the current one highlighted.
class _StepDashes extends StatelessWidget {
  const _StepDashes({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == current ? AppColors.primaryDark : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
