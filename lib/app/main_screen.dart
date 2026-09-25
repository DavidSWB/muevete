import 'package:flutter/material.dart';
import 'package:muevete/app/home_screen.dart';
import 'package:muevete/features/settings/presentation/screens/settings_screen.dart';
import 'package:muevete/features/progress/presentation/screens/progress_screen.dart';
import 'package:muevete/features/training/presentation/screens/training_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex =0;

  @override
  Widget build(BuildContext context) {

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
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const[
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
        ]
        ),
    );
  }
}