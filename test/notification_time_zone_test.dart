import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_timezone');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    NotificationScheduler.resetForTesting();
  });

  Future<void> initializeWithDeviceZone(Object? reply) async {
    messenger.setMockMethodCallHandler(channel, (call) async => reply);
    await NotificationScheduler.initialize(adapter: _NoopAdapter());
  }

  test('reminders are scheduled in the device time zone', () async {
    await initializeWithDeviceZone('America/Bogota');

    expect(tz.local.name, 'America/Bogota');
  });

  test('the time zone is read from the structured platform reply', () async {
    await initializeWithDeviceZone({
      'identifier': 'Europe/Madrid',
      'localizedName': 'Central European Standard Time',
      'locale': 'en',
    });

    expect(tz.local.name, 'Europe/Madrid');
  });

  test('an unknown time zone falls back to UTC', () async {
    await initializeWithDeviceZone('Not/AZone');

    expect(tz.local.name, 'UTC');
  });
}

class _NoopAdapter extends NotificationPluginAdapter {
  @override
  Future<void> initialize({
    void Function(NotificationResponse)? onTap,
  }) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> checkPermissionStatus() async => true;

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
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}
