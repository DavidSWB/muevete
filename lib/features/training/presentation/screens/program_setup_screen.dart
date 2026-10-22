import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/services/training_schedule_service.dart';
import 'package:muevete/features/training/presentation/providers/program_setup_provider.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/screens/error_screen.dart';
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

  Future<void> _save(AppLocalizations l10n) async {
    final selectedPlan = _selectedPlan;
    if (selectedPlan == null) return;
    if (_selectedSchedule.length != selectedPlan.daysPerWeek) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final sortedWeekdays = _selectedSchedule.keys.toList()..sort();
      final canonicalDays = <int, int>{};
      for (int i = 0; i < sortedWeekdays.length; i++) {
        canonicalDays[sortedWeekdays[i]] = i + 1;
      }

      final schedule = UserSchedule(
        days: canonicalDays,
        preferredTime:
            '${_preferredTime.hour.toString().padLeft(2, '0')}:${_preferredTime.minute.toString().padLeft(2, '0')}',
      );

      await ref
          .read(programSetupProvider.notifier)
          .savePlan(selectedPlan.planId, schedule);
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        setState(() {
          _saveError = l10n.progCouldNotSave;
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleDay(int weekday, bool selected) {
    final selectedPlan = _selectedPlan;
    if (selectedPlan == null) return;

    setState(() {
      if (selected) {
        if (_selectedSchedule.length < selectedPlan.daysPerWeek) {
          _selectedSchedule[weekday] = 1;
        }
      } else {
        _selectedSchedule.remove(weekday);
      }

      final sortedWeekdays = _selectedSchedule.keys.toList()..sort();
      _selectedSchedule.clear();
      for (int i = 0; i < sortedWeekdays.length; i++) {
        _selectedSchedule[sortedWeekdays[i]] = i + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plansAsync = ref.watch(programSetupProvider);

    final dayNames = [
      l10n.dayMonShort,
      l10n.dayTueShort,
      l10n.dayWedShort,
      l10n.dayThuShort,
      l10n.dayFriShort,
      l10n.daySatShort,
      l10n.daySunShort,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progTitle),
        actions: const [LocaleSwitcher(compact: true), SizedBox(width: 8)],
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorScreen(
          l10n.progCouldNotLoad,
          onRetry: () => ref.invalidate(programSetupProvider),
          retryLabel: l10n.notifRetry,
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return ErrorScreen(l10n.progNoPrograms);
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      l10n.progSelectSubtitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        plan: plans[index],
                        selected: _selectedPlan?.planId == plans[index].planId,
                        onTap: () => setState(() {
                          _selectedPlan = plans[index];
                          _selectedSchedule.clear();
                          _saveError = null;
                        }),
                      ),
                    ),
                  ),
                  if (_selectedPlan != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${l10n.progSelectDays} (${_selectedSchedule.length}/${_selectedPlan!.daysPerWeek})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        final weekday = index + 1;
                        final isSelected = _selectedSchedule.containsKey(
                          weekday,
                        );
                        return ChoiceChip(
                          label: Text(
                            dayNames[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          onSelected: (selected) =>
                              _toggleDay(weekday, selected),
                          selectedColor: const Color(0xFF0077C2),
                          backgroundColor: const Color(0xFFE3F2FD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF0077C2)
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          elevation: isSelected ? 2 : 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        );
                      }),
                    ),
                    Builder(
                      builder: (context) {
                        final conflicts = const TrainingScheduleService()
                            .getRecoveryConflicts(
                              _selectedSchedule,
                              _selectedPlan!,
                            );
                        if (conflicts.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warningSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.progRecoveryWarning,
                                      style: const TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.primaryDark,
                          ),
                          title: Text(
                            l10n.progReminderTime,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            _preferredTime.format(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _preferredTime,
                            );
                            if (time != null) {
                              setState(() => _preferredTime = time);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                  if (_saveError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Text(
                        _saveError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  MyButton(
                    text: l10n.progContinue,
                    isLoading: _isSaving,
                    enabled:
                        _selectedPlan != null &&
                        _selectedSchedule.length == _selectedPlan!.daysPerWeek,
                    onTap: () => _save(l10n),
                  ),
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
    final name = plan.name.localized(context, fallback: plan.planId);
    final description = plan.description.localized(context, fallback: '');

    return Card(
      color: selected ? AppColors.cardBlue : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primaryDark : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primaryDark : AppColors.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '${plan.daysPerWeek} days/week',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
