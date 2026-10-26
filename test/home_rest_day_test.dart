import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

// 2026-10-12 is a Monday. The schedule trains Monday and Wednesday.
final _monday = DateTime(2026, 10, 12, 9);
final _tuesday = DateTime(2026, 10, 13, 9);
final _wednesday = DateTime(2026, 10, 14, 9);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a training day keeps the card with the new heading', (
    tester,
  ) async {
    await _pump(tester, now: _monday);

    expect(find.text("TODAY'S WORKOUT"), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Start\nworkout'), findsOneWidget);
    expect(find.text('35 min'), findsOneWidget);
    expect(find.text('REST DAY'), findsNothing);
    expect(find.byKey(const ValueKey('home-rest-advance')), findsNothing);
    expect(find.byKey(const ValueKey('home-done-early')), findsNothing);
    expect(_anchor('home.startWorkout'), findsOneWidget);
  });

  testWidgets('a rest day shows the light-day message and both actions', (
    tester,
  ) async {
    await _pump(tester, now: _tuesday);

    expect(find.text('REST DAY'), findsOneWidget);
    expect(find.text('Rest day!'), findsOneWidget);
    expect(
      find.text(
        'Take time to recover today, and keep moving gently throughout the day.',
      ),
      findsOneWidget,
    );
    expect(find.text('Take an active break'), findsOneWidget);
    expect(find.text('Start next workout early'), findsOneWidget);
    expect(find.text('Day 1'), findsNothing);
    expect(find.text('Start\nworkout'), findsNothing);
    expect(find.text('35 min'), findsNothing);
    // The tour step still has its target.
    expect(_anchor('home.startWorkout'), findsOneWidget);
  });

  testWidgets('advancing opens the Training tab without changing the profile', (
    tester,
  ) async {
    final container = await _pump(tester, now: _tuesday);
    final before = container.read(profileProvider).value;

    await tester.tap(find.byKey(const ValueKey('home-rest-advance')));
    await tester.pumpAndSettle();

    expect(container.read(mainNavIndexProvider), MainScreen.trainingTab);
    expect(container.read(profileProvider).value, same(before));
  });

  testWidgets('the active-break action opens the existing selection page', (
    tester,
  ) async {
    await _pump(tester, now: _tuesday);

    await tester.tap(find.byKey(const ValueKey('home-rest-active-break')));
    await tester.pumpAndSettle();

    expect(find.byType(ActiveBreaksScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('a session done on the rest day before shows "Done early"', (
    tester,
  ) async {
    await _pump(
      tester,
      now: _wednesday,
      user: _user(completedWorkouts: [DateTime(2026, 10, 13, 18)]),
    );

    expect(find.byKey(const ValueKey('home-done-early')), findsOneWidget);
    expect(find.text('Done early'), findsOneWidget);
    expect(find.text("TODAY'S WORKOUT"), findsOneWidget);
    expect(find.text('Start\nworkout'), findsOneWidget);
  });

  testWidgets('a missing schedule never shows a rest day', (tester) async {
    await _pump(tester, now: _tuesday, user: _user(schedule: null));

    expect(find.text("TODAY'S WORKOUT"), findsOneWidget);
    expect(find.text('REST DAY'), findsNothing);
  });

  for (final state in [_NextTraining.loading, _NextTraining.error]) {
    testWidgets('a ${state.name} next workout keeps the training card', (
      tester,
    ) async {
      await _pump(tester, now: _monday, nextTraining: state);

      expect(find.text("TODAY'S WORKOUT"), findsOneWidget);
      expect(find.text('REST DAY'), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets('the rest-day card is in Spanish and fits a small phone', (
    tester,
  ) async {
    await _pump(
      tester,
      now: _tuesday,
      locale: const Locale('es'),
      size: const Size(360, 2400),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('DÍA DE DESCANSO'), findsOneWidget);
    expect(find.text('¡Día ligero!'), findsOneWidget);
    expect(find.text('Hacer una pausa activa'), findsOneWidget);
    expect(find.text('Adelantar próximo entrenamiento'), findsOneWidget);
  });

  testWidgets('the training-day heading is in Spanish', (tester) async {
    await _pump(tester, now: _monday, locale: const Locale('es'));

    expect(find.text('TU ENTRENAMIENTO DE HOY'), findsOneWidget);
    expect(find.text('Comenzar\nentrenamiento'), findsOneWidget);
  });
}

enum _NextTraining { data, loading, error }

Finder _anchor(String id) => find.byWidgetPredicate(
  (widget) => widget is WalkthroughAnchor && widget.id == id,
);

UserModel _user({
  UserSchedule? schedule = const UserSchedule(days: {1: 1, 3: 2}),
  List<DateTime> completedWorkouts = const [],
}) {
  return UserModel(
    id: 'u',
    email: 'user@example.com',
    username: 'user',
    training: UserTraining(
      activePlanId: 'plan-1',
      planStartDate: DateTime(2026, 10, 1),
      schedule: schedule,
    ),
    completedWorkouts: completedWorkouts,
  );
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required DateTime now,
  UserModel? user,
  _NextTraining nextTraining = _NextTraining.data,
  Locale locale = const Locale('en'),
  Size size = const Size(400, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final profile = user ?? _user();
  final container = ProviderContainer(
    overrides: [
      homeClockProvider.overrideWithValue(() => now),
      walkthroughStoreProvider.overrideWithValue(_MemoryStore()),
      walkthroughUserIdProvider.overrideWithValue('u'),
      // Already checked, so the launcher does not offer the tour.
      walkthroughCheckedUsersProvider.overrideWithValue({'u'}),
      profileProvider.overrideWith(() => _FixedProfile(profile)),
      nextTrainingProvider.overrideWith(
        (ref) => switch (nextTraining) {
          _NextTraining.data => Future.value(
            const PlanDay(day: 1, name: {'en': 'Day 1'}, exercises: []),
          ),
          _NextTraining.loading => Completer<PlanDay>().future,
          _NextTraining.error => Future<PlanDay>.error(StateError('offline')),
        },
      ),
      workoutControllerProvider.overrideWith(_FixedWorkoutController.new),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/active-breaks',
        builder: (context, state) => const ActiveBreaksScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return container;
}

class _FixedProfile extends Profile {
  _FixedProfile(this._user);

  final UserModel _user;

  @override
  Future<UserModel> build() async => _user;
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
