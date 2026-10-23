import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_dialogs.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_route_observer.dart';
import 'package:muevete/l10n/app_localizations.dart';

void main() {
  group('WalkthroughRouteObserver', () {
    testWidgets('reports the route that becomes visible', (tester) async {
      final observer = WalkthroughRouteObserver();
      final revealed = <String?>[];
      final subscription = observer.revealed.listen(revealed.add);
      addTearDown(subscription.cancel);
      final navigator = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          navigatorObservers: [observer],
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Text(settings.name ?? ''),
          ),
          initialRoute: '/',
        ),
      );
      expect(revealed, ['/']);

      navigator.currentState!.pushNamed('exercise');
      await tester.pumpAndSettle();
      navigator.currentState!.pushReplacementNamed('exercise');
      await tester.pumpAndSettle();
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(revealed, ['/', 'exercise', 'exercise', '/']);
    });

    testWidgets('ignores dialogs', (tester) async {
      final observer = WalkthroughRouteObserver();
      final revealed = <String?>[];
      final subscription = observer.revealed.listen(revealed.add);
      addTearDown(subscription.cancel);
      final navigator = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          navigatorObservers: [observer],
          home: const SizedBox(),
        ),
      );
      revealed.clear();

      showDialog<void>(
        context: navigator.currentContext!,
        builder: (_) => const AlertDialog(content: Text('dialog')),
      );
      await tester.pumpAndSettle();
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(revealed, isEmpty);
    });
  });

  group('invitation', () {
    testWidgets('Start tour starts at the first step', (tester) async {
      final h = await _DialogHarness.pump(tester);

      await h.openInvitation(tester);
      expect(find.text('Want a quick tour of Muévete?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('walkthrough-invite-start')));
      await tester.pumpAndSettle();

      expect(h.state.isActive, isTrue);
      expect(h.state.step.id, 'home.welcome');
    });

    testWidgets('Not now saves nothing, so it asks again later', (
      tester,
    ) async {
      final h = await _DialogHarness.pump(tester);

      await h.openInvitation(tester);
      await tester.tap(find.byKey(const ValueKey('walkthrough-invite-later')));
      await tester.pumpAndSettle();

      expect(h.state.isActive, isFalse);
      expect(h.store.data, isEmpty);
    });

    testWidgets('Never ask again is saved and points to Settings', (
      tester,
    ) async {
      final h = await _DialogHarness.pump(tester);

      await h.openInvitation(tester);
      await tester.tap(find.byKey(const ValueKey('walkthrough-invite-never')));
      await tester.pumpAndSettle();

      expect(h.store.data['u']?.status, WalkthroughStatus.declined);
      expect(
        find.text("No problem. You'll find the tour in Settings."),
        findsOneWidget,
      );
    });

    testWidgets('is shown in Spanish', (tester) async {
      final h = await _DialogHarness.pump(tester, locale: const Locale('es'));

      await h.openInvitation(tester);
      expect(find.text('¿Quieres hacer la guía de Muévete?'), findsOneWidget);
      expect(find.text('No volver a preguntar'), findsOneWidget);
    });
  });

  group('starting again', () {
    const closed = WalkthroughProgress(
      status: WalkthroughStatus.dismissed,
      stepId: 'home.startWorkout',
    );

    testWidgets('with nothing to resume starts straight away', (tester) async {
      final h = await _DialogHarness.pump(tester);

      await h.openStart(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(h.state.step.id, 'home.welcome');
    });

    testWidgets('Continue resumes where the tour was closed', (tester) async {
      final h = await _DialogHarness.pump(tester, saved: closed);

      await h.openStart(tester);
      expect(
        find.text(
          'You were on step 5 of 33. Continue where you left off or start over?',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('walkthrough-resume')));
      await tester.pumpAndSettle();

      expect(h.state.isActive, isTrue);
      expect(h.state.step.id, 'home.startWorkout');
    });

    testWidgets('Start over goes to the first step', (tester) async {
      final h = await _DialogHarness.pump(tester, saved: closed);

      await h.openStart(tester);
      await tester.tap(find.byKey(const ValueKey('walkthrough-start-over')));
      await tester.pumpAndSettle();

      expect(h.state.step.id, 'home.welcome');
    });

    testWidgets('closing the question starts nothing', (tester) async {
      final h = await _DialogHarness.pump(tester, saved: closed);

      await h.openStart(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(h.state.isActive, isFalse);
    });
  });
}

class _DialogHarness {
  _DialogHarness(this.container, this.store);

  final ProviderContainer container;
  final _MemoryStore store;
  final _navigator = GlobalKey<NavigatorState>();

  WalkthroughState get state => container.read(walkthroughControllerProvider);
  WalkthroughController get controller =>
      container.read(walkthroughControllerProvider.notifier);

  static Future<_DialogHarness> pump(
    WidgetTester tester, {
    WalkthroughProgress? saved,
    Locale locale = const Locale('en'),
  }) async {
    final store = _MemoryStore();
    if (saved != null) store.data['u'] = saved;
    final container = ProviderContainer(
      overrides: [
        walkthroughStoreProvider.overrideWithValue(store),
        walkthroughUserIdProvider.overrideWithValue('u'),
      ],
    );
    addTearDown(container.dispose);
    container.listen(walkthroughControllerProvider, (_, _) {});
    await container.read(walkthroughControllerProvider.notifier).loaded;

    final h = _DialogHarness(container, store);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: h._navigator,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      ),
    );
    return h;
  }

  Future<void> openInvitation(WidgetTester tester) async {
    offerWalkthrough(_navigator.currentContext!, controller, state);
    await tester.pumpAndSettle();
  }

  Future<void> openStart(WidgetTester tester) async {
    startWalkthrough(_navigator.currentContext!, controller, state);
    await tester.pumpAndSettle();
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
