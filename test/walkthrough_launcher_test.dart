import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_launcher.dart';
import 'package:muevete/l10n/app_localizations.dart';

const _invite = ValueKey('walkthrough-invite-start');
const _later = ValueKey('walkthrough-invite-later');

void main() {
  testWidgets('a new account starts the tour without asking', (tester) async {
    final h = await _Harness.pump(tester);

    expect(find.byKey(_invite), findsNothing);
    expect(h.state.isActive, isTrue);
    expect(h.state.step.id, 'home.welcome');
  });

  testWidgets('an account with workouts is invited', (tester) async {
    final h = await _Harness.pump(tester, workouts: [DateTime(2026, 10, 1)]);

    expect(find.byKey(_invite), findsOneWidget);
    expect(h.state.isActive, isFalse);
  });

  testWidgets('a tour closed part way is offered again', (tester) async {
    await _Harness.pump(
      tester,
      saved: const WalkthroughProgress(
        status: WalkthroughStatus.dismissed,
        stepId: 'home.health',
      ),
    );

    expect(find.byKey(_invite), findsOneWidget);
  });

  for (final status in [
    WalkthroughStatus.completed,
    WalkthroughStatus.declined,
  ]) {
    testWidgets('a ${status.name} tour is left alone', (tester) async {
      final h = await _Harness.pump(
        tester,
        saved: WalkthroughProgress(status: status, stepId: 'home.welcome'),
      );

      expect(find.byKey(_invite), findsNothing);
      expect(h.state.isActive, isFalse);
    });
  }

  testWidgets('Not now saves nothing and is not asked again this session',
      (tester) async {
    final h = await _Harness.pump(tester, workouts: [DateTime(2026, 10, 1)]);

    await tester.tap(find.byKey(_later));
    await tester.pumpAndSettle();
    expect(find.byKey(_invite), findsNothing);
    expect(h.store.data, isEmpty);

    // Leaving and coming back to the main screen does not ask again.
    await tester.pumpWidget(h.app(const SizedBox()));
    await tester.pumpWidget(h.app(const WalkthroughLauncher(child: Text('main'))));
    await tester.pumpAndSettle();
    expect(find.byKey(_invite), findsNothing);
  });

  testWidgets('nothing happens without a signed-in user', (tester) async {
    final h = await _Harness.pump(tester, uid: null);

    expect(find.byKey(_invite), findsNothing);
    expect(h.state.isActive, isFalse);
  });

  testWidgets('nothing happens when the profile cannot be read',
      (tester) async {
    final h = await _Harness.pump(tester, profileFails: true);

    expect(find.byKey(_invite), findsNothing);
    expect(h.state.isActive, isFalse);
  });
}

class _Harness {
  _Harness(this.container, this.store);

  final ProviderContainer container;
  final _MemoryStore store;

  WalkthroughState get state => container.read(walkthroughControllerProvider);

  Widget app(Widget home) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: home,
      ),
    );
  }

  static Future<_Harness> pump(
    WidgetTester tester, {
    String? uid = 'u',
    WalkthroughProgress? saved,
    List<DateTime> workouts = const [],
    bool profileFails = false,
  }) async {
    final store = _MemoryStore();
    if (saved != null && uid != null) store.data[uid] = saved;
    final container = ProviderContainer(
      overrides: <Override>[
        walkthroughStoreProvider.overrideWithValue(store),
        walkthroughUserIdProvider.overrideWithValue(uid),
        profileProvider.overrideWith(
          () => _FakeProfile(workouts, fails: profileFails),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(walkthroughControllerProvider, (_, _) {});

    final h = _Harness(container, store);
    await tester.pumpWidget(
      h.app(const WalkthroughLauncher(child: Text('main'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('main'), findsOneWidget);
    return h;
  }
}

class _FakeProfile extends Profile {
  _FakeProfile(this._workouts, {required this.fails});

  final List<DateTime> _workouts;
  final bool fails;

  @override
  Future<UserModel> build() async {
    if (fails) throw StateError('profile unavailable');
    return UserModel(
      id: 'u',
      email: 'user@example.com',
      username: 'user',
      completedWorkouts: _workouts,
    );
  }
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
