import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/progress/providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {  

    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text("Progress"),
            ElevatedButton(
              onPressed: (){
                context.push("/training");
              }, 
              child: const Text('(Training)'),
            ),
            progress.when(
              data: (p) {
                return Column(
                  children: [
                    Text("Completed: ${p.completed? "Yes" : "No"}"),
                    Text("Date: ${p.date}"),
                    Text("Duration: ${p.duration}"),
                  ],
                );
              }, 
              error: (err, stack) => Text('Error: $err'), 
              loading: ()=> CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}