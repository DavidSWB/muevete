import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/app/badge_sync_listener.dart';
import 'package:muevete/features/gamification/data/firebase_achievement_repository.dart';
import 'package:muevete/features/gamification/domain/achievement.dart';
import 'package:muevete/features/gamification/domain/achievement_evaluator.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/gamification/presentation/badge_sync.dart';
import 'package:muevete/features/gamification/presentation/gamification_providers.dart';
import 'package:muevete/features/gamification/presentation/medal_case_section.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';

void main() {
  const evaluator = AchievementEvaluator();
  final catalogue = [
    for (final entry in _catalogueJson.entries)
      FirebaseAchievementRepository.parse(entry.key, entry.value),
  ];

  UserModel user({
    int activeBreaks = 0,
    List<DateTime> workouts = const [],
    DateTime? trackedSince,
    List<String> owned = const [],
  }) => UserModel(
    id: 'u',
    email: 'e',
    username: 'n',
    completedActiveBreaks: [
      for (var i = 0; i < activeBreaks; i++) DateTime(2026, 10, 1 + i, 9),
    ],
    completedWorkouts: workouts,
    consistencyTrackedSince: trackedSince,
    unlockedBadgeIds: owned,
  );

  Set<String> earned(UserModel user, {bool tour = false}) =>
      evaluator.newlyEarned(
        catalogue: catalogue,
        user: user,
        walkthroughCompleted: tour,
      );

  group('FirebaseAchievementRepository.parse', () {
    test('reads the stored catalogue', () {
      expect(catalogue.map((a) => a.achievementId), [
        'first-active-break',
        'first-workout',
        'guide-completed',
        'on-the-move',
      ]);
      final onTheMove = catalogue.last;
      expect(onTheMove.order, 4);
      expect(onTheMove.icon, 'directions_walk');
      expect(onTheMove.name, {'es': 'En movimiento', 'en': 'On the Move'});
      final condition = onTheMove.condition as CompletionCountCondition;
      expect(condition.kind, CountedActivity.activeBreaks);
      expect(condition.count, 3);
      expect(catalogue[2].condition, isA<WalkthroughCompletedCondition>());
    });

    test('a condition it does not know never unlocks', () {
      final achievement = FirebaseAchievementRepository.parse('streak-7', {
        'name': {'es': 'Racha', 'en': 'Streak'},
        'description': {'es': '7 días', 'en': '7 days'},
        'condition': {'type': 'streakDays', 'count': 7},
      });

      expect(achievement.achievementId, 'streak-7');
      expect(achievement.condition, isA<UnknownCondition>());
      expect(
        evaluator.newlyEarned(
          catalogue: [achievement],
          user: user(activeBreaks: 50),
          walkthroughCompleted: true,
        ),
        isEmpty,
      );
    });

    test('a count condition without a count is unknown', () {
      final achievement = FirebaseAchievementRepository.parse('x', {
        'name': {'es': 'a', 'en': 'a'},
        'description': {'es': 'b', 'en': 'b'},
        'condition': {'type': 'workouts'},
      });
      expect(achievement.condition, isA<UnknownCondition>());
    });

    test('rejects a badge without both languages', () {
      expect(
        () => FirebaseAchievementRepository.parse('x', {
          'name': {'es': 'Solo español'},
          'description': {'es': 'b', 'en': 'b'},
        }),
        throwsFormatException,
      );
    });
  });

  group('AchievementEvaluator', () {
    test('nothing is earned without activity', () {
      expect(earned(user()), isEmpty);
    });

    test('active-break badges follow the count', () {
      expect(earned(user(activeBreaks: 1)), {'first-active-break'});
      expect(earned(user(activeBreaks: 2)), {'first-active-break'});
      expect(earned(user(activeBreaks: 3)), {
        'first-active-break',
        'on-the-move',
      });
    });

    test('counts workouts only from when they were tracked apart', () {
      final since = DateTime(2026, 10, 20);
      expect(
        earned(user(workouts: [DateTime(2026, 10, 19)], trackedSince: since)),
        isEmpty,
      );
      expect(
        earned(user(workouts: [DateTime(2026, 10, 20)], trackedSince: since)),
        {'first-workout'},
      );
    });

    test('legacy history without the tracking date counts no workouts', () {
      expect(
        earned(user(workouts: [DateTime(2026, 9, 1), DateTime(2026, 9, 2)])),
        isEmpty,
      );
    });

    test('the guide badge needs a completed tour', () {
      expect(earned(user()), isNot(contains('guide-completed')));
      expect(earned(user(), tour: true), {'guide-completed'});
    });

    test('never returns a badge the user already has', () {
      expect(
        earned(
          user(activeBreaks: 3, owned: ['first-active-break', 'on-the-move']),
          tour: true,
        ),
        {'guide-completed'},
      );
    });
  });

  group('BadgeSync', () {
    late _BadgeRepository repository;

    ProviderContainer makeContainer(UserModel initial) {
      repository = _BadgeRepository(initial);
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          profileProvider.overrideWith(() => _FakeProfile(repository)),
          achievementsProvider.overrideWith((ref) async => catalogue),
        ],
      );
      addTearDown(container.dispose);
      container.listen(profileProvider, (_, _) {});
      return container;
    }

    test('saves the earned badges and shows them at once', () async {
      final container = makeContainer(user(activeBreaks: 3));
      final profile = await container.read(profileProvider.future);

      final unlocked = await container
          .read(badgeSyncProvider)
          .sync(profile, walkthroughCompleted: false);

      expect(unlocked, {'first-active-break', 'on-the-move'});
      expect(repository.unlockCalls, [
        {'first-active-break', 'on-the-move'},
      ]);
      expect(
        container.read(profileProvider).value!.unlockedBadgeIds,
        containsAll(['first-active-break', 'on-the-move']),
      );
    });

    test('a second check writes nothing', () async {
      final container = makeContainer(user(activeBreaks: 1));
      final sync = container.read(badgeSyncProvider);
      await _syncOnce(container, sync);

      final again = await sync.sync(
        container.read(profileProvider).value!,
        walkthroughCompleted: false,
      );

      expect(again, isEmpty);
      expect(repository.unlockCalls, hasLength(1));
    });

    test('two checks at once save each badge once', () async {
      final container = makeContainer(user(activeBreaks: 1));
      final profile = await container.read(profileProvider.future);
      final sync = container.read(badgeSyncProvider);
      repository.gate = Completer<void>();

      final first = sync.sync(profile, walkthroughCompleted: false);
      final second = sync.sync(profile, walkthroughCompleted: false);
      await Future<void>.delayed(Duration.zero);
      repository.gate!.complete();

      expect(await first, {'first-active-break'});
      expect(await second, isEmpty);
      expect(repository.unlockCalls, hasLength(1));
    });

    test('reads the catalogue again after it failed to load', () async {
      repository = _BadgeRepository(user(activeBreaks: 1));
      var attempts = 0;
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repository),
          profileProvider.overrideWith(() => _FakeProfile(repository)),
          achievementsProvider.overrideWith((ref) async {
            attempts++;
            if (attempts == 1) throw StateError('offline');
            return catalogue;
          }),
        ],
      );
      addTearDown(container.dispose);
      container.listen(profileProvider, (_, _) {});
      final profile = await container.read(profileProvider.future);
      final sync = container.read(badgeSyncProvider);

      expect(await sync.sync(profile, walkthroughCompleted: false), isEmpty);
      expect(await sync.sync(profile, walkthroughCompleted: false), {
        'first-active-break',
      });
    });

    test('a failed save is logged, not thrown', () async {
      final container = makeContainer(user(activeBreaks: 1));
      final profile = await container.read(profileProvider.future);
      repository.fail = true;

      final unlocked = await container
          .read(badgeSyncProvider)
          .sync(profile, walkthroughCompleted: false);

      expect(unlocked, isEmpty);
      expect(
        container.read(profileProvider).value!.unlockedBadgeIds,
        isEmpty,
      );
    });
  });

  group('BadgeSyncListener', () {
    Future<_BadgeRepository> pump(
      WidgetTester tester,
      UserModel initial, {
      WalkthroughStatus? tour,
    }) async {
      final repository = _BadgeRepository(initial);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(repository),
            profileProvider.overrideWith(() => _FakeProfile(repository)),
            achievementsProvider.overrideWith((ref) async => catalogue),
            walkthroughUserIdProvider.overrideWithValue('u'),
            walkthroughStoreProvider.overrideWithValue(
              _FixedWalkthroughStore(
                tour == null
                    ? null
                    : WalkthroughProgress(status: tour, stepId: 'home.welcome'),
              ),
            ),
          ],
          child: const BadgeSyncListener(child: SizedBox()),
        ),
      );
      await tester.pumpAndSettle();
      return repository;
    }

    testWidgets('unlocks what the loaded history has earned', (tester) async {
      final repository = await pump(tester, user(activeBreaks: 1));
      expect(repository.unlockCalls, [
        {'first-active-break'},
      ]);
    });

    testWidgets('unlocks the guide badge for a completed tour', (
      tester,
    ) async {
      final repository = await pump(
        tester,
        user(),
        tour: WalkthroughStatus.completed,
      );
      expect(repository.unlockCalls.expand((ids) => ids), ['guide-completed']);
    });

    testWidgets('a dismissed tour gives no badge', (tester) async {
      final repository = await pump(
        tester,
        user(),
        tour: WalkthroughStatus.dismissed,
      );
      expect(repository.unlockCalls, isEmpty);
    });
  });

  group('MedalCaseSection', () {
    Future<void> pump(
      WidgetTester tester,
      Locale locale, {
      Future<List<Achievement>> Function()? load,
    }) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            achievementsProvider.overrideWith(
              (ref) => load == null ? Future.value(catalogue) : load(),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: MedalCaseSection(
                  user: user(owned: ['first-active-break']),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows earned and locked medals in Spanish', (tester) async {
      await pump(tester, const Locale('es'));

      expect(find.text('Tus medallas'), findsOneWidget);
      expect(find.text('1 de 4'), findsOneWidget);
      expect(find.text('Primera pausa activa'), findsOneWidget);
      expect(find.text('Completa 3 pausas activas.'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Primera pausa activa: medalla desbloqueada'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Guía completada: medalla bloqueada. Termina la guía de la app.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('medal-first-workout-locked')),
        findsOneWidget,
      );
    });

    testWidgets('shows earned and locked medals in English', (tester) async {
      await pump(tester, const Locale('en'));

      expect(find.text('Your medals'), findsOneWidget);
      expect(find.text('1 of 4'), findsOneWidget);
      expect(
        find.bySemanticsLabel('First Active Break: medal unlocked'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'On the Move: medal locked. Complete 3 active breaks.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('fits two medals per row on a phone', (tester) async {
      await pump(tester, const Locale('en'));

      final first = tester.getTopLeft(
        find.byKey(const ValueKey('medal-first-active-break-unlocked')),
      );
      final second = tester.getTopLeft(
        find.byKey(const ValueKey('medal-first-workout-locked')),
      );
      final third = tester.getTopLeft(
        find.byKey(const ValueKey('medal-guide-completed-locked')),
      );
      expect(second.dy, first.dy);
      expect(third.dy, greaterThan(first.dy));
    });

    testWidgets('offers a retry when the catalogue cannot load', (
      tester,
    ) async {
      var attempts = 0;
      await pump(
        tester,
        const Locale('en'),
        load: () async {
          attempts++;
          if (attempts == 1) throw StateError('offline');
          return catalogue;
        },
      );

      expect(find.text("Couldn't load your medals."), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 4'), findsOneWidget);
    });
  });
}

/// Runs one check and waits for it, for tests that need a first unlock.
Future<void> _syncOnce(ProviderContainer container, BadgeSync sync) async {
  await sync.sync(
    await container.read(profileProvider.future),
    walkthroughCompleted: false,
  );
}

const _catalogueJson = <String, Map<String, dynamic>>{
  'first-active-break': {
    'achievementId': 'first-active-break',
    'order': 1,
    'icon': 'self_improvement',
    'name': {'es': 'Primera pausa activa', 'en': 'First Active Break'},
    'description': {
      'es': 'Completa tu primera pausa activa.',
      'en': 'Complete your first active break.',
    },
    'condition': {'type': 'activeBreaks', 'count': 1},
  },
  'first-workout': {
    'achievementId': 'first-workout',
    'order': 2,
    'icon': 'fitness_center',
    'name': {'es': 'Primer entrenamiento', 'en': 'First Workout'},
    'description': {
      'es': 'Completa tu primer entrenamiento.',
      'en': 'Complete your first workout.',
    },
    'condition': {'type': 'workouts', 'count': 1},
  },
  'guide-completed': {
    'achievementId': 'guide-completed',
    'order': 3,
    'icon': 'explore',
    'name': {'es': 'Guía completada', 'en': 'Guide Completed'},
    'description': {
      'es': 'Termina la guía de la app.',
      'en': 'Finish the app tour.',
    },
    'condition': {'type': 'walkthroughCompleted'},
  },
  'on-the-move': {
    'achievementId': 'on-the-move',
    'order': 4,
    'icon': 'directions_walk',
    'name': {'es': 'En movimiento', 'en': 'On the Move'},
    'description': {
      'es': 'Completa 3 pausas activas.',
      'en': 'Complete 3 active breaks.',
    },
    'condition': {'type': 'activeBreaks', 'count': 3},
  },
};

class _FakeProfile extends Profile {
  _FakeProfile(this._repository);

  final _BadgeRepository _repository;

  @override
  Future<UserModel> build() async => _repository.user;
}

class _FixedWalkthroughStore implements WalkthroughStore {
  _FixedWalkthroughStore(this.progress);

  final WalkthroughProgress? progress;

  @override
  Future<WalkthroughProgress?> load(String uid) async => progress;

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async {}

  @override
  Future<void> clear(String uid) async {}
}

class _BadgeRepository implements ProfileRepository {
  _BadgeRepository(this.user);

  UserModel user;
  final List<Set<String>> unlockCalls = [];
  Completer<void>? gate;
  bool fail = false;

  @override
  Future<void> unlockBadges(Set<String> badgeIds) async {
    await gate?.future;
    if (fail) throw StateError('offline');
    unlockCalls.add(badgeIds);
    user = user.copyWith(
      unlockedBadgeIds: {...user.unlockedBadgeIds, ...badgeIds}.toList(),
    );
  }

  @override
  Future<UserModel> getProfile() async => user;

  @override
  Future<void> saveProfile(UserModel user) async {}

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {}

  @override
  Future<void> createProfile(UserModel user) async {}

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) async {}
}
