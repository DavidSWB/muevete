import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class ActiveBreaksScreen extends StatelessWidget {
  const ActiveBreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Breaks')),
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You better move that beautiful butt... or you\'ll lose it.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _OptionCard(
              icon: Icons.accessibility_new,
              title: 'Active Breaks',
              description: 'Choose a quick routine to keep moving.',
              onTap: () => context.push('/active-breaks/browse'),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.timer_outlined,
              title: 'Personal Timer',
              description: 'Set a timer for a self-directed break.',
              onTap: () => context.push('/active-breaks/timer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 34, color: AppColors.primaryDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
