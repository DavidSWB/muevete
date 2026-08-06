import 'package:go_router/go_router.dart';
import 'package:muevete/app/home_screen.dart';
import 'package:muevete/auth_gate.dart';
import 'package:muevete/features/auth/presentation/login_screen.dart';
import 'package:muevete/features/auth/presentation/signup_screen.dart';
import 'package:muevete/features/diagnosis/presentation/screens/diagnosis_screen.dart';
import 'package:muevete/features/progress/presentation/progress_screen.dart';
import 'package:muevete/features/training/presentation/screens/training_screen.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => AuthGate() ,
    ),
    GoRoute(
      path: "/login",
      builder: (context, state) => LoginScreen() ,
    ),
    GoRoute(
      path: "/home",
      builder: (context, state) => HomeScreen() ,
    ),
    GoRoute(
      path: "/signup",
      builder: (context, state) => SignupScreen() ,
    ),
    GoRoute(
      path: "/diagnosis",
      builder: (context, state) => DiagnosisScreen() ,
    ),
    GoRoute(
      path: "/progress",
      builder: (context, state) => ProgressScreen() ,
    ),
    GoRoute(
      path: "/training",
      builder: (context, state) => TrainingScreen() ,
    ),
  ],
);