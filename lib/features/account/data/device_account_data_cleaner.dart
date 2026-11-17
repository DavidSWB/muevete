import 'dart:developer' as developer;

import 'package:muevete/features/account/domain/account_deletion_service.dart';
import 'package:muevete/features/education/data/shared_preferences_tip_preferences_store.dart';
import 'package:muevete/features/privacy/data/shared_preferences_policy_notice_store.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceAccountDataCleaner implements LocalAccountDataCleaner {
  DeviceAccountDataCleaner({
    required WalkthroughStore walkthroughStore,
    Future<void> Function()? cancelReminders,
    Future<SharedPreferences> Function()? preferences,
  }) : _walkthroughStore = walkthroughStore,
       _cancelReminders =
           cancelReminders ?? NotificationScheduler.cancelUserReminders,
       _preferences = preferences ?? SharedPreferences.getInstance;

  final WalkthroughStore _walkthroughStore;
  final Future<void> Function() _cancelReminders;
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<void> clear(String uid) async {
    // Each step is independent: one failing must not keep the others from
    // running or stop the account deletion.
    await _run('cancel reminders', _cancelReminders);
    await _run('clear tour progress', () => _walkthroughStore.clear(uid));
    await _run('clear tip preferences', () async {
      final prefs = await _preferences();
      await prefs.remove(SharedPreferencesTipPreferencesStore.keyFor(uid));
    });
    await _run('clear policy notice', () async {
      final prefs = await _preferences();
      await prefs.remove(SharedPreferencesPolicyNoticeStore.keyFor(uid));
    });
  }

  Future<void> _run(String operation, Future<void> Function() step) async {
    try {
      await step();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to $operation',
        name: 'muevete.account',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
