import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> rescheduleAll(UserModel user) async {
    await _notificationsPlugin.cancelAll();

    if (user.notifications == null || !user.notifications!.enabled) {
      return;
    }

    if (user.notifications!.trainingReminderEnabled &&
        user.training?.schedule != null) {
      await _scheduleTrainingReminders(user);
    }

    if (user.notifications!.activeBreakReminderEnabled) {
      await _scheduleActiveBreaks(user);
    }
  }

  static Future<void> _scheduleTrainingReminders(UserModel user) async {
    final schedule = user.training!.schedule!;
    if (schedule.days.isEmpty || schedule.preferredTime == null) return;

    final timeParts = schedule.preferredTime!.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 9;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    for (final entry in schedule.days.entries) {
      final weekday = entry.key; // 1=Mon, 7=Sun
      
      // We calculate the next occurrence of this weekday
      var now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      
      while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        100 + weekday, // Unique ID per day
        'Time to train!',
        'Your scheduled training session is coming up.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'training_channel',
            'Training Reminders',
            channelDescription: 'Reminders for your scheduled workouts',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> _scheduleActiveBreaks(UserModel user) async {
    final prefs = user.notifications!;
    final intervalStr = prefs.activeBreakIntervalMinutes ?? 120;
    
    final startParts = (prefs.activeBreakStartTime ?? '08:00').split(':');
    final endParts = (prefs.activeBreakEndTime ?? '18:00').split(':');
    
    final startHour = int.tryParse(startParts[0]) ?? 8;
    final endHour = int.tryParse(endParts[0]) ?? 18;

    // Schedule active breaks for the next 7 days
    int idCounter = 200;
    final now = tz.TZDateTime.now(tz.local);
    
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      var currentDay = tz.TZDateTime(tz.local, now.year, now.month, now.day).add(Duration(days: dayOffset));
      
      var breakTime = tz.TZDateTime(tz.local, currentDay.year, currentDay.month, currentDay.day, startHour);
      final endTime = tz.TZDateTime(tz.local, currentDay.year, currentDay.month, currentDay.day, endHour);
      
      while (breakTime.isBefore(endTime)) {
        if (breakTime.isAfter(now)) {
          await _notificationsPlugin.zonedSchedule(
            idCounter++,
            'Active Break',
            'Time to move! Take a short active break.',
            breakTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'active_break_channel',
                'Active Breaks',
                channelDescription: 'Recurring active break reminders',
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
        breakTime = breakTime.add(Duration(minutes: intervalStr));
      }
    }
  }
}
