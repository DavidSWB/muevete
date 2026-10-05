import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/services/training_schedule_service.dart';
import 'package:muevete/features/training/presentation/providers/program_setup_provider.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';

class ProgramSetupScreen extends ConsumerStatefulWidget {
  const ProgramSetupScreen({super.key});

  @override
  ConsumerState<ProgramSetupScreen> createState() => _ProgramSetupScreenState();
}

class _ProgramSetupScreenState extends ConsumerState<ProgramSetupScreen> {
  TrainingPlan? _selectedPlan;
  final Map<int, int> _selectedSchedule = {};
  TimeOfDay _preferredTime = const TimeOfDay(hour: 9, minute: 0);

  bool _isSaving = false;
  String? _saveError;

  Future<void> _save() async {
    final selectedPlan = _selectedPlan;
    if (selectedPlan == null) return;
    if (_selectedSchedule.length != selectedPlan.daysPerWeek) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final schedule = UserSchedule(
        days: _selectedSchedule,
        preferredTime: '${_preferredTime.hour.toString().padLeft(2, '0')}:${_preferredTime.minute.toString().padLeft(2, '0')}',
      );
      
      await ref.read(programSetupProvider.notifier).savePlan(selectedPlan.planId, schedule);
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
            child: SingleChildScrollView(
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) => _PlanCard(
                      plan: plans[index],
                      selected: _selectedPlan?.planId == plans[index].planId,
                      onTap: () => setState(() {
                        _selectedPlan = plans[index];
                        _selectedSchedule.clear();
                        _saveError = null;
                      }),
                    ),
                  ),
                  if (_selectedPlan != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Select your training days', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final weekday = index + 1;
                        final isSelected = _selectedSchedule.containsKey(weekday);
                        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return ChoiceChip(
                          label: Text(dayNames[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (_selectedSchedule.length < _selectedPlan!.daysPerWeek) {
                                  int nextDay = 1;
                                  for (int i = 1; i <= _selectedPlan!.daysPerWeek; i++) {
                                    if (!_selectedSchedule.containsValue(i)) {
                                      nextDay = i;
                                      break;
                                    }
                                  }
                                  _selectedSchedule[weekday] = nextDay;
                                }
                              } else {
                                _selectedSchedule.remove(weekday);
                              }
                            });
                          },
                        );
                      }),
                    ),
                    Builder(builder: (context) {
                      final conflicts = const TrainingScheduleService().getRecoveryConflicts(_selectedSchedule, _selectedPlan!);
                      if (conflicts.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            '⚠️ Scheduling workouts that target the same muscles consecutively limits recovery. Consider leaving a 48h window.',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    ListTile(
                      title: const Text('Reminder Time'),
                      trailing: Text(_preferredTime.format(context)),
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: _preferredTime);
                        if (time != null) {
                          setState(() => _preferredTime = time);
                        }
                      },
                    ),
                  ],
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
                          enabled: _selectedPlan != null && _selectedSchedule.length == _selectedPlan!.daysPerWeek,
                          onTap: _save,
                        ),
                  const SizedBox(height: 16),
                ],
              ),
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
