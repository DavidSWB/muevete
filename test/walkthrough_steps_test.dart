import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_launch.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_steps.dart';

int _index(String id) {
  final index = walkthroughStepIndex(id);
  expect(index, isNonNegative, reason: 'unknown step $id');
  return index;
}

void main() {
  group('step map', () {
    test('has 33 steps with unique ids', () {
      expect(walkthroughSteps, hasLength(33));
      final ids = walkthroughSteps.map((step) => step.id).toSet();
      expect(ids, hasLength(33));
    });

    test('has 15 informational and 18 gated steps', () {
      expect(walkthroughSteps.where((step) => step.isGated), hasLength(18));
      expect(walkthroughSteps.where((step) => !step.isGated), hasLength(15));
    });

    test(
      'every gated step waits for a signal and no informational step does',
      () {
        for (final step in walkthroughSteps) {
          if (step.isGated) {
            expect(step.completesOn, isNotNull, reason: step.id);
            expect(step.passThrough, isFalse, reason: step.id);
          } else {
            expect(step.completesOn, isNull, reason: step.id);
            expect(step.requiresFirst, isNull, reason: step.id);
            expect(step.alsoAccepts, isNull, reason: step.id);
          }
        }
      },
    );

    test('the tour starts and ends on informational steps', () {
      expect(walkthroughSteps.first.isGated, isFalse);
      expect(walkthroughSteps.last.isGated, isFalse);
    });

    test('a step that changes the screen leads to a step on that screen', () {
      for (var i = 0; i < walkthroughSteps.length - 1; i++) {
        final completesOn = walkthroughSteps[i].completesOn;
        if (completesOn is! ScreenRevealed) continue;
        var next = i + 1;
        if (walkthroughSteps[next].skipWhen != null) next++;
        expect(
          walkthroughSteps[next].screen,
          completesOn.screen,
          reason: walkthroughSteps[i].id,
        );
      }
    });

    test('only the language step lets taps through', () {
      expect(
        walkthroughSteps.where((step) => step.passThrough).map((s) => s.id),
        ['settings.language'],
      );
    });
  });

  group('resume', () {
    test('steps on pushed screens resume at the last step on a tab', () {
      expect(
        walkthroughResumeIndex(_index('exercise.completeSet')),
        _index('training.openExercise'),
      );
      expect(
        walkthroughResumeIndex(_index('exercise.done')),
        _index('training.openExercise'),
      );
      expect(
        walkthroughResumeIndex(_index('diagnosis.leave')),
        _index('progress.retake'),
      );
      expect(
        walkthroughResumeIndex(_index('ab.routine')),
        _index('home.activeBreaks'),
      );
      expect(
        walkthroughResumeIndex(_index('ab.exitToHome')),
        _index('home.activeBreaks'),
      );
    });

    test('steps on tabs resume on themselves', () {
      for (var i = 0; i < walkthroughSteps.length; i++) {
        if (walkthroughSteps[i].screen.isTab) {
          expect(walkthroughResumeIndex(i), i, reason: walkthroughSteps[i].id);
        }
      }
    });
  });

  group('Previous', () {
    test('is refused on the first step and after a screen change', () {
      expect(walkthroughCanGoBack(0), isFalse);
      expect(walkthroughCanGoBack(_index('training.overview')), isFalse);
      expect(walkthroughCanGoBack(_index('exercise.prescription')), isFalse);
      expect(walkthroughCanGoBack(_index('exercise.done')), isFalse);
      expect(walkthroughCanGoBack(_index('home.practiceNote')), isFalse);
    });

    test('is allowed within a screen', () {
      expect(walkthroughCanGoBack(_index('home.profile')), isTrue);
      expect(walkthroughCanGoBack(_index('home.startWorkout')), isTrue);
      expect(walkthroughCanGoBack(_index('exercise.next')), isTrue);
      expect(walkthroughCanGoBack(_index('settings.replay')), isTrue);
    });
  });

  group('realign', () {
    test('goes back to the closest earlier step on the revealed screen', () {
      expect(
        walkthroughRealignIndex(
          _index('exercise.completeSet'),
          WalkthroughScreen.training,
        ),
        _index('training.openExercise'),
      );
      expect(
        walkthroughRealignIndex(
          _index('ab.routine'),
          WalkthroughScreen.activeBreaksBrowse,
        ),
        _index('ab.openRoutine'),
      );
    });

    test('never points forward', () {
      expect(
        walkthroughRealignIndex(
          _index('home.welcome'),
          WalkthroughScreen.settings,
        ),
        isNull,
      );
    });
  });

  group('launch', () {
    test('a user with nothing saved and no workouts gets the tour', () {
      expect(
        decideWalkthroughLaunch(saved: null, hasCompletedWorkouts: false),
        WalkthroughLaunch.autoStart,
      );
    });

    test('an existing user with nothing saved is invited', () {
      expect(
        decideWalkthroughLaunch(saved: null, hasCompletedWorkouts: true),
        WalkthroughLaunch.invite,
      );
    });

    test('a user who closed the tour part way is invited again', () {
      expect(
        decideWalkthroughLaunch(
          saved: const WalkthroughProgress(
            status: WalkthroughStatus.dismissed,
            stepId: 'home.health',
          ),
          hasCompletedWorkouts: true,
        ),
        WalkthroughLaunch.invite,
      );
    });

    test('completed, declined or running tours are left alone', () {
      for (final status in [
        WalkthroughStatus.completed,
        WalkthroughStatus.declined,
        WalkthroughStatus.active,
      ]) {
        expect(
          decideWalkthroughLaunch(
            saved: WalkthroughProgress(status: status, stepId: 'home.welcome'),
            hasCompletedWorkouts: false,
          ),
          WalkthroughLaunch.none,
          reason: status.name,
        );
      }
    });
  });
}
