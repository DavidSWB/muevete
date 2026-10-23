import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/walkthrough/data/shared_preferences_walkthrough_store.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_steps.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';

final walkthroughStoreProvider = Provider<WalkthroughStore>(
  (ref) => SharedPreferencesWalkthroughStore(),
);

/// The signed-in user whose tour is shown, or null when nobody is signed in.
final walkthroughUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

final walkthroughControllerProvider =
    NotifierProvider<WalkthroughController, WalkthroughState>(
      WalkthroughController.new,
    );

class WalkthroughState {
  const WalkthroughState({
    required this.isLoaded,
    this.saved,
    this.isActive = false,
    this.stepIndex = 0,
    this.generation = 0,
    this.receiptSeen = false,
    this.halfwayReached = false,
  });

  /// False until the signed-in user's saved progress has been read. Nothing
  /// can start the tour before then.
  final bool isLoaded;

  /// What is stored for the user, after the latest change.
  final WalkthroughProgress? saved;

  final bool isActive;
  final int stepIndex;

  /// Changes with every step change, so work started for one step can tell
  /// when that step is over.
  final int generation;

  /// The current step's [WalkthroughStep.requiresFirst] has arrived.
  final bool receiptSeen;

  /// The current step's [WalkthroughStep.alsoAccepts] has arrived.
  final bool halfwayReached;

  WalkthroughStep get step => walkthroughSteps[stepIndex];
  int get stepNumber => stepIndex + 1;
  int get stepCount => walkthroughSteps.length;
  bool get isLastStep => stepIndex == walkthroughSteps.length - 1;
  bool get canGoBack => isActive && walkthroughCanGoBack(stepIndex);
  bool get canGoNext => isActive && !step.isGated;

  /// A tour that was closed part way and can be continued.
  bool get canResume =>
      saved?.status == WalkthroughStatus.dismissed &&
      walkthroughStepIndex(saved!.stepId) > 0;
}

/// Runs the tour: which step is showing, what completes it, and what is
/// saved. It knows nothing about widgets; the screens report what happens
/// through [onSignal].
class WalkthroughController extends Notifier<WalkthroughState> {
  final Set<WalkthroughCondition> _conditions = {};
  Future<void> _loading = Future.value();

  /// Completes once the signed-in user's progress has been read.
  Future<void> get loaded => _loading;

  @override
  WalkthroughState build() {
    _conditions.clear();
    final uid = ref.watch(walkthroughUserIdProvider);
    if (uid == null) {
      _loading = Future.value();
      return const WalkthroughState(isLoaded: false);
    }
    _loading = _load(uid);
    return const WalkthroughState(isLoaded: false);
  }

  Future<void> _load(String uid) async {
    final saved = await ref.read(walkthroughStoreProvider).load(uid);
    if (!ref.mounted) return;

    final savedIndex = saved == null ? -1 : walkthroughStepIndex(saved.stepId);
    if (saved?.status == WalkthroughStatus.active && savedIndex >= 0) {
      // The app closed during the tour: continue where the screen allows.
      state = WalkthroughState(
        isLoaded: true,
        saved: saved,
        isActive: true,
        stepIndex: walkthroughResumeIndex(savedIndex),
      );
      _save();
      return;
    }
    // A step id this version no longer has cannot be resumed.
    final usable =
        saved != null &&
            (savedIndex >= 0 ||
                saved.status == WalkthroughStatus.completed ||
                saved.status == WalkthroughStatus.declined)
        ? saved
        : null;
    state = WalkthroughState(isLoaded: true, saved: usable);
  }

  /// Starts the tour from the first step.
  void start() {
    if (!state.isLoaded) return;
    _goTo(0);
  }

  /// Continues a closed tour at the step it was closed on, or at the last
  /// main-screen step before it when that step was on a pushed screen.
  void resume() {
    if (!state.isLoaded) return;
    final savedIndex = walkthroughStepIndex(state.saved?.stepId ?? '');
    if (savedIndex < 0) {
      start();
      return;
    }
    _goTo(walkthroughResumeIndex(savedIndex));
  }

  /// Closes the tour and keeps the step, so it can be resumed.
  void dismiss() {
    if (!state.isActive) return;
    _setStatus(WalkthroughStatus.dismissed);
  }

  /// "Never ask again" on the invitation.
  void decline() {
    if (!state.isLoaded || state.isActive) return;
    _setStatus(WalkthroughStatus.declined);
  }

  /// Moves on from an informational step. Gated steps only move on when the
  /// user does what they ask, so this does nothing on them.
  bool next() {
    if (!state.canGoNext) return false;
    if (state.isLastStep) {
      _setStatus(WalkthroughStatus.completed);
    } else {
      _goTo(state.stepIndex + 1);
    }
    return true;
  }

  bool previous() {
    if (!state.canGoBack) return false;
    _goTo(state.stepIndex - 1);
    return true;
  }

  /// Records a fact about the user's data that can make a step pointless.
  void setCondition(WalkthroughCondition condition, bool holds) {
    final changed = holds
        ? _conditions.add(condition)
        : _conditions.remove(condition);
    if (changed && state.isActive && state.step.skipWhen == condition) {
      _goTo(state.stepIndex);
    }
  }

  /// Reports what just happened in the app. Only the signal the current step
  /// waits for moves the tour forward. Pass the [generation] read when the
  /// action started to drop a report that arrives after the step changed.
  void onSignal(WalkthroughSignal signal, {int? generation}) {
    if (!state.isActive) return;
    if (generation != null && generation != state.generation) return;

    final step = state.step;
    if (step.isGated) {
      if (signal == step.requiresFirst) {
        state = _copy(receiptSeen: true);
        return;
      }
      if (signal == step.completesOn &&
          (step.requiresFirst == null || state.receiptSeen)) {
        _goTo(state.stepIndex + 1);
        return;
      }
      if (signal == step.alsoAccepts) {
        state = _copy(halfwayReached: true);
        return;
      }
    }

    if (signal is ScreenRevealed && signal.screen != step.screen) {
      final realign = walkthroughRealignIndex(state.stepIndex, signal.screen);
      if (realign != null) _goTo(realign);
    }
  }

  void _goTo(int index) {
    var target = index;
    while (target < walkthroughSteps.length - 1 &&
        _conditions.contains(walkthroughSteps[target].skipWhen)) {
      target++;
    }
    state = WalkthroughState(
      isLoaded: true,
      saved: state.saved,
      isActive: true,
      stepIndex: target,
      generation: state.generation + 1,
    );
    _save();
  }

  void _setStatus(WalkthroughStatus status) {
    state = WalkthroughState(
      isLoaded: true,
      saved: state.saved,
      stepIndex: state.stepIndex,
      generation: state.generation + 1,
    );
    _save(status: status);
  }

  void _save({WalkthroughStatus? status}) {
    final uid = ref.read(walkthroughUserIdProvider);
    if (uid == null) return;
    final progress = WalkthroughProgress(
      status: status ?? WalkthroughStatus.active,
      stepId: state.step.id,
    );
    state = _copy(saved: progress);
    ref.read(walkthroughStoreProvider).save(uid, progress);
  }

  WalkthroughState _copy({
    WalkthroughProgress? saved,
    bool? receiptSeen,
    bool? halfwayReached,
  }) {
    return WalkthroughState(
      isLoaded: state.isLoaded,
      saved: saved ?? state.saved,
      isActive: state.isActive,
      stepIndex: state.stepIndex,
      generation: state.generation,
      receiptSeen: receiptSeen ?? state.receiptSeen,
      halfwayReached: halfwayReached ?? state.halfwayReached,
    );
  }
}
