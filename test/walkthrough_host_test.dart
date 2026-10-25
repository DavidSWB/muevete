import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_steps.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_copy.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_host.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/l10n/app_localizations_en.dart';
import 'package:muevete/l10n/app_localizations_es.dart';

const _card = ValueKey('walkthrough-card');
const _next = ValueKey('walkthrough-next');
const _previous = ValueKey('walkthrough-previous');
const _hint = ValueKey('walkthrough-hint');
const _retry = ValueKey('walkthrough-retry');
const _close = ValueKey('walkthrough-close');

void main() {
  late _Harness h;

  setUp(() => h = _Harness());
  tearDown(() => h.dispose());

  group('while no tour runs', () {
    testWidgets('the app is untouched', (tester) async {
      await h.pump(tester);

      expect(find.byKey(_card), findsNothing);
      await tester.tap(find.byKey(const ValueKey('outside')));
      expect(h.taps, ['outside']);
    });
  });

  group('informational steps', () {
    testWidgets('show Previous and Next and block every tap on the app', (
      tester,
    ) async {
      await h.pump(tester);
      h.goTo('home.profile');
      await tester.pumpAndSettle();

      expect(find.byKey(_next), findsOneWidget);
      expect(_enabled(tester, _previous), isTrue);
      await tester.tap(
        find.byKey(const ValueKey('home.profile')),
        warnIfMissed: false,
      );
      await tester.tap(
        find.byKey(const ValueKey('outside')),
        warnIfMissed: false,
      );
      expect(h.taps, isEmpty);

      await tester.tap(find.byKey(_next));
      await tester.pumpAndSettle();
      expect(h.stepId, 'home.weeklyStats');
    });

    testWidgets('a centered step has Previous disabled on the first step', (
      tester,
    ) async {
      await h.pump(tester);
      h.controller.start();
      await tester.pumpAndSettle();

      expect(h.stepId, 'home.welcome');
      expect(_enabled(tester, _previous), isFalse);
      expect(find.byKey(_next), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('outside')),
        warnIfMissed: false,
      );
      expect(h.taps, isEmpty);
    });

    testWidgets('the language step lets taps reach the switch', (tester) async {
      await h.pump(tester);
      h.goTo('settings.language');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('settings.language')));
      expect(h.taps, ['settings.language']);
      expect(h.stepId, 'settings.language');
    });

    testWidgets('the last step reads Got it and ends the tour', (tester) async {
      await h.pump(tester);
      h.goTo('settings.replay');
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byKey(_next), matching: find.text('Got it')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(_next));
      await tester.pumpAndSettle();
      expect(find.byKey(_card), findsNothing);
      expect(h.store.data['u']?.status, WalkthroughStatus.completed);
    });
  });

  group('gated steps', () {
    testWidgets('have no Next and let only the highlighted control be tapped', (
      tester,
    ) async {
      await h.pump(tester);
      h.goTo('home.startWorkout');
      await tester.pumpAndSettle();

      expect(find.byKey(_next), findsNothing);
      expect(find.byKey(_hint), findsOneWidget);
      expect(
        find.text('Tap the highlighted control to continue'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('outside')),
        warnIfMissed: false,
      );
      expect(h.taps, isEmpty);

      await tester.tap(find.byKey(const ValueKey('home.startWorkout')));
      expect(h.taps, ['home.startWorkout']);
      expect(h.stepId, 'home.startWorkout');
    });

    testWidgets('Previous goes back without doing the action', (tester) async {
      await h.pump(tester);
      h.goTo('home.startWorkout');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(_previous));
      await tester.pumpAndSettle();
      expect(h.stepId, 'home.health');
      expect(h.taps, isEmpty);
    });

    testWidgets('a missing target offers Try again but never Next', (
      tester,
    ) async {
      await h.pump(tester);
      h.goTo('training.openExercise');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text("We couldn't find this on the screen."), findsOneWidget);
      expect(find.byKey(_retry), findsOneWidget);
      expect(find.byKey(_next), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('outside')),
        warnIfMissed: false,
      );
      expect(h.taps, isEmpty);

      await tester.tap(find.byKey(_retry));
      await tester.pumpAndSettle();
      expect(h.stepId, 'training.openExercise');
    });

    testWidgets('a target that shows up late is picked up', (tester) async {
      await h.pump(tester);
      h.goTo('training.openExercise');
      await tester.pumpAndSettle();
      h.showLateAnchor.value = true;
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text("We couldn't find this on the screen."), findsNothing);
      await tester.tap(find.byKey(const ValueKey('training.openExercise')));
      expect(h.taps, ['training.openExercise']);
    });

    testWidgets('the halfway back press changes the hint', (tester) async {
      await h.pump(tester);
      h.goTo('ab.backToMenu');
      await tester.pumpAndSettle();

      h.routes.add('activeBreaksBrowse');
      await tester.pumpAndSettle();
      expect(find.text('One more step back'), findsOneWidget);
      expect(h.stepId, 'ab.backToMenu');
    });
  });

  group('closing', () {
    testWidgets('the close button ends the tour and keeps the step', (
      tester,
    ) async {
      await h.pump(tester);
      h.goTo('home.health');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(_close));
      await tester.pumpAndSettle();
      expect(find.byKey(_card), findsNothing);
      expect(
        h.store.data['u'],
        const WalkthroughProgress(
          status: WalkthroughStatus.dismissed,
          stepId: 'home.health',
        ),
      );
      await tester.tap(find.byKey(const ValueKey('outside')));
      expect(h.taps, ['outside']);
    });
  });

  group('signals from the app', () {
    testWidgets('a pushed route completes the step that opens it', (
      tester,
    ) async {
      await h.pump(tester);
      h.goTo('training.openExercise');
      await tester.pumpAndSettle();

      h.routes.add('exercise');
      await tester.pumpAndSettle();
      expect(h.stepId, 'exercise.prescription');

      h.routes.add('/');
      await tester.pumpAndSettle();
      expect(h.stepId, 'training.openExercise');
    });

    testWidgets('a tab change completes the step that asks for it', (
      tester,
    ) async {
      await h.pump(tester);
      h.goTo('nav.openProgress');
      await tester.pumpAndSettle();

      h.container
          .read(mainNavIndexProvider.notifier)
          .setIndex(MainScreen.progressTab);
      await tester.pumpAndSettle();
      expect(h.stepId, 'progress.calendar');
    });

    testWidgets('the Active Breaks tab completes no step', (tester) async {
      await h.pump(tester);
      h.goTo('nav.openProgress');
      await tester.pumpAndSettle();

      h.container
          .read(mainNavIndexProvider.notifier)
          .setIndex(MainScreen.activeBreaksTab);
      await tester.pumpAndSettle();
      expect(h.stepId, 'nav.openProgress');
    });

    testWidgets('tab changes behind a pushed route are ignored', (
      tester,
    ) async {
      await h.pump(tester);
      h.goTo('nav.openProgress');
      await tester.pumpAndSettle();

      h.routes.add('somethingElse');
      h.container
          .read(mainNavIndexProvider.notifier)
          .setIndex(MainScreen.progressTab);
      await tester.pumpAndSettle();
      expect(h.stepId, 'nav.openProgress');
    });

    testWidgets('starting from another tab selects the step tab', (
      tester,
    ) async {
      await h.pump(tester);
      h.container.read(mainNavIndexProvider.notifier).setIndex(3);
      await tester.pump();

      h.controller.start();
      await tester.pumpAndSettle();
      expect(h.container.read(mainNavIndexProvider), 0);
      expect(h.stepId, 'home.welcome');
    });
  });

  group('language', () {
    testWidgets('switching language keeps the step and changes the text', (
      tester,
    ) async {
      await h.pump(tester, locale: const Locale('es'));
      h.goTo('home.profile');
      await tester.pumpAndSettle();
      expect(find.text('Tu perfil'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);

      h.locale.value = const Locale('en');
      await tester.pumpAndSettle();
      expect(find.text('Your profile'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(h.stepId, 'home.profile');
    });

    test('every step has text in Spanish and English', () {
      for (final l10n in [AppLocalizationsEs(), AppLocalizationsEn()]) {
        for (final step in walkthroughSteps) {
          final (title, body) = walkthroughStepCopy(l10n, step.id);
          expect(title.trim(), isNotEmpty, reason: step.id);
          expect(body.trim(), isNotEmpty, reason: step.id);
        }
      }
    });
  });
}

bool _enabled(WidgetTester tester, Key key) =>
    tester.widget<ButtonStyleButton>(find.byKey(key)).onPressed != null;

class _Harness {
  _Harness() {
    container = ProviderContainer(
      overrides: [
        walkthroughStoreProvider.overrideWithValue(store),
        walkthroughUserIdProvider.overrideWithValue('u'),
      ],
    );
  }

  final store = _MemoryStore();
  late final ProviderContainer container;
  final routes = StreamController<String?>.broadcast(sync: true);
  final taps = <String>[];
  final locale = ValueNotifier<Locale>(const Locale('en'));
  final showLateAnchor = ValueNotifier<bool>(false);

  WalkthroughController get controller =>
      container.read(walkthroughControllerProvider.notifier);
  String get stepId => container.read(walkthroughControllerProvider).step.id;

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (locale != null) this.locale.value = locale;

    container.listen(walkthroughControllerProvider, (_, _) {});
    await controller.loaded;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ValueListenableBuilder<Locale>(
          valueListenable: this.locale,
          builder: (context, locale, _) => MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) =>
                WalkthroughHost(routeNames: routes.stream, child: child!),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _button('home.profile', anchored: true),
                    _button('home.startWorkout', anchored: true),
                    _button('settings.language', anchored: true),
                    ValueListenableBuilder<bool>(
                      valueListenable: showLateAnchor,
                      builder: (context, show, _) => show
                          ? _button('training.openExercise', anchored: true)
                          : const SizedBox.shrink(),
                    ),
                    const Spacer(),
                    _button('outside'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget _button(String id, {bool anchored = false}) {
    final button = ElevatedButton(
      key: ValueKey(id),
      onPressed: () => taps.add(id),
      child: Text(id),
    );
    return anchored ? WalkthroughAnchor(id: id, child: button) : button;
  }

  /// Walks the real controller to [id], as the app's signals would.
  void goTo(String id) {
    controller.start();
    final target = walkthroughStepIndex(id);
    while (container.read(walkthroughControllerProvider).stepIndex < target) {
      final step = container.read(walkthroughControllerProvider).step;
      if (!step.isGated) {
        controller.next();
        continue;
      }
      if (step.requiresFirst != null) controller.onSignal(step.requiresFirst!);
      controller.onSignal(step.completesOn!);
    }
    expect(stepId, id);
  }

  void dispose() {
    routes.close();
    container.dispose();
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
