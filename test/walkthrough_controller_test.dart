import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_steps.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';

const _training = ScreenRevealed(WalkthroughScreen.training);
const _exercise = ScreenRevealed(WalkthroughScreen.exercise);
const _home = ScreenRevealed(WalkthroughScreen.home);

void main() {
  late _MemoryStore store;
  late ProviderContainer container;
  late NotifierProvider<_Uid, String?> uid;

  Future<WalkthroughController> controllerFor({
    Map<String, WalkthroughProgress> saved = const {},
    String? user = 'user-a',
  }) async {
    store = _MemoryStore(saved);
    uid = NotifierProvider<_Uid, String?>(() => _Uid(user));
    container = ProviderContainer(
      overrides: [
        walkthroughStoreProvider.overrideWithValue(store),
        walkthroughUserIdProvider.overrideWith((ref) => ref.watch(uid)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(walkthroughControllerProvider, (_, _) {});
    final controller = container.read(walkthroughControllerProvider.notifier);
    await controller.loaded;
    return controller;
  }

  WalkthroughState state() => container.read(walkthroughControllerProvider);
  String stepId() => state().step.id;

  void goTo(WalkthroughController controller, String id) {
    controller.start();
    final target = walkthroughStepIndex(id);
    while (state().stepIndex < target) {
      final step = state().step;
      if (!step.isGated) {
        controller.next();
        continue;
      }
      if (step.requiresFirst != null) controller.onSignal(step.requiresFirst!);
      controller.onSignal(step.completesOn!);
    }
    expect(stepId(), id);
  }

  group('loading', () {
    test('nothing starts before the saved progress is read', () async {
      store = _MemoryStore({});
      store.hold = true;
      container = ProviderContainer(
        overrides: [
          walkthroughStoreProvider.overrideWithValue(store),
          walkthroughUserIdProvider.overrideWithValue('user-a'),
        ],
      );
      addTearDown(container.dispose);
      container.listen(walkthroughControllerProvider, (_, _) {});
      final controller = container.read(walkthroughControllerProvider.notifier);

      controller.start();
      expect(state().isLoaded, isFalse);
      expect(state().isActive, isFalse);

      store.release();
      await controller.loaded;
      expect(state().isLoaded, isTrue);
      expect(state().isActive, isFalse);
      expect(store.writes, isEmpty);
    });

    test('nobody signed in means no tour', () async {
      final controller = await controllerFor(user: null);
      controller.start();
      expect(state().isActive, isFalse);
      expect(store.writes, isEmpty);
    });

    test(
      'a tour that was running when the app closed resumes on a tab',
      () async {
        await controllerFor(
          saved: {
            'user-a': const WalkthroughProgress(
              status: WalkthroughStatus.active,
              stepId: 'exercise.completeSet',
            ),
          },
        );
        expect(state().isActive, isTrue);
        expect(stepId(), 'training.openExercise');
      },
    );

    test('an unknown saved step is treated as nothing saved', () async {
      await controllerFor(
        saved: {
          'user-a': const WalkthroughProgress(
            status: WalkthroughStatus.dismissed,
            stepId: 'removed.step',
          ),
        },
      );
      expect(state().isActive, isFalse);
      expect(state().saved, isNull);
    });

    test('each user has their own progress', () async {
      final controller = await controllerFor(
        saved: {
          'user-b': const WalkthroughProgress(
            status: WalkthroughStatus.completed,
            stepId: 'settings.replay',
          ),
        },
      );
      goTo(controller, 'home.health');
      expect(store.data['user-a']?.stepId, 'home.health');

      container.read(uid.notifier).set('user-b');
      await container.read(walkthroughControllerProvider.notifier).loaded;
      expect(state().isActive, isFalse);
      expect(state().saved?.status, WalkthroughStatus.completed);
      expect(store.data['user-a']?.stepId, 'home.health');
    });
  });

  group('informational and gated steps', () {
    test('Next moves on from an informational step and saves it', () async {
      final controller = await controllerFor();
      controller.start();

      expect(controller.next(), isTrue);
      expect(stepId(), 'home.mission');
      expect(
        store.data['user-a'],
        const WalkthroughProgress(
          status: WalkthroughStatus.active,
          stepId: 'home.mission',
        ),
      );
    });

    test('Next does nothing on a gated step', () async {
      final controller = await controllerFor();
      goTo(controller, 'home.startWorkout');
      final writes = store.writes.length;

      expect(controller.next(), isFalse);
      expect(stepId(), 'home.startWorkout');
      expect(store.writes.length, writes);
    });

    test('only the expected signal completes a gated step, once', () async {
      final controller = await controllerFor();
      goTo(controller, 'home.startWorkout');

      controller.onSignal(const ActionReceipt(WalkthroughAction.setCompleted));
      controller.onSignal(const ScreenRevealed(WalkthroughScreen.progress));
      expect(stepId(), 'home.startWorkout');

      controller.onSignal(_training);
      expect(stepId(), 'training.overview');

      controller.onSignal(_training);
      expect(stepId(), 'training.overview');
    });

    test(
      'a receipt alone does not complete a step that needs a destination',
      () async {
        final controller = await controllerFor();
        goTo(controller, 'training.finishWorkout');

        controller.onSignal(
          const ActionReceipt(WalkthroughAction.workoutFinishPressed),
        );
        expect(stepId(), 'training.finishWorkout');

        controller.onSignal(_home);
        expect(stepId(), 'home.practiceNote');
      },
    );

    test(
      'a destination alone does not complete a step that needs a receipt',
      () async {
        final controller = await controllerFor();
        goTo(controller, 'exercise.next');

        controller.onSignal(_exercise);
        expect(stepId(), 'exercise.next');

        controller.onSignal(
          const ActionReceipt(WalkthroughAction.exerciseNext),
        );
        controller.onSignal(_exercise);
        expect(stepId(), 'exercise.done');
      },
    );

    test('a report from an earlier step is dropped', () async {
      final controller = await controllerFor();
      goTo(controller, 'home.startWorkout');
      final stale = state().generation;
      controller.previous();
      controller.next();

      controller.onSignal(_training, generation: stale);
      expect(stepId(), 'home.startWorkout');

      controller.onSignal(_training, generation: state().generation);
      expect(stepId(), 'training.overview');
    });

    test('the last step completes the tour', () async {
      final controller = await controllerFor();
      goTo(controller, 'settings.replay');

      expect(controller.next(), isTrue);
      expect(state().isActive, isFalse);
      expect(state().saved?.status, WalkthroughStatus.completed);
      expect(store.data['user-a']?.status, WalkthroughStatus.completed);
    });

    test('the whole tour can be walked from start to finish', () async {
      final controller = await controllerFor();
      goTo(controller, 'settings.replay');
      controller.next();
      expect(store.data['user-a']?.status, WalkthroughStatus.completed);
    });
  });

  group('Previous', () {
    test('goes back within a screen', () async {
      final controller = await controllerFor();
      goTo(controller, 'home.health');

      expect(controller.previous(), isTrue);
      expect(stepId(), 'home.weeklyStats');
    });

    test('is refused at the start of a screen', () async {
      final controller = await controllerFor();
      goTo(controller, 'training.overview');

      expect(state().canGoBack, isFalse);
      expect(controller.previous(), isFalse);
      expect(stepId(), 'training.overview');
    });

    test('from a gated step it never performs the action', () async {
      final controller = await controllerFor();
      goTo(controller, 'home.startWorkout');

      controller.previous();
      expect(stepId(), 'home.health');
      controller.onSignal(_training);
      expect(stepId(), 'home.health');
    });
  });

  group('screens reached another way', () {
    test('back from the exercise realigns to opening it again', () async {
      final controller = await controllerFor();
      goTo(controller, 'exercise.completeSet');

      controller.onSignal(_training);
      expect(stepId(), 'training.openExercise');
    });

    test('the first back press out of a routine keeps the step', () async {
      final controller = await controllerFor();
      goTo(controller, 'ab.backToMenu');

      controller.onSignal(
        const ScreenRevealed(WalkthroughScreen.activeBreaksBrowse),
      );
      expect(stepId(), 'ab.backToMenu');
      expect(state().halfwayReached, isTrue);

      controller.onSignal(
        const ScreenRevealed(WalkthroughScreen.activeBreaksMenu),
      );
      expect(stepId(), 'ab.openTimer');
      expect(state().halfwayReached, isFalse);
    });

    test('a screen with no earlier step is ignored', () async {
      final controller = await controllerFor();
      goTo(controller, 'home.weeklyStats');

      controller.onSignal(const ScreenRevealed(WalkthroughScreen.settings));
      expect(stepId(), 'home.weeklyStats');
    });
  });

  group('single-exercise workouts', () {
    test('skip the Next step', () async {
      final controller = await controllerFor();
      controller.setCondition(WalkthroughCondition.noNextExercise, true);
      goTo(controller, 'exercise.completeSet');

      controller.onSignal(const ActionReceipt(WalkthroughAction.setCompleted));
      expect(stepId(), 'exercise.done');
    });

    test('keep it when another exercise follows', () async {
      final controller = await controllerFor();
      controller.setCondition(WalkthroughCondition.noNextExercise, false);
      goTo(controller, 'exercise.completeSet');

      controller.onSignal(const ActionReceipt(WalkthroughAction.setCompleted));
      expect(stepId(), 'exercise.next');
    });

    test('skip it when the fact arrives while it is showing', () async {
      final controller = await controllerFor();
      goTo(controller, 'exercise.next');

      controller.setCondition(WalkthroughCondition.noNextExercise, true);
      expect(stepId(), 'exercise.done');
    });
  });

  group('closing, resuming and declining', () {
    test('closing keeps the step for later', () async {
      final controller = await controllerFor();
      goTo(controller, 'home.health');

      controller.dismiss();
      expect(state().isActive, isFalse);
      expect(state().canResume, isTrue);
      expect(
        store.data['user-a'],
        const WalkthroughProgress(
          status: WalkthroughStatus.dismissed,
          stepId: 'home.health',
        ),
      );
    });

    test('resume continues where the tour was closed', () async {
      final controller = await controllerFor(
        saved: {
          'user-a': const WalkthroughProgress(
            status: WalkthroughStatus.dismissed,
            stepId: 'progress.jointStats',
          ),
        },
      );

      controller.resume();
      expect(state().isActive, isTrue);
      expect(stepId(), 'progress.jointStats');
    });

    test('resume from a pushed screen goes back to its tab', () async {
      final controller = await controllerFor(
        saved: {
          'user-a': const WalkthroughProgress(
            status: WalkthroughStatus.dismissed,
            stepId: 'diagnosis.overview',
          ),
        },
      );

      controller.resume();
      expect(stepId(), 'progress.retake');
    });

    test('start over goes to the first step', () async {
      final controller = await controllerFor(
        saved: {
          'user-a': const WalkthroughProgress(
            status: WalkthroughStatus.dismissed,
            stepId: 'progress.jointStats',
          ),
        },
      );

      controller.start();
      expect(stepId(), 'home.welcome');
    });

    test('closing on the first step leaves nothing to resume', () async {
      final controller = await controllerFor();
      controller.start();
      controller.dismiss();

      expect(state().canResume, isFalse);
    });

    test('"Never ask again" is saved', () async {
      final controller = await controllerFor();

      controller.decline();
      expect(store.data['user-a']?.status, WalkthroughStatus.declined);
    });

    test('a completed tour can be replayed', () async {
      final controller = await controllerFor(
        saved: {
          'user-a': const WalkthroughProgress(
            status: WalkthroughStatus.completed,
            stepId: 'settings.replay',
          ),
        },
      );

      controller.start();
      expect(state().isActive, isTrue);
      expect(stepId(), 'home.welcome');
    });

    test('signals are ignored while no tour is running', () async {
      final controller = await controllerFor();
      controller.onSignal(_training);
      expect(state().isActive, isFalse);
      expect(store.writes, isEmpty);
    });
  });
}

class _Uid extends Notifier<String?> {
  _Uid(this._initial);

  final String? _initial;

  @override
  String? build() => _initial;

  void set(String? value) => state = value;
}

class _MemoryStore implements WalkthroughStore {
  _MemoryStore(Map<String, WalkthroughProgress> initial)
    : data = Map.of(initial);

  final Map<String, WalkthroughProgress> data;
  final List<WalkthroughProgress> writes = [];
  bool hold = false;
  final List<void Function()> _held = [];

  void release() {
    hold = false;
    for (final resume in _held) {
      resume();
    }
    _held.clear();
  }

  @override
  Future<WalkthroughProgress?> load(String uid) async {
    if (hold) {
      final completer = Completer<void>();
      _held.add(completer.complete);
      await completer.future;
    }
    return data[uid];
  }

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async {
    writes.add(progress);
    data[uid] = progress;
  }

  @override
  Future<void> clear(String uid) async => data.remove(uid);
}
