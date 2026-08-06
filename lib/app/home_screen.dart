import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text("Home"),
            ElevatedButton(
              onPressed: (){
                context.push("/diagnosis");
              }, 
              child: const Text('(Diagnosis)'),
          
            ),
            Text(
              user?.email ?? "No User"
            ),
            ElevatedButton(
              onPressed: (){
                context.push("/training");
              }, 
              child: const Text('(Training)'),
          
            ),
            ElevatedButton(
              onPressed: (){
                ref.read(authProvider.notifier).signOut();
                context.go("/");
              }, 
              child: const Text('(Sign out)'),
          
            ),
          ],
        ),
      ),
    );
  }
}