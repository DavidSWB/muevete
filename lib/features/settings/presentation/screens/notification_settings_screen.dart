import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_button.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _initializedFromProfile = false;

  bool _notificationsMasterEnabled = true;
  bool _trainingReminderEnabled = true;
  bool _activeBreakReminderEnabled = false;

  TimeOfDay _activeBreakStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _activeBreakEndTime = const TimeOfDay(hour: 18, minute: 0);
  int _activeBreakIntervalMinutes = 120;

  bool _permissionGranted = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await NotificationScheduler.checkPermissionStatus();
    if (mounted) {
      setState(() {
        _permissionGranted = granted;
      });
    }
  }

  Future<void> _requestPermission() async {
    final granted = await NotificationScheduler.requestPermission();
    if (mounted) {
      setState(() {
        _permissionGranted = granted;
      });
    }
  }

  void _initFields(UserModel user) {
    if (_initializedFromProfile) return;
    _initializedFromProfile = true;

    final notifs = user.notifications;
    if (notifs != null) {
      _notificationsMasterEnabled = notifs.enabled;
      _trainingReminderEnabled = notifs.trainingReminderEnabled;
      _activeBreakReminderEnabled = notifs.activeBreakReminderEnabled;

      _activeBreakStartTime = _parseTimeString(
        notifs.activeBreakStartTime,
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      _activeBreakEndTime = _parseTimeString(
        notifs.activeBreakEndTime,
        fallback: const TimeOfDay(hour: 18, minute: 0),
      );
      _activeBreakIntervalMinutes = notifs.activeBreakIntervalMinutes;
    }
  }

  TimeOfDay _parseTimeString(String? timeStr, {required TimeOfDay fallback}) {
    if (timeStr == null) return fallback;
    final parts = timeStr.trim().split(':');
    if (parts.length != 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get _isActiveBreakRangeValid {
    final startMinutes =
        _activeBreakStartTime.hour * 60 + _activeBreakStartTime.minute;
    final endMinutes =
        _activeBreakEndTime.hour * 60 + _activeBreakEndTime.minute;
    return endMinutes > startMinutes;
  }

  bool get _canSave {
    if (_isSaving) return false;
    if (_activeBreakReminderEnabled && !_isActiveBreakRangeValid) return false;
    return true;
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _activeBreakStartTime,
    );
    if (picked != null) {
      setState(() {
        _activeBreakStartTime = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _activeBreakEndTime,
    );
    if (picked != null) {
      setState(() {
        _activeBreakEndTime = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (!_canSave) return;

    if (_activeBreakReminderEnabled && !_isActiveBreakRangeValid) {
      setState(() {
        _errorMessage = 'End time must be later than start time.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedNotifs = UserNotifications(
        enabled: _notificationsMasterEnabled,
        trainingReminderEnabled: _trainingReminderEnabled,
        activeBreakReminderEnabled: _activeBreakReminderEnabled,
        activeBreakStartTime: _formatTimeOfDay(_activeBreakStartTime),
        activeBreakEndTime: _formatTimeOfDay(_activeBreakEndTime),
        activeBreakIntervalMinutes: _activeBreakIntervalMinutes,
      );

      await ref
          .read(profileProvider.notifier)
          .saveNotificationPreferences(updatedNotifs);

      // Re-check permissions
      await _checkPermission();

      if (mounted) {
        if (!_permissionGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Settings saved, but notifications are disabled on this device.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification settings saved successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error is NotificationSchedulingException
              ? 'Preferences were saved, but reminders could not be scheduled. Check notification permissions and try again.'
              : 'Could not save notification settings. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatWeekdayList(Map<int, int> days) {
    const names = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    final sorted = days.keys.toList()..sort();
    return sorted.map((d) => names[d] ?? 'Day $d').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      backgroundColor: AppColors.surface,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load profile.'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) {
          _initFields(user);
          final schedule = user.training?.schedule;
          final hasValidSchedule =
              schedule != null && schedule.days.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              if (!_permissionGranted) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Notifications Disabled',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Notification permissions are disabled on your device. Muévete cannot deliver workout or active break reminders until permission is enabled.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Request Permission'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber.shade900,
                          side: BorderSide(color: Colors.amber.shade700),
                        ),
                        onPressed: _requestPermission,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Section: Training Reminders
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cardBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Training Reminders',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _trainingReminderEnabled && hasValidSchedule,
                          onChanged: hasValidSchedule
                              ? (val) {
                                  setState(() {
                                    _trainingReminderEnabled = val;
                                  });
                                }
                              : null,
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (hasValidSchedule) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.softGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Days: ${_formatWeekdayList(schedule.days)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  'Time: ${schedule.preferredTime ?? "18:00"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Change Schedule in Program Setup'),
                        onPressed: () {
                          context.push('/program-setup');
                        },
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No Active Training Schedule',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'To enable training reminders, please select a training plan and set your workout days.',
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cardOrangeStrong,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context.push('/program-setup');
                              },
                              child: const Text('Configure Program'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section: Active-Break Reminders
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cardOrange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.directions_walk,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Active-Break Reminders',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _activeBreakReminderEnabled,
                          onChanged: (val) {
                            setState(() {
                              _activeBreakReminderEnabled = val;
                            });
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Receive reminders to move throughout your day during a configurable time window.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    if (_activeBreakReminderEnabled) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickStartTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.softGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimeOfDay(_activeBreakStartTime),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickEndTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.softGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'End Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimeOfDay(_activeBreakEndTime),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_isActiveBreakRangeValid) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'End time must be later than start time within the same day.',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Reminder Interval',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final minutes in UserNotifications.supportedIntervals)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(
                                    minutes == 60
                                        ? '60 min\n(1 hour)'
                                        : minutes == 120
                                            ? '120 min\n(2 hours)'
                                            : '180 min\n(3 hours)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _activeBreakIntervalMinutes ==
                                              minutes
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  selected:
                                      _activeBreakIntervalMinutes == minutes,
                                  selectedColor: AppColors.primary,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _activeBreakIntervalMinutes = minutes;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                MyButton(
                  text: 'Save Preferences',
                  enabled: _canSave,
                  onTap: _savePreferences,
                ),
            ],
          );
        },
      ),
    );
  }
}
