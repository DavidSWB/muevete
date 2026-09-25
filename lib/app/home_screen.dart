import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/presentation/providers/next_training_provider.dart';
import 'package:muevete/shared/theme/app_colors.dart';



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final nextTraining = ref.watch(nextTrainingProvider);

    return profile.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => const Center(
        child: Text('Could not load profile'),
      ),
      data: (user) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(user.username),
                const SizedBox(height: 20),
                _buildKeepProgress(),
                const SizedBox(height: 20),
                _buildStats(user, nextTraining),
                const SizedBox(height: 28),
                _buildStartTraining(),
              ],
            ),
          ),
        );
      },
    );
  }
}

  Widget _buildGreeting(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi $username!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Let’s keep moving.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildKeepProgress() {
    return Card(
      color: AppColors.cardBlue,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep progress!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Stay consistent with your training.'),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(user, AsyncValue nextTraining) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatCard(
          title: 'Completed',
          value: '${user.completedWorkouts.length}',
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          title: 'Next workout',
          value: nextTraining.when(
            loading: () => '...',
            error: (_, __) => '--',
            data: (day) => day.name['en'] ?? 'Workout',
          ),
          color: AppColors.cardOrange,
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          title: 'Overall level',
          value: user.stats?.overallLevel.round().toString() ?? '--',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    Color color = AppColors.softGrey,
  }) {
    return Expanded(
      child: Card(
        color: color,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


Widget _buildStartTraining() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start training now!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.accessibility_new,
                  size: 36,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active breaks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quick routines to keep you moving.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }