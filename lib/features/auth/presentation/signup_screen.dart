import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  String? errorMessage = '';
  bool _isLoading = false;

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

  String? _validateInputs() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final ageText = _ageController.text.trim();
    final weightText = _weightController.text.trim();
    final heightText = _heightController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        ageText.isEmpty ||
        weightText.isEmpty ||
        heightText.isEmpty) {
      return "All mandatory fields must be filled.";
    }

    if (!email.contains('@') || !email.contains('.')) {
      return "Please enter a valid email address.";
    }

    if (password.length < 6) {
      return "Password must be at least 6 characters long.";
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0 || age > 120) {
      return "Please enter a valid age (1-120).";
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0 || weight > 400) {
      return "Please enter a valid weight in kg.";
    }

    final height = double.tryParse(heightText);
    if (height == null || height <= 0 || height > 300) {
      return "Please enter a valid height in cm.";
    }

    return null;
  }

  Future<void> handleSignup() async {
    final validationError = _validateInputs();
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

      // 1. Create user with Firebase Auth
      final user = await ref.read(authProvider.notifier).signUp(
            email: email,
            password: password,
          );

      final uid = user?.uid ?? ref.read(authRepositoryProvider).currentUser?.uid;

      if (uid == null) {
        throw Exception("Could not retrieve user ID after registration.");
      }

      // 2. Create initial user profile in Firestore
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

      await ref.read(profileRepositoryProvider).saveProfile(initialUser);

      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already in use by another account.";
          break;
        case 'invalid-email':
          message = "The email address is invalid.";
          break;
        case 'weak-password':
          message = "The password provided is too weak.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your internet connection.";
          break;
        default:
          message = e.message ?? "Authentication failed. Please try again.";
      }
      if (mounted) {
        setState(() {
          errorMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "An unexpected error occurred. Please try again.";
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MyHeadingTwo(text: "Create Account"),
                const SizedBox(height: 16),

                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _nameController,
                  hintText: "Full name",
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _emailController,
                  hintText: "Email (example@gmail.com)",
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _passwordController,
                  hintText: "Password (min. 6 characters)",
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _ageController,
                  hintText: "Age (e.g. 25)",
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _weightController,
                  hintText: "Weight in kg (e.g. 70.5)",
                  obscureText: false,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _heightController,
                  hintText: "Height in cm (e.g. 175)",
                  obscureText: false,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                MyTextinputfield(
                  controller: _medicalConditionsController,
                  hintText: "Medical conditions (optional)",
                  obscureText: false,
                ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  MyButton(
                    text: "Register",
                    onTap: handleSignup,
                  ),
                const SizedBox(height: 16),

                MyButtonSecondarytext(
                  text: "Already have an account? Log in",
                  onTap: () => context.go("/login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}