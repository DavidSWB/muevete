import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/l10n/app_localizations_en.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final _l10n = AppLocalizationsEn();

final _user = UserModel(
  id: 'test-user',
  email: 'test@example.com',
  username: 'Tester',
  training: UserTraining(
    activePlanId: 'plan-1',
    planStartDate: DateTime(2026, 10, 1),
    schedule: const UserSchedule(days: {1: 1, 3: 2}, preferredTime: '18:00'),
  ),
  notifications: const UserNotifications(
    enabled: true,
    trainingReminderEnabled: true,
    activeBreakReminderEnabled: false,
    activeBreakStartTime: '08:00',
    activeBreakEndTime: '18:00',
    activeBreakIntervalMinutes: 120,
  ),
);

void main() {
  late _Adapter adapter;
  late _Repository repository;

  setUpAll(tz.initializeTimeZones);

  setUp(() {
    adapter = _Adapter();
    repository = _Repository();
    NotificationScheduler.setAdapterForTesting(adapter);
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  tearDown(NotificationScheduler.resetForTesting);

  Future<void> save(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(_l10n.notifSavePreferences), 200);
    await tester.tap(find.text(_l10n.notifSavePreferences));
    await tester.pumpAndSettle();
  }

  testWidgets('a plugin failure keeps the preferences and says reminders failed',
      (tester) async {
    // What the release build threw on a physical phone.
    adapter.failure = PlatformException(
      code: 'error',
      message: 'Missing type parameter.',
    );

    await save(tester);

    expect(repository.saved, hasLength(1));
    expect(find.text(_l10n.notifErrorSchedule), findsOneWidget);
    expect(find.text(_l10n.notifSavedSuccess), findsNothing);
  });

  testWidgets('a failure with notifications off points at the permission',
      (tester) async {
    adapter.failure = PlatformException(code: 'error');
    adapter.permission = false;

    await save(tester);

    expect(repository.saved, hasLength(1));
    expect(find.text(_l10n.notifErrorScheduleNoPermission), findsOneWidget);
    expect(find.text(_l10n.notifErrorSchedule), findsNothing);
  });

  testWidgets('success is reported only once reminders are scheduled',
      (tester) async {
    await save(tester);

    expect(repository.saved, hasLength(1));
    expect(adapter.scheduled, isNotEmpty);
    expect(find.text(_l10n.notifSavedSuccess), findsOneWidget);
    expect(find.text(_l10n.notifErrorSchedule), findsNothing);
  });

  testWidgets('a failed save is not reported as saved', (tester) async {
    repository.fail = true;

    await save(tester);

    expect(find.text(_l10n.notifErrorSave), findsOneWidget);
    expect(find.text(_l10n.notifSavedSuccess), findsNothing);
  });

  test('the provider stores the preferences before rethrowing the failure',
      () async {
    adapter.failure = PlatformException(code: 'error');
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(profileProvider.future);

    await expectLater(
      container
          .read(profileProvider.notifier)
          .saveNotificationPreferences(_user.notifications!),
      throwsA(
        isA<NotificationSchedulingException>().having(
          (e) => e.error,
          'error',
          isA<PlatformException>(),
        ),
      ),
    );
    expect(repository.saved, hasLength(1));
  });
}

class _Adapter implements NotificationPluginAdapter {
  final Set<int> scheduled = {};
  bool permission = true;
  Object? failure;

  @override
  Future<void> initialize({void Function(NotificationResponse)? onTap}) async {}

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<bool> checkPermissionStatus() async => permission;

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
  }) async {
    if (failure != null) throw failure!;
    scheduled.add(id);
  }

  @override
  Future<void> cancel(int id) async {
    if (failure != null) throw failure!;
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
      const [];

  @override
  Future<NotificationResponse?> launchResponse() async => null;
}

class _Repository implements ProfileRepository {
  final List<UserModel> saved = [];
  bool fail = false;

  @override
  Future<UserModel> getProfile() async => _user;

  @override
  Future<void> saveProfile(UserModel user) async {
    if (fail) throw StateError('offline');
    saved.add(user);
  }

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) =>
      throw UnimplementedError();

  @override
  Future<void> createProfile(UserModel user) => throw UnimplementedError();

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) => throw UnimplementedError();
}
