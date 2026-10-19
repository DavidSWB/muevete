import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/localization/presentation/locale_provider.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FakeNotificationPluginAdapter implements NotificationPluginAdapter {
  final Map<int, Map<String, dynamic>> scheduled = {};

  @override
  Future<void> initialize() async {}

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
  }) async {
    scheduled[id] = {
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
    };
  }

  @override
  Future<void> cancel(int id) async {
    scheduled.remove(id);
  }

  @override
  Future<void> showNow(
    int id,
    String? title,
    String? body,
    NotificationDetails notificationDetails,
  ) async {}

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async =>
      const <PendingNotificationRequest>[];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalizedMapX Extension', () {
    test('returns exact language match for es and en', () {
      final map = {
        'es': 'Sentadilla',
        'en': 'Squat',
      };

      expect(map.localizedWithCode('es'), equals('Sentadilla'));
      expect(map.localizedWithCode('en'), equals('Squat'));
    });

    test('falls back to Spanish when requested language is absent', () {
      final map = {
        'es': 'Descanso activo',
      };

      expect(map.localizedWithCode('en'), equals('Descanso activo'));
      expect(map.localizedWithCode('fr'), equals('Descanso activo'));
    });

    test('falls back to English when Spanish is absent', () {
      final map = {
        'en': 'Active Break',
      };

      expect(map.localizedWithCode('es'), equals('Active Break'));
      expect(map.localizedWithCode('fr'), equals('Active Break'));
    });

    test('falls back to first non-empty entry if neither es nor en is present', () {
      final map = {
        'pt': 'Alongamento',
      };

      expect(map.localizedWithCode('es'), equals('Alongamento'));
      expect(map.localizedWithCode('en'), equals('Alongamento'));
    });

    test('returns fallback string when map is empty or null', () {
      const Map<String, String>? nullMap = null;
      final emptyMap = <String, String>{};

      expect(nullMap.localizedWithCode('es', fallback: 'Default'), equals('Default'));
      expect(emptyMap.localizedWithCode('en', fallback: 'N/A'), equals('N/A'));
    });
  });

  group('resolveDeviceLocale', () {
    test('resolves Spanish locale to es', () {
      expect(resolveDeviceLocale(const Locale('es')), equals(const Locale('es')));
      expect(resolveDeviceLocale(const Locale('es', 'CO')), equals(const Locale('es')));
    });

    test('resolves English locale to en', () {
      expect(resolveDeviceLocale(const Locale('en')), equals(const Locale('en')));
      expect(resolveDeviceLocale(const Locale('en', 'US')), equals(const Locale('en')));
    });

    test('defaults unsupported locales to es', () {
      expect(resolveDeviceLocale(const Locale('fr')), equals(const Locale('es')));
      expect(resolveDeviceLocale(const Locale('de')), equals(const Locale('es')));
      expect(resolveDeviceLocale(const Locale('zh')), equals(const Locale('es')));
    });
  });

  group('localeProvider & SharedPreferences persistence', () {
    test('loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'user_selected_locale': 'en',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger build and wait for async read
      final initialLocale = container.read(localeProvider);
      expect(initialLocale, isA<Locale>());

      // Allow async load to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final loadedLocale = container.read(localeProvider);
      expect(loadedLocale.languageCode, equals('en'));
    });

    test('persists updated locale when setLocale is called', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(localeProvider.notifier);
      await notifier.setLocale(const Locale('en'));

      expect(container.read(localeProvider).languageCode, equals('en'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_selected_locale'), equals('en'));

      await notifier.setLocale(const Locale('es'));
      expect(container.read(localeProvider).languageCode, equals('es'));
      expect(prefs.getString('user_selected_locale'), equals('es'));
    });

    test('toggleLocale switches between es and en', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(localeProvider.notifier);
      await notifier.setLocale(const Locale('es'));
      expect(container.read(localeProvider).languageCode, equals('es'));

      await notifier.toggleLocale();
      expect(container.read(localeProvider).languageCode, equals('en'));

      await notifier.toggleLocale();
      expect(container.read(localeProvider).languageCode, equals('es'));
    });
  });

  group('NotificationScheduler Locale Support', () {
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

    final testUser = UserModel(
      id: 'test-user',
      email: 'test@example.com',
      username: 'tester',
      notifications: const UserNotifications(
        enabled: true,
        trainingReminderEnabled: true,
        activeBreakReminderEnabled: true,
        activeBreakIntervalMinutes: 60,
        activeBreakStartTime: '08:00',
        activeBreakEndTime: '18:00',
      ),
      training: UserTraining(
        activePlanId: 'plan-1',
        planStartDate: DateTime(2026, 10, 1),
        schedule: const UserSchedule(
          preferredTime: '08:00',
          days: {1: 1, 3: 2}, // Mon -> Session 1, Wed -> Session 2
        ),
      ),
    );

    test('schedules training reminders in Spanish when locale is es', () async {
      await NotificationScheduler.scheduleTrainingReminders(
        testUser,
        locale: const Locale('es'),
      );

      final mondayNotif = fakeAdapter.scheduled[1001];
      expect(mondayNotif, isNotNull);
      expect(mondayNotif!['title'], equals('¡Hora de entrenar!'));
      expect(mondayNotif['body'], contains('Sesión 1'));
    });

    test('schedules training reminders in English when locale is en', () async {
      await NotificationScheduler.scheduleTrainingReminders(
        testUser,
        locale: const Locale('en'),
      );

      final mondayNotif = fakeAdapter.scheduled[1001];
      expect(mondayNotif, isNotNull);
      expect(mondayNotif!['title'], equals('Time to train!'));
      expect(mondayNotif['body'], contains('Session 1'));
    });

    test('schedules active breaks in Spanish when locale is es', () async {
      final now = DateTime.utc(2026, 10, 19, 7, 0); // before 08:00
      await NotificationScheduler.scheduleActiveBreaks(
        testUser,
        nowOverride: now,
        locale: const Locale('es'),
      );

      final breakNotif = fakeAdapter.scheduled[2001];
      expect(breakNotif, isNotNull);
      expect(breakNotif!['title'], equals('Pausa activa'));
      expect(breakNotif['body'], contains('¡Hora de moverte!'));
    });

    test('schedules active breaks in English when locale is en', () async {
      final now = DateTime.utc(2026, 10, 19, 7, 0); // before 08:00
      await NotificationScheduler.scheduleActiveBreaks(
        testUser,
        nowOverride: now,
        locale: const Locale('en'),
      );

      final breakNotif = fakeAdapter.scheduled[2001];
      expect(breakNotif, isNotNull);
      expect(breakNotif!['title'], equals('Active Break'));
      expect(breakNotif['body'], contains('Time to move!'));
    });
  });

  group('LocaleSwitcher Widget Test', () {
    testWidgets('renders compact switcher and responds to tap', (tester) async {
      SharedPreferences.setMockInitialValues({'user_selected_locale': 'es'});

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              final activeLocale = ref.watch(localeProvider);
              return MaterialApp(
                locale: activeLocale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: const Scaffold(
                  body: Center(
                    child: LocaleSwitcher(compact: true),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In compact mode with 'es', badge displays 'ES'
      expect(find.text('ES'), findsOneWidget);

      // Tap to toggle locale
      await tester.tap(find.byType(LocaleSwitcher));
      await tester.pumpAndSettle();

      // Now locale is 'en', badge displays 'EN'
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('renders standard segmented switcher and responds to selection', (tester) async {
      SharedPreferences.setMockInitialValues({'user_selected_locale': 'es'});

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              final activeLocale = ref.watch(localeProvider);
              return MaterialApp(
                locale: activeLocale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: const Scaffold(
                  body: Center(
                    child: LocaleSwitcher(compact: false),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ES'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);

      // Tap EN segment
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      // Verify locale changed in provider
      final element = tester.element(find.byType(LocaleSwitcher));
      final container = ProviderScope.containerOf(element);
      expect(container.read(localeProvider).languageCode, equals('en'));
    });
  });
}
