import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/auth_gate.dart';
import 'package:muevete/features/auth/presentation/login_screen.dart';
import 'package:muevete/features/auth/presentation/signup_screen.dart';
import 'package:muevete/features/diagnosis/presentation/screens/diagnosis_screen.dart';
import 'package:muevete/features/training/presentation/screens/program_setup_screen.dart';
import 'package:muevete/features/active_breaks/presentation/screens/active_breaks_screen.dart';
import 'package:muevete/features/active_breaks/presentation/screens/active_break_selection_screen.dart';
import 'package:muevete/features/active_breaks/presentation/screens/active_break_timer_screen.dart';
import 'package:muevete/features/active_breaks/presentation/screens/active_break_workout_screen.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';

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
      path: "/signup",
      builder: (context, state) => SignupScreen() ,
    ),
    GoRoute(
      path: "/home",
      builder: (context, state) => const AuthGate() ,
    ),
    GoRoute(
      path: "/diagnosis",
      builder: (context, state) => DiagnosisScreen() ,
    ),
    GoRoute(
      path: "/program-setup",
      builder: (context, state) => const ProgramSetupScreen(),
    ),
    GoRoute(
      path: "/active-breaks",
      builder: (context, state) => const ActiveBreaksScreen(),
      routes: [
        GoRoute(
          path: "browse",
          builder: (context, state) => const ActiveBreakSelectionScreen(),
        ),
        GoRoute(
          path: "timer",
          builder: (context, state) => const ActiveBreakTimerScreen(),
        ),
        GoRoute(
          path: "workout",
          builder: (context, state) {
            final activeBreak = state.extra;
            if (activeBreak is! ActiveBreak) {
              return const Scaffold(
                body: Center(child: Text('Active Break not found.')),
              );
            }
            return ActiveBreakWorkoutScreen(activeBreak: activeBreak);
          },
        ),
      ],
    ),
  ],
);
