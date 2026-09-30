import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/presentation/providers/program_setup_provider.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';

class ProgramSetupScreen extends ConsumerStatefulWidget {
  const ProgramSetupScreen({super.key});

  @override
  ConsumerState<ProgramSetupScreen> createState() => _ProgramSetupScreenState();
}

class _ProgramSetupScreenState extends ConsumerState<ProgramSetupScreen> {
  String? _selectedPlanId;
  bool _isSaving = false;
  String? _saveError;

  Future<void> _save() async {
    final selectedPlanId = _selectedPlanId;
    if (selectedPlanId == null) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await ref.read(programSetupProvider.notifier).savePlan(selectedPlanId);
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        setState(() {
          _saveError = 'Could not save the training program. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(programSetupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Training program')),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: 'Could not load training programs.',
          onRetry: () => ref.invalidate(programSetupProvider),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return const _ErrorView(message: 'No training programs are available.');
          }

          return SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Select a program to continue to Home.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) => _PlanCard(
                      plan: plans[index],
                      selected: _selectedPlanId == plans[index].planId,
                      onTap: () => setState(() {
                        _selectedPlanId = plans[index].planId;
                        _saveError = null;
                      }),
                    ),
                  ),
                ),
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _saveError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 8),
                _isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      )
                    : MyButton(
                        text: 'Continue',
                        enabled: _selectedPlanId != null,
                        onTap: _save,
                      ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final TrainingPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = plan.name['es'] ?? plan.name['en'] ?? plan.planId;
    final description = plan.description['es'] ?? plan.description['en'] ?? '';

    return Card(
      color: selected ? AppColors.cardBlue : null,
      child: RadioListTile<String>(
        value: plan.planId,
        groupValue: selected ? plan.planId : null,
        onChanged: (_) => onTap(),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$description\n${plan.daysPerWeek} days per week'),
        isThreeLine: true,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
