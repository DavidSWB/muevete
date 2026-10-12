import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/home_screen.dart';
import 'package:muevete/features/settings/presentation/screens/settings_screen.dart';
import 'package:muevete/features/progress/presentation/screens/progress_screen.dart';
import 'package:muevete/features/training/presentation/screens/training_screen.dart';

final mainNavIndexProvider =
    NotifierProvider<MainNavIndexNotifier, int>(MainNavIndexNotifier.new);

class MainNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainNavIndexProvider);

    const screens = [
      HomeScreen(),
      TrainingScreen(),
      ProgressScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(mainNavIndexProvider.notifier).setIndex(index);
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined), 
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.fitness_center),
            icon: Icon(Icons.fitness_center_outlined), 
            label: 'Training',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.insights),
            icon: Icon(Icons.insights_outlined), 
            label: 'Progress',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined), 
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}