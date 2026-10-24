import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/home_screen.dart';
import 'package:muevete/features/progress/presentation/screens/progress_screen.dart';
import 'package:muevete/features/settings/presentation/screens/settings_screen.dart';
import 'package:muevete/features/training/presentation/screens/training_screen.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_launcher.dart';
import 'package:muevete/l10n/app_localizations.dart';

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

  static const List<Widget> _screens = [
    HomeScreen(),
    TrainingScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(mainNavIndexProvider);

    return WalkthroughLauncher(child: Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index != currentIndex) {
            HapticFeedback.selectionClick();
            ref.read(mainNavIndexProvider.notifier).setIndex(index);
          }
        },
        destinations: [
          WalkthroughAnchor(
            id: 'nav.home',
            child: NavigationDestination(
              selectedIcon: const Icon(Icons.home_rounded),
              icon: const Icon(Icons.home_outlined),
              label: l10n.navHome,
            ),
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.fitness_center_rounded),
            icon: const Icon(Icons.fitness_center_outlined),
            label: l10n.navTraining,
          ),
          WalkthroughAnchor(
            id: 'nav.progress',
            child: NavigationDestination(
              selectedIcon: const Icon(Icons.insights_rounded),
              icon: const Icon(Icons.insights_outlined),
              label: l10n.navProgress,
            ),
          ),
          WalkthroughAnchor(
            id: 'nav.settings',
            child: NavigationDestination(
              selectedIcon: const Icon(Icons.settings_rounded),
              icon: const Icon(Icons.settings_outlined),
              label: l10n.navSettings,
            ),
          ),
        ],
      ),
    ));
  }
}
