import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationPluginAdapter {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<bool> checkPermissionStatus();
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
  });
  Future<void> cancel(int id);

  Future<void> showNow(
    int id,
    String? title,
    String? body,
    NotificationDetails notificationDetails,
  ) async {}

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return const <PendingNotificationRequest>[];
  }
}

class DefaultNotificationPluginAdapter implements NotificationPluginAdapter {
  final FlutterLocalNotificationsPlugin plugin;

  DefaultNotificationPluginAdapter([FlutterLocalNotificationsPlugin? plugin])
      : plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await plugin.initialize(initializationSettings);
  }

  @override
  Future<bool> requestPermission() async {
    bool granted = false;
    try {
      final android = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final res = await android.requestNotificationsPermission();
        granted = res ?? false;
      }
      final ios = plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final res = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = res ?? false;
      }
    } catch (_) {}
    return granted;
  }

  @override
  Future<bool> checkPermissionStatus() async {
    try {
      final android = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final res = await android.areNotificationsEnabled();
        return res ?? false;
      }
      final ios = plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final status = await ios.checkPermissions();
        return status?.isEnabled ?? false;
      }
    } catch (error, stackTrace) {
      developer.log(
        'Unable to check notification permission status',
        name: 'muevete.notifications',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
    return false;
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
  }) {
    return plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: androidScheduleMode,
      uiLocalNotificationDateInterpretation:
          uiLocalNotificationDateInterpretation,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  Future<void> cancel(int id) {
    return plugin.cancel(id);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    return plugin.pendingNotificationRequests();
  }

  @override
  Future<void> showNow(
    int id,
    String? title,
    String? body,
    NotificationDetails notificationDetails,
  ) {
    return plugin.show(id, title, body, notificationDetails);
  }
}

class NotificationScheduler {
  NotificationScheduler._();

  static NotificationPluginAdapter _adapter =
      DefaultNotificationPluginAdapter();

  static const int trainingIdBase = 1000; // IDs 1001..1007
  static const int activeBreakIdBase = 2000; // IDs 2001..2050
  static const int maxActiveBreakSlots = 45;
  static const int maxActiveBreakId = 2050;

  static String? _lastScheduledFingerprint;

  static void setAdapterForTesting(NotificationPluginAdapter adapter) {
    _adapter = adapter;
    _lastScheduledFingerprint = null;
  }

  static void resetForTesting() {
    _adapter = DefaultNotificationPluginAdapter();
    _lastScheduledFingerprint = null;
  }

  static Future<void> initialize({
    NotificationPluginAdapter? adapter,
    String? defaultLocationName,
  }) async {
    if (adapter != null) {
      _adapter = adapter;
    }

    tz.initializeTimeZones();
    try {
      final tzResult = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = defaultLocationName ?? tzResult.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    await _adapter.initialize();
  }

  static Future<bool> requestPermission() async {
    return _adapter.requestPermission();
  }

  static Future<bool> checkPermissionStatus() async {
    return _adapter.checkPermissionStatus();
  }

  static Future<List<PendingNotificationRequest>>
      pendingNotificationRequests() {
    return _adapter.pendingNotificationRequests();
  }

  static Future<void> showDiagnosticNotification() {
    return _adapter.showNow(
      9000,
      'Muévete diagnostic notification',
      'Local notifications are configured and can be displayed.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'diagnostic_channel',
          'Notification Diagnostics',
          channelDescription: 'Development diagnostics for local notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelTrainingReminders() async {
    for (int weekday = 1; weekday <= 7; weekday++) {
      await _adapter.cancel(trainingIdBase + weekday);
    }
  }

  static Future<void> cancelActiveBreakReminders() async {
    for (int id = activeBreakIdBase + 1; id <= maxActiveBreakId; id++) {
      await _adapter.cancel(id);
    }
  }

  static Future<void> cancelUserReminders() async {
    _lastScheduledFingerprint = null;
    await cancelTrainingReminders();
    await cancelActiveBreakReminders();
  }

  static String _generateFingerprint(UserModel user) {
    final notifs = user.notifications;
    final schedule = user.training?.schedule;
    return '${user.id}_'
        '${notifs?.enabled}_'
        '${notifs?.trainingReminderEnabled}_'
        '${schedule?.preferredTime}_'
        '${schedule?.days.entries.map((e) => "${e.key}:${e.value}").join(",")}_'
        '${notifs?.activeBreakReminderEnabled}_'
        '${notifs?.activeBreakStartTime}_'
        '${notifs?.activeBreakEndTime}_'
        '${notifs?.activeBreakIntervalMinutes}';
  }

  static Future<void> rescheduleAll(UserModel user, {bool force = false}) async {
    final fingerprint = _generateFingerprint(user);
    if (!force && _lastScheduledFingerprint == fingerprint) {
      return;
    }

    await scheduleTrainingReminders(user);
    await scheduleActiveBreaks(user);

    _lastScheduledFingerprint = fingerprint;
  }

  static Future<int> scheduleTrainingReminders(
    UserModel user, {
    DateTime? nowOverride,
  }) async {
    await cancelTrainingReminders();

    if (user.notifications == null ||
        !user.notifications!.enabled ||
        !user.notifications!.trainingReminderEnabled) {
      return 0;
    }

    final schedule = user.training?.schedule;
    if (schedule == null ||
        schedule.days.isEmpty ||
        schedule.preferredTime == null) {
      return 0;
    }

    if (!UserNotifications.isValidTimeFormat(schedule.preferredTime)) {
      return 0;
    }

    final timeParts = schedule.preferredTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    int scheduledCount = 0;
    final nowTz = nowOverride != null
        ? tz.TZDateTime.from(nowOverride, tz.local)
        : tz.TZDateTime.now(tz.local);

    for (final entry in schedule.days.entries) {
      final weekday = entry.key; // 1=Mon .. 7=Sun
      if (weekday < 1 || weekday > 7) continue;

      final sessionNumber = entry.value;

      var scheduledDate = tz.TZDateTime(
        tz.local,
        nowTz.year,
        nowTz.month,
        nowTz.day,
        hour,
        minute,
      );

      while (scheduledDate.weekday != weekday || scheduledDate.isBefore(nowTz)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _adapter.zonedSchedule(
        trainingIdBase + weekday,
        'Time to train!',
        'Session $sessionNumber: Your scheduled workout is ready.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'training_channel',
            'Training Reminders',
            channelDescription: 'Reminders for your scheduled workouts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      scheduledCount++;
    }

    return scheduledCount;
  }

  static Future<int> scheduleActiveBreaks(
    UserModel user, {
    DateTime? nowOverride,
  }) async {
    await cancelActiveBreakReminders();

    final prefs = user.notifications;
    if (prefs == null || !prefs.enabled || !prefs.activeBreakReminderEnabled) {
      return 0;
    }

    if (!prefs.isValidActiveBreakRange || !prefs.isValidInterval) {
      return 0;
    }

    final intervalMinutes = prefs.activeBreakIntervalMinutes;
    final startParts = prefs.activeBreakStartTime.split(':');
    final endParts = prefs.activeBreakEndTime.split(':');

    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    final nowTz = nowOverride != null
        ? tz.TZDateTime.from(nowOverride, tz.local)
        : tz.TZDateTime.now(tz.local);

    int scheduledCount = 0;

    // Rolling window of 3 days (today, tomorrow, day after tomorrow)
    for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
      final currentDay = nowTz.add(Duration(days: dayOffset));
      var breakTime = tz.TZDateTime(
        tz.local,
        currentDay.year,
        currentDay.month,
        currentDay.day,
        startHour,
        startMinute,
      );
      final dayEndTime = tz.TZDateTime(
        tz.local,
        currentDay.year,
        currentDay.month,
        currentDay.day,
        endHour,
        endMinute,
      );

      // Boundary: inclusive (startTime <= breakTime <= dayEndTime)
      while (breakTime.isBefore(dayEndTime) ||
          breakTime.isAtSameMomentAs(dayEndTime)) {
        if (breakTime.isAfter(nowTz)) {
          if (scheduledCount >= maxActiveBreakSlots) {
            break;
          }
          final id = activeBreakIdBase + 1 + scheduledCount;
          await _adapter.zonedSchedule(
            id,
            'Active Break',
            'Time to move! Take a short active break.',
            breakTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'active_break_channel',
                'Active Breaks',
                channelDescription: 'Recurring active break reminders',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduledCount++;
        }
        breakTime = breakTime.add(Duration(minutes: intervalMinutes));
      }
      if (scheduledCount >= maxActiveBreakSlots) break;
    }

    return scheduledCount;
  }
}
