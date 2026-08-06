import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/home_screen.dart';
import 'package:muevete/features/auth/presentation/login_screen.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/shared/screens/error_screen.dart';
import 'package:muevete/shared/screens/loading_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return auth.when(
      data: (user){

        if (user == null) return const LoginScreen();

        return HomeScreen();
      }, 
      error: (error, stack){
        return ErrorScreen(error);
      }, 
      loading: () {
        return LoadingScreen();
      });

  }
}