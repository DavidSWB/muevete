import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/home_screen.dart';
import 'package:muevete/features/progress/presentation/screens/progress_screen.dart';
import 'package:muevete/features/settings/presentation/screens/settings_screen.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        destinations: [
          NavigationDestination(
            selectedIcon: const Icon(Icons.home),
            icon: const Icon(Icons.home_outlined), 
            label: l10n.navHome,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.fitness_center),
            icon: const Icon(Icons.fitness_center_outlined), 
            label: l10n.navTraining,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.insights),
            icon: const Icon(Icons.insights_outlined), 
            label: l10n.navProgress,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.settings),
            icon: const Icon(Icons.settings_outlined), 
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}