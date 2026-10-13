import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/settings/presentation/screens/notification_settings_screen.dart';

void main() {
  testWidgets('NotificationSettingsScreen displays preferences and schedule',
      (WidgetTester tester) async {
    final testUser = UserModel(
      id: 'test-user-1',
      email: 'test@example.com',
      username: 'Tester',
      training: UserTraining(
        activePlanId: 'plan-1',
        planStartDate: DateTime(2026, 10, 1),
        schedule: const UserSchedule(
          days: {1: 1, 3: 2, 5: 3},
          preferredTime: '18:00',
        ),
      ),
      notifications: const UserNotifications(
        enabled: true,
        trainingReminderEnabled: true,
        activeBreakReminderEnabled: true,
        activeBreakStartTime: '08:00',
        activeBreakEndTime: '18:00',
        activeBreakIntervalMinutes: 120,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(testUser),
          ),
        ],
        child: const MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Training Reminders'), findsOneWidget);
    expect(find.text('Active-Break Reminders'), findsOneWidget);
    expect(find.text('Days: Monday, Wednesday, Friday'), findsOneWidget);
    expect(find.text('Time: 18:00'), findsOneWidget);
    expect(find.text('Start Time'), findsOneWidget);
    expect(find.text('End Time'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('18:00'), findsOneWidget);
    
    await tester.scrollUntilVisible(find.text('Save Preferences'), 200);
    expect(find.text('Save Preferences'), findsOneWidget);
  });

  testWidgets('NotificationSettingsScreen guides user when schedule is missing',
      (WidgetTester tester) async {
    final testUser = UserModel(
      id: 'test-user-2',
      email: 'test@example.com',
      username: 'Tester',
      training: null,
      notifications: const UserNotifications(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(
            () => _FakeProfileNotifier(testUser),
          ),
        ],
        child: const MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No Active Training Schedule'), findsOneWidget);
    expect(find.text('Configure Program'), findsOneWidget);
  });
}

class _FakeProfileNotifier extends Profile {
  final UserModel _user;
  _FakeProfileNotifier(this._user);

  @override
  Future<UserModel> build() async {
    return _user;
  }
}
