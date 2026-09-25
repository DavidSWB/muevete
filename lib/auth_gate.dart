import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/auth/presentation/login_screen.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:muevete/features/auth/presentation/signup_screen.dart';
import 'package:muevete/features/diagnosis/presentation/screens/diagnosis_screen.dart';
import 'package:muevete/shared/screens/error_screen.dart';
import 'package:muevete/shared/screens/loading_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        final onboardingState = ref.watch(onboardingStatusProvider);

        return onboardingState.when(
          data: (status) {
            switch (status) {
              case OnboardingStatus.unauthenticated:
                return const LoginScreen();
              case OnboardingStatus.noProfile:
                return const SignupScreen();
              case OnboardingStatus.noDiagnosis:
                return const DiagnosisScreen();
              case OnboardingStatus.complete:
                return const MainScreen();
            }
          },
          error: (error, stackTrace) => ErrorScreen(error),
          loading: () => const LoadingScreen(),
        );
      },
      error: (error, stackTrace) => ErrorScreen(error),
      loading: () => const LoadingScreen(),
    );
  }
}