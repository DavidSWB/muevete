import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/app/notification_tap_handler.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/features/training/domain/services/notification_target.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';

void main() {
  late ProviderContainer container;
  String? routeName;

  setUp(() async {
    NotificationScheduler.resetForTesting();
    routeName = '/';
    container = ProviderContainer(
      overrides: [
        walkthroughStoreProvider.overrideWithValue(_MemoryStore()),
        walkthroughUserIdProvider.overrideWithValue('u'),
      ],
    );
    container.listen(walkthroughControllerProvider, (_, _) {});
    await container.read(walkthroughControllerProvider.notifier).loaded;
  });

  tearDown(() {
    container.dispose();
    NotificationScheduler.resetForTesting();
  });

  Future<void> pumpHandler(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: NotificationTapHandler(
            currentRouteName: () => routeName,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  int tab() => container.read(mainNavIndexProvider);

  testWidgets('a training reminder opens the Training tab', (tester) async {
    await pumpHandler(tester);

    NotificationScheduler.handleTap(1003, NotificationPayloads.training);
    await tester.pump();

    expect(tab(), MainScreen.trainingTab);
    expect(NotificationScheduler.pendingTap.value, isNull);
  });

  testWidgets('an active-break reminder opens the Breaks tab', (tester) async {
    await pumpHandler(tester);

    NotificationScheduler.handleTap(2001, NotificationPayloads.activeBreak);
    await tester.pump();

    expect(tab(), MainScreen.activeBreaksTab);
  });

  testWidgets('a tap is acted on once', (tester) async {
    await pumpHandler(tester);
    NotificationScheduler.handleTap(2001, null);
    await tester.pump();
    expect(tab(), MainScreen.activeBreaksTab);

    container.read(mainNavIndexProvider.notifier).setIndex(MainScreen.homeTab);
    await tester.pump();
    await tester.pump();

    expect(tab(), MainScreen.homeTab);
  });

  testWidgets('a tap made before the main screen shows runs once it shows', (
    tester,
  ) async {
    NotificationScheduler.handleTap(1001, NotificationPayloads.training);

    await pumpHandler(tester);

    expect(tab(), MainScreen.trainingTab);
  });

  testWidgets('a tap without a destination changes nothing', (tester) async {
    await pumpHandler(tester);

    NotificationScheduler.handleTap(9000, null);
    await tester.pump();

    expect(tab(), MainScreen.homeTab);
  });

  testWidgets('a tap during the tour is dropped', (tester) async {
    await pumpHandler(tester);
    container.read(walkthroughControllerProvider.notifier).start();

    NotificationScheduler.handleTap(1001, NotificationPayloads.training);
    await tester.pump();

    expect(tab(), MainScreen.homeTab);
    expect(NotificationScheduler.pendingTap.value, isNull);
  });

  for (final activity in ['exercise', 'activeBreakRoutine', 'activeBreaksTimer']) {
    testWidgets('a tap never leaves the $activity screen', (tester) async {
      routeName = activity;
      await pumpHandler(tester);

      NotificationScheduler.handleTap(2001, NotificationPayloads.activeBreak);
      await tester.pump();

      expect(tab(), MainScreen.homeTab);
      expect(NotificationScheduler.pendingTap.value, isNull);
    });
  }

  testWidgets('from another pushed screen it returns to the main screen', (
    tester,
  ) async {
    routeName = 'settings';
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const Text('main')),
        GoRoute(
          path: '/settings',
          builder: (_, _) => NotificationTapHandler(
            currentRouteName: () => routeName,
            child: const Text('settings'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    NotificationScheduler.handleTap(1002, NotificationPayloads.training);
    await tester.pumpAndSettle();

    expect(find.text('main'), findsOneWidget);
    expect(tab(), MainScreen.trainingTab);
  });
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
