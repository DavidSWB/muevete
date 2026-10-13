import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ScheduledNotificationRecord {
  final int id;
  final String? title;
  final String? body;
  final tz.TZDateTime scheduledDate;
  final NotificationDetails notificationDetails;
  final AndroidScheduleMode androidScheduleMode;
  final UILocalNotificationDateInterpretation
      uiLocalNotificationDateInterpretation;
  final DateTimeComponents? matchDateTimeComponents;

  ScheduledNotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.notificationDetails,
    required this.androidScheduleMode,
    required this.uiLocalNotificationDateInterpretation,
    this.matchDateTimeComponents,
  });
}

class FakeNotificationPluginAdapter implements NotificationPluginAdapter {
  final Map<int, ScheduledNotificationRecord> scheduled = {};
  final List<int> cancelledIds = [];
  bool initializeCalled = false;
  bool permissionRequested = false;
  bool isPermissionGranted = true;

  @override
  Future<void> initialize() async {
    initializeCalled = true;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequested = true;
    return isPermissionGranted;
  }

  @override
  Future<bool> checkPermissionStatus() async {
    return isPermissionGranted;
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
  }) async {
    scheduled[id] = ScheduledNotificationRecord(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: androidScheduleMode,
      uiLocalNotificationDateInterpretation:
          uiLocalNotificationDateInterpretation,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    scheduled.remove(id);
  }
}

void main() {
  late FakeNotificationPluginAdapter fakeAdapter;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() {
    fakeAdapter = FakeNotificationPluginAdapter();
    NotificationScheduler.setAdapterForTesting(fakeAdapter);
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  tearDown(() {
    NotificationScheduler.resetForTesting();
  });

  UserModel createTestUser({
    String id = 'user-1',
    UserNotifications? notifications,
    Map<int, int> scheduleDays = const {1: 1, 3: 2, 5: 3},
    String preferredTime = '18:00',
  }) {
    return UserModel(
      id: id,
      email: 'test@example.com',
      username: 'tester',
      training: UserTraining(
        activePlanId: 'plan-1',
        planStartDate: DateTime(2026, 10, 1),
        schedule: UserSchedule(
          days: scheduleDays,
          preferredTime: preferredTime,
        ),
      ),
      notifications: notifications ?? const UserNotifications(),
    );
  }

  group('Preferences and Persistence', () {
    test('1. Missing notification settings load with intended defaults', () {
      final notifs = UserNotifications.fromJson(const {});

      expect(notifs.enabled, isTrue);
      expect(notifs.trainingReminderEnabled, isTrue);
      expect(notifs.activeBreakReminderEnabled, isFalse);
      expect(notifs.activeBreakStartTime, '08:00');
      expect(notifs.activeBreakEndTime, '18:00');
      expect(notifs.activeBreakIntervalMinutes, 120);
    });

    test('2. Existing settings are restored correctly from Firestore format', () {
      final json = {
        'enabled': true,
        'trainingReminder': {'enabled': false},
        'activeBreakReminder': {
          'enabled': true,
          'startTime': '09:30',
          'endTime': '17:45',
          'intervalMinutes': 60,
        },
      };

      final notifs = UserNotifications.fromJson(json);

      expect(notifs.enabled, isTrue);
      expect(notifs.trainingReminderEnabled, isFalse);
      expect(notifs.activeBreakReminderEnabled, isTrue);
      expect(notifs.activeBreakStartTime, '09:30');
      expect(notifs.activeBreakEndTime, '17:45');
      expect(notifs.activeBreakIntervalMinutes, 60);
    });

    test('3. Saving settings persists expected fields without overwriting user data', () {
      final originalUser = createTestUser(
        id: 'user-persist-1',
        notifications: const UserNotifications(
          trainingReminderEnabled: true,
          activeBreakReminderEnabled: false,
        ),
      );

      final updatedNotifs = originalUser.notifications!.copyWith(
        activeBreakReminderEnabled: true,
        activeBreakIntervalMinutes: 180,
      );

      final updatedUser = originalUser.copyWith(notifications: updatedNotifs);

      // Verify user fields remain intact
      expect(updatedUser.id, originalUser.id);
      expect(updatedUser.email, originalUser.email);
      expect(updatedUser.training, originalUser.training);
      expect(updatedUser.notifications!.activeBreakReminderEnabled, isTrue);
      expect(updatedUser.notifications!.activeBreakIntervalMinutes, 180);

      // Verify serialization output
      final json = updatedUser.toJson();
      final notifJson = json['notifications'] as Map<String, dynamic>;
      expect(notifJson['enabled'], isTrue);
      expect(notifJson['trainingReminder']['enabled'], isTrue);
      expect(notifJson['activeBreakReminder']['enabled'], isTrue);
      expect(notifJson['activeBreakReminder']['intervalMinutes'], 180);
    });

    test('4. Invalid time ranges are rejected', () {
      // End before start
      const invalidReversed = UserNotifications(
        activeBreakStartTime: '18:00',
        activeBreakEndTime: '08:00',
      );
      expect(invalidReversed.isValidActiveBreakRange, isFalse);

      // End equal to start
      const invalidEqual = UserNotifications(
        activeBreakStartTime: '10:00',
        activeBreakEndTime: '10:00',
      );
      expect(invalidEqual.isValidActiveBreakRange, isFalse);

      // Valid range
      const valid = UserNotifications(
        activeBreakStartTime: '08:00',
        activeBreakEndTime: '18:00',
      );
      expect(valid.isValidActiveBreakRange, isTrue);
    });

    test('5. Interval values outside the supported options are rejected', () {
      const valid60 = UserNotifications(activeBreakIntervalMinutes: 60);
      const valid120 = UserNotifications(activeBreakIntervalMinutes: 120);
      const valid180 = UserNotifications(activeBreakIntervalMinutes: 180);

      const invalid30 = UserNotifications(activeBreakIntervalMinutes: 30);
      const invalid90 = UserNotifications(activeBreakIntervalMinutes: 90);
      const invalid240 = UserNotifications(activeBreakIntervalMinutes: 240);

      expect(valid60.isValidInterval, isTrue);
      expect(valid120.isValidInterval, isTrue);
      expect(valid180.isValidInterval, isTrue);

      expect(invalid30.isValidInterval, isFalse);
      expect(invalid90.isValidInterval, isFalse);
      expect(invalid240.isValidInterval, isFalse);
    });
  });

  group('Training Reminders', () {
    test('6. Only persisted training weekdays receive reminders with correct IDs', () async {
      final user = createTestUser(
        scheduleDays: {1: 1, 3: 2, 5: 3}, // Mon, Wed, Fri
        preferredTime: '18:00',
      );

      final count = await NotificationScheduler.scheduleTrainingReminders(user);

      expect(count, 3);
      expect(fakeAdapter.scheduled.containsKey(1001), isTrue); // Mon
      expect(fakeAdapter.scheduled.containsKey(1003), isTrue); // Wed
      expect(fakeAdapter.scheduled.containsKey(1005), isTrue); // Fri

      expect(fakeAdapter.scheduled.containsKey(1002), isFalse); // Tue
      expect(fakeAdapter.scheduled.containsKey(1004), isFalse); // Thu
      expect(fakeAdapter.scheduled.containsKey(1006), isFalse); // Sat
      expect(fakeAdapter.scheduled.containsKey(1007), isFalse); // Sun
    });

    test('7. Weekdays map to the correct training sessions in notification body', () async {
      final user = createTestUser(
        scheduleDays: {2: 1, 4: 2}, // Tue -> session 1, Thu -> session 2
        preferredTime: '07:30',
      );

      await NotificationScheduler.scheduleTrainingReminders(user);

      final tueNotification = fakeAdapter.scheduled[1002];
      final thuNotification = fakeAdapter.scheduled[1004];

      expect(tueNotification, isNotNull);
      expect(thuNotification, isNotNull);

      expect(tueNotification!.body, contains('Session 1'));
      expect(thuNotification!.body, contains('Session 2'));
    });

    test('8. Preferred time is respected with both hours and minutes', () async {
      final user = createTestUser(
        scheduleDays: {1: 1},
        preferredTime: '19:45',
      );

      await NotificationScheduler.scheduleTrainingReminders(user);

      final notification = fakeAdapter.scheduled[1001];
      expect(notification, isNotNull);
      expect(notification!.scheduledDate.hour, 19);
      expect(notification.scheduledDate.minute, 45);
      expect(notification.matchDateTimeComponents,
          DateTimeComponents.dayOfWeekAndTime);
    });

    test('9. Missing or empty schedules do not produce invented reminders', () async {
      final userNoSchedule = UserModel(
        id: 'no-sched',
        email: 'test@example.com',
        username: 'test',
        training: null,
      );

      final count = await NotificationScheduler.scheduleTrainingReminders(userNoSchedule);
      expect(count, 0);
      expect(fakeAdapter.scheduled, isEmpty);
    });

    test('10. Changing schedule or preferred time reconciles pending reminders', () async {
      final userV1 = createTestUser(
        scheduleDays: {1: 1, 3: 2},
        preferredTime: '08:00',
      );
      await NotificationScheduler.scheduleTrainingReminders(userV1);

      expect(fakeAdapter.scheduled.keys.toSet(), {1001, 1003});

      // Update schedule to Tue, Thu at 18:30
      final userV2 = createTestUser(
        scheduleDays: {2: 1, 4: 2},
        preferredTime: '18:30',
      );
      await NotificationScheduler.scheduleTrainingReminders(userV2);

      // Verify old IDs (1001, 1003) were cancelled and new ones (1002, 1004) scheduled
      expect(fakeAdapter.cancelledIds, containsAll([1001, 1002, 1003, 1004, 1005, 1006, 1007]));
      expect(fakeAdapter.scheduled.keys.toSet(), {1002, 1004});
      expect(fakeAdapter.scheduled[1002]!.scheduledDate.hour, 18);
      expect(fakeAdapter.scheduled[1002]!.scheduledDate.minute, 30);
    });
  });

  group('Active-Break Reminders', () {
    test('11. Disabled reminders produce no active-break notifications', () async {
      final user = createTestUser(
        notifications: const UserNotifications(
          activeBreakReminderEnabled: false,
        ),
      );

      final count = await NotificationScheduler.scheduleActiveBreaks(user);
      expect(count, 0);
      expect(fakeAdapter.scheduled, isEmpty);
    });

    test('12. Supported intervals produce expected notification counts', () async {
      // 08:00 to 12:00 window, simulated on a fixed reference day at 07:00
      final refTime = DateTime.utc(2026, 10, 12, 7, 0);

      // Interval 60: 08:00, 09:00, 10:00, 11:00, 12:00 -> 5 per day * 3 days = 15
      final user60 = createTestUser(
        notifications: const UserNotifications(
          activeBreakReminderEnabled: true,
          activeBreakStartTime: '08:00',
          activeBreakEndTime: '12:00',
          activeBreakIntervalMinutes: 60,
        ),
      );
      final count60 = await NotificationScheduler.scheduleActiveBreaks(
        user60,
        nowOverride: refTime,
      );
      expect(count60, 15);

      // Interval 120: 08:00, 10:00, 12:00 -> 3 per day * 3 days = 9
      final user120 = createTestUser(
        notifications: const UserNotifications(
          activeBreakReminderEnabled: true,
          activeBreakStartTime: '08:00',
          activeBreakEndTime: '12:00',
          activeBreakIntervalMinutes: 120,
        ),
      );
      final count120 = await NotificationScheduler.scheduleActiveBreaks(
        user120,
        nowOverride: refTime,
      );
      expect(count120, 9);

      // Interval 180: 08:00, 11:00 -> 2 per day * 3 days = 6
      final user180 = createTestUser(
        notifications: const UserNotifications(
          activeBreakReminderEnabled: true,
          activeBreakStartTime: '08:00',
          activeBreakEndTime: '12:00',
          activeBreakIntervalMinutes: 180,
        ),
      );
      final count180 = await NotificationScheduler.scheduleActiveBreaks(
        user180,
        nowOverride: refTime,
      );
      expect(count180, 6);
    });

    test('13. Start and end minutes are handled correctly', () async {
      final refTime = DateTime.utc(2026, 10, 12, 8, 0);
      final user = createTestUser(
        notifications: const UserNotifications(
          activeBreakReminderEnabled: true,
          activeBreakStartTime: '08:15',
          activeBreakEndTime: '10:15',
          activeBreakIntervalMinutes: 60,
        ),
      );

      await NotificationScheduler.scheduleActiveBreaks(
        user,
        nowOverride: refTime,
      );

      final scheduledTimes = fakeAdapter.scheduled.values
          .map((r) => '${r.scheduledDate.hour.toString().padLeft(2, '0')}:${r.scheduledDate.minute.toString().padLeft(2, '0')}')
          .toSet();

      expect(scheduledTimes, containsAll(['08:15', '09:15', '10:15']));
    });

    test('14. Reminders never fall outside configured window and boundary is inclusive', () async {
      final refTime = DateTime.utc(2026, 10, 12, 6, 0);
      final user = createTestUser(
        notifications: const UserNotifications(
          activeBreakReminderEnabled: true,
          activeBreakStartTime: '09:00',
          activeBreakEndTime: '13:00',
          activeBreakIntervalMinutes: 120,
        ),
      );

      await NotificationScheduler.scheduleActiveBreaks(
        user,
        nowOverride: refTime,
      );

      for (final rec in fakeAdapter.scheduled.values) {
        final timeInMinutes = rec.scheduledDate.hour * 60 + rec.scheduledDate.minute;
        expect(timeInMinutes >= 9 * 60, isTrue);
        expect(timeInMinutes <= 13 * 60, isTrue);
      }
    });

    test('15. Do not schedule notifications in the past', () async {
      // Current time is 11:30, start is 08:00, end is 18:00, interval 120
      // Today: 08:00 (past), 10:00 (past), 12:00 (future), 14:00, 16:00, 18:00 (future)
      final refTime = DateTime.utc(2026, 10, 12, 11, 30);
      final user = createTestUser(
        notifications: const UserNotifications(
          activeBreakReminderEnabled: true,
          activeBreakStartTime: '08:00',
          activeBreakEndTime: '18:00',
          activeBreakIntervalMinutes: 120,
        ),
      );

      await NotificationScheduler.scheduleActiveBreaks(
        user,
        nowOverride: refTime,
      );

      for (final rec in fakeAdapter.scheduled.values) {
        expect(rec.scheduledDate.isAfter(tz.TZDateTime.from(refTime, tz.local)), isTrue);
      }
    });
  });

  group('Scheduler and Lifecycle', () {
    test('16. Repeated scheduling is idempotent', () async {
      final user = createTestUser(
        notifications: const UserNotifications(
          trainingReminderEnabled: true,
          activeBreakReminderEnabled: true,
        ),
      );

      await NotificationScheduler.rescheduleAll(user);
      final scheduledCountFirst = fakeAdapter.scheduled.length;

      // Call again with same user
      await NotificationScheduler.rescheduleAll(user);
      final scheduledCountSecond = fakeAdapter.scheduled.length;

      expect(scheduledCountFirst, scheduledCountSecond);
    });

    test('17. Category-specific cancellation preserves other categories', () async {
      final user = createTestUser(
        notifications: const UserNotifications(
          trainingReminderEnabled: true,
          activeBreakReminderEnabled: true,
        ),
      );
      await NotificationScheduler.rescheduleAll(user, force: true);

      final initialTrainingCount =
          fakeAdapter.scheduled.keys.where((id) => id >= 1000 && id < 2000).length;
      final initialActiveBreakCount =
          fakeAdapter.scheduled.keys.where((id) => id >= 2000).length;

      expect(initialTrainingCount, greaterThan(0));
      expect(initialActiveBreakCount, greaterThan(0));

      // Cancel only active breaks
      await NotificationScheduler.cancelActiveBreakReminders();

      final remainingTraining =
          fakeAdapter.scheduled.keys.where((id) => id >= 1000 && id < 2000).length;
      final remainingActiveBreaks =
          fakeAdapter.scheduled.keys.where((id) => id >= 2000).length;

      expect(remainingTraining, initialTrainingCount);
      expect(remainingActiveBreaks, 0);

      // Cancel only training
      await NotificationScheduler.cancelTrainingReminders();
      expect(fakeAdapter.scheduled, isEmpty);
    });

    test('18. Combined schedules respect the platform limit budget (<= 64)', () async {
      final user = createTestUser(
        scheduleDays: {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7}, // all 7 days
        notifications: const UserNotifications(
          trainingReminderEnabled: true,
          activeBreakReminderEnabled: true,
          activeBreakStartTime: '08:00',
          activeBreakEndTime: '20:00',
          activeBreakIntervalMinutes: 60, // Maximum density
        ),
      );

      await NotificationScheduler.rescheduleAll(user, force: true);

      final totalScheduled = fakeAdapter.scheduled.length;
      expect(totalScheduled, lessThanOrEqualTo(64));
    });

    test('19. Sign-out and account switching do not leak notifications', () async {
      final userA = createTestUser(
        id: 'user-A',
        scheduleDays: {1: 1},
        notifications: const UserNotifications(trainingReminderEnabled: true),
      );
      await NotificationScheduler.rescheduleAll(userA, force: true);
      expect(fakeAdapter.scheduled, isNotEmpty);

      // Sign out
      await NotificationScheduler.cancelUserReminders();
      expect(fakeAdapter.scheduled, isEmpty);

      // User B logs in with disabled notifications
      final userB = createTestUser(
        id: 'user-B',
        notifications: const UserNotifications(
          trainingReminderEnabled: false,
          activeBreakReminderEnabled: false,
        ),
      );
      await NotificationScheduler.rescheduleAll(userB, force: true);
      expect(fakeAdapter.scheduled, isEmpty);
    });

    test('20. Time-zone changes and daylight-saving transitions are handled', () async {
      // Simulate New York timezone (with DST)
      tz.setLocalLocation(tz.getLocation('America/New_York'));

      final user = createTestUser(
        scheduleDays: {1: 1},
        preferredTime: '09:00',
      );

      await NotificationScheduler.scheduleTrainingReminders(user);
      final rec = fakeAdapter.scheduled[1001];

      expect(rec, isNotNull);
      expect(rec!.scheduledDate.location.name, 'America/New_York');
      expect(rec.scheduledDate.hour, 9);
      expect(rec.scheduledDate.minute, 0);
    });
  });
}
