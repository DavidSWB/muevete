import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/app/home_screen.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/active_breaks/presentation/screens/active_breaks_screen.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/presentation/providers/next_training_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_launcher.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void useScreen(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Home shows Active Breaks above the health card', (
    tester,
  ) async {
    useScreen(tester, const Size(400, 2400));
    // HomeScreen is a MainScreen tab, so it relies on MainScreen's Scaffold.
    await tester.pumpWidget(_app(const Scaffold(body: HomeScreen())));
    await tester.pumpAndSettle();

    final activeBreaks = tester.getTopLeft(_anchor('home.activeBreaks')).dy;
    final health = tester.getTopLeft(_anchor('home.health')).dy;
    final weeklyStats = tester.getTopLeft(_anchor('home.weeklyStats')).dy;

    expect(weeklyStats, lessThan(activeBreaks));
    expect(activeBreaks, lessThan(health));
  });

  testWidgets('the Breaks tab opens the existing Active Breaks page', (
    tester,
  ) async {
    useScreen(tester, const Size(400, 900));
    final container = _container();
    await tester.pumpWidget(_app(const MainScreen(), container: container));
    await tester.pumpAndSettle();

    final destinations = find.byType(NavigationDestination);
    expect(destinations, findsNWidgets(5));
    expect(
      tester
          .widgetList<NavigationDestination>(destinations)
          .map((destination) => destination.label),
      ['Home', 'Training', 'Breaks', 'Progress', 'Settings'],
    );

    await tester.tap(find.text('Breaks'));
    await tester.pumpAndSettle();

    expect(container.read(mainNavIndexProvider), MainScreen.activeBreaksTab);
    expect(
      find.byType(ActiveBreaksScreen, skipOffstage: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(container.read(mainNavIndexProvider), MainScreen.progressTab);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(container.read(mainNavIndexProvider), MainScreen.settingsTab);
  });

  for (final locale in const [Locale('es'), Locale('en')]) {
    testWidgets('five tabs fit a 320 dp screen in ${locale.languageCode}', (
      tester,
    ) async {
      useScreen(tester, const Size(320, 640));
      // Keep the tabs loading so only the navigation bar is laid out with
      // content: this checks the tab labels, not the Home cards, whose text
      // is far wider in the test font than on a device.
      await tester.pumpWidget(
        _app(
          const MainScreen(),
          container: _container(loadingContent: true),
          locale: locale,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });
  }
}

Finder _anchor(String id) => find.byWidgetPredicate(
  (widget) => widget is WalkthroughAnchor && widget.id == id,
);

ProviderContainer _container({bool loadingContent = false}) {
  final container = ProviderContainer(
    overrides: [
      walkthroughStoreProvider.overrideWithValue(_MemoryStore()),
      walkthroughUserIdProvider.overrideWithValue('u'),
      // Already checked, so the launcher does not offer the tour.
      walkthroughCheckedUsersProvider.overrideWithValue({'u'}),
      profileProvider.overrideWith(
        loadingContent ? _LoadingProfile.new : _FakeProfile.new,
      ),
      nextTrainingProvider.overrideWith(
        (ref) async =>
            const PlanDay(day: 1, name: {'en': 'Day 1'}, exercises: []),
      ),
      workoutControllerProvider.overrideWith(
        loadingContent
            ? _LoadingWorkoutController.new
            : _FixedWorkoutController.new,
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(
  Widget home, {
  ProviderContainer? container,
  Locale locale = const Locale('en'),
}) {
  return UncontrolledProviderScope(
    container: container ?? _container(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: home,
    ),
  );
}

class _FakeProfile extends Profile {
  @override
  Future<UserModel> build() async => UserModel(
    id: 'u',
    email: 'user@example.com',
    username: 'user',
    training: UserTraining(
      activePlanId: 'plan-1',
      planStartDate: DateTime(2026, 10, 1),
      schedule: const UserSchedule(days: {1: 1, 3: 2}, preferredTime: '18:00'),
    ),
  );
}

class _LoadingProfile extends Profile {
  @override
  Future<UserModel> build() => Completer<UserModel>().future;
}

class _LoadingWorkoutController extends WorkoutController {
  @override
  Future<Workout> build() => Completer<Workout>().future;
}

class _FixedWorkoutController extends WorkoutController {
  @override
  Future<Workout> build() async =>
      const Workout(exercises: [], day: 1, name: {'en': 'Day 1'});
}

class _MemoryStore implements WalkthroughStore {
  final Map<String, WalkthroughProgress> data = {};

  @override
  Future<WalkthroughProgress?> load(String uid) async => data[uid];

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async =>
      data[uid] = progress;

  @override
  Future<void> clear(String uid) async => data.remove(uid);
}
