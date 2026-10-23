import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_step.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_anchor.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_coach_card.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_route_observer.dart';
import 'package:muevete/shared/theme/app_colors.dart';

/// Route names of the main screen, whose tabs are told apart by
/// [mainNavIndexProvider].
const Set<String> walkthroughMainRouteNames = {'/', '/home'};

const Map<String, WalkthroughScreen> walkthroughRouteScreens = {
  'exercise': WalkthroughScreen.exercise,
  'diagnosis': WalkthroughScreen.diagnosis,
  'activeBreaks': WalkthroughScreen.activeBreaksMenu,
  'activeBreaksBrowse': WalkthroughScreen.activeBreaksBrowse,
  'activeBreakRoutine': WalkthroughScreen.activeBreakRoutine,
  'activeBreaksTimer': WalkthroughScreen.activeBreakTimer,
};

const List<WalkthroughScreen> _tabs = [
  WalkthroughScreen.home,
  WalkthroughScreen.training,
  WalkthroughScreen.progress,
  WalkthroughScreen.settings,
];

/// How long a target may be missing before the card says so. Screens that
/// load their data show their controls a moment after they appear.
const Duration _missingGrace = Duration(milliseconds: 800);

/// Sits above the router and draws the tour over every screen.
///
/// While no tour runs it only passes [child] through. While one runs it dims
/// the screen, leaves a hole over the highlighted control and blocks taps
/// everywhere else. On gated steps taps inside the hole reach the real
/// control; on informational steps they are blocked too, except on steps
/// marked [WalkthroughStep.passThrough].
class WalkthroughHost extends ConsumerStatefulWidget {
  const WalkthroughHost({super.key, required this.child, this.routeNames});

  final Widget child;

  /// Names of the routes that become visible. Defaults to the app router's
  /// [walkthroughRouteObserver].
  final Stream<String?>? routeNames;

  @override
  ConsumerState<WalkthroughHost> createState() => _WalkthroughHostState();
}

class _WalkthroughHostState extends ConsumerState<WalkthroughHost> {
  final GlobalKey _stackKey = GlobalKey();
  StreamSubscription<String?>? _routeSubscription;
  bool _mainRouteOnTop = true;

  bool _frameCallbackScheduled = false;
  int? _measuredGeneration;
  int? _scrolledGeneration;
  Rect? _hole;
  bool _targetMissing = false;
  bool _showMissing = false;
  Timer? _missingTimer;

  @override
  void initState() {
    super.initState();
    _routeSubscription =
        (widget.routeNames ?? walkthroughRouteObserver.revealed).listen(
          _onRouteRevealed,
        );
  }

  @override
  void dispose() {
    _routeSubscription?.cancel();
    _missingTimer?.cancel();
    super.dispose();
  }

  WalkthroughController get _controller =>
      ref.read(walkthroughControllerProvider.notifier);

  void _onRouteRevealed(String? name) {
    if (name != null && walkthroughMainRouteNames.contains(name)) {
      _mainRouteOnTop = true;
      final index = ref.read(mainNavIndexProvider);
      if (index >= 0 && index < _tabs.length) {
        _controller.onSignal(ScreenRevealed(_tabs[index]));
      }
      return;
    }
    _mainRouteOnTop = false;
    final screen = walkthroughRouteScreens[name];
    if (screen != null) _controller.onSignal(ScreenRevealed(screen));
  }

  void _onTabChanged(int? previous, int next) {
    if (previous == next || !_mainRouteOnTop) return;
    if (next >= 0 && next < _tabs.length) {
      _controller.onSignal(ScreenRevealed(_tabs[next]));
    }
  }

  void _onTourChanged(WalkthroughState? previous, WalkthroughState next) {
    if (!next.isActive) return;
    if (previous?.isActive == true && previous?.generation == next.generation) {
      return;
    }
    // Starting, resuming or stepping back can land on another tab than the
    // one showing. Select it; the user cannot reach the tabs themselves.
    final tab = _tabs.indexOf(next.step.screen);
    if (tab < 0 || !_mainRouteOnTop) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mainRouteOnTop) return;
      final current = ref.read(walkthroughControllerProvider);
      if (!current.isActive || current.generation != next.generation) return;
      if (ref.read(mainNavIndexProvider) != tab) {
        ref.read(mainNavIndexProvider.notifier).setIndex(tab);
      }
    });
  }

  void _scheduleMeasure() {
    if (_frameCallbackScheduled) return;
    _frameCallbackScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _frameCallbackScheduled = false;
      if (!mounted) return;
      final state = ref.read(walkthroughControllerProvider);
      if (!state.isActive) return;
      _measure(state);
      // Measure again after every later frame, so the hole follows scrolling
      // and layout changes. This never asks for extra frames by itself.
      _scheduleMeasure();
    });
  }

  void _measure(WalkthroughState state) {
    final targetId = state.step.targetId;
    Rect? hole;
    var missing = false;

    if (targetId != null) {
      final anchor = ref.read(walkthroughAnchorRegistryProvider).find(targetId);
      final stackBox = _stackKey.currentContext?.findRenderObject();
      final box = anchor?.findRenderObject();
      if (anchor != null &&
          box is RenderBox &&
          stackBox is RenderBox &&
          stackBox.hasSize) {
        final topLeft = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
        hole = (topLeft & box.size).intersect(Offset.zero & stackBox.size);
        if (hole.isEmpty) hole = null;
        if (_scrolledGeneration != state.generation) {
          _scrolledGeneration = state.generation;
          if (Scrollable.maybeOf(anchor) != null) {
            Scrollable.ensureVisible(
              anchor,
              alignment: 0.5,
              duration: const Duration(milliseconds: 250),
            );
          }
        }
      }
      missing = hole == null;
    }

    if (!missing) {
      _missingTimer?.cancel();
      _missingTimer = null;
    } else if (_missingTimer == null && !_showMissing) {
      final generation = state.generation;
      _missingTimer = Timer(_missingGrace, () {
        _missingTimer = null;
        if (!mounted || !_targetMissing) return;
        if (ref.read(walkthroughControllerProvider).generation != generation) {
          return;
        }
        setState(() => _showMissing = true);
      });
    }

    final generationChanged = _measuredGeneration != state.generation;
    if (generationChanged || hole != _hole || missing != _targetMissing) {
      setState(() {
        if (generationChanged) _showMissing = false;
        _measuredGeneration = state.generation;
        _hole = hole;
        _targetMissing = missing;
        if (!missing) _showMissing = false;
      });
    }
  }

  void _retry() {
    _missingTimer?.cancel();
    _missingTimer = null;
    setState(() {
      _showMissing = false;
      _scrolledGeneration = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mainNavIndexProvider, _onTabChanged);
    ref.listen(walkthroughControllerProvider, _onTourChanged);
    final state = ref.watch(walkthroughControllerProvider);

    if (state.isActive) _scheduleMeasure();
    final measured = state.isActive && _measuredGeneration == state.generation;

    return Stack(
      key: _stackKey,
      children: [
        widget.child,
        if (state.isActive)
          Positioned.fill(
            // The host sits above the app's navigator, so the card's
            // tooltips need an overlay of their own.
            child: Overlay.wrap(
              child: _TourLayer(
                state: state,
                measured: measured,
                hole: measured ? _hole : null,
                targetMissing: measured && _targetMissing && _showMissing,
                onPrevious: () => _controller.previous(),
                onNext: () => _controller.next(),
                onClose: () => _controller.dismiss(),
                onRetry: _retry,
              ),
            ),
          ),
      ],
    );
  }
}

class _TourLayer extends StatelessWidget {
  const _TourLayer({
    required this.state,
    required this.measured,
    required this.hole,
    required this.targetMissing,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.onRetry,
  });

  static const double _holePadding = 6;
  static const double _margin = 16;
  static const double _minCardSpace = 220;

  final WalkthroughState state;
  final bool measured;
  final Rect? hole;
  final bool targetMissing;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final screen = Offset.zero & size;
        final padded = hole?.inflate(_holePadding).intersect(screen);
        final step = state.step;
        final blockHole = !step.isGated && !step.passThrough;

        final card = WalkthroughCoachCard(
          state: state,
          targetMissing: targetMissing,
          onPrevious: onPrevious,
          onNext: onNext,
          onClose: onClose,
          onRetry: onRetry,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ScrimPainter(padded)),
              ),
            ),
            if (padded == null)
              const Positioned.fill(child: _TapBlocker())
            else ...[
              for (final rect in _around(padded, size))
                Positioned.fromRect(rect: rect, child: const _TapBlocker()),
              if (blockHole)
                Positioned.fromRect(
                  rect: padded,
                  child: const _TapBlocker(
                    key: ValueKey('walkthrough-hole-blocker'),
                  ),
                ),
            ],
            if (measured) _placeCard(context, card, padded, size),
          ],
        );
      },
    );
  }

  /// The four rectangles around [hole] that block taps.
  static List<Rect> _around(Rect hole, Size size) {
    final rects = [
      Rect.fromLTRB(0, 0, size.width, hole.top),
      Rect.fromLTRB(0, hole.bottom, size.width, size.height),
      Rect.fromLTRB(0, hole.top, hole.left, hole.bottom),
      Rect.fromLTRB(hole.right, hole.top, size.width, hole.bottom),
    ];
    return [
      for (final rect in rects)
        if (rect.width > 0 && rect.height > 0) rect,
    ];
  }

  Widget _placeCard(BuildContext context, Widget card, Rect? hole, Size size) {
    final insets = MediaQuery.paddingOf(context);
    final constrained = Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: card,
      ),
    );

    if (hole == null) {
      return Positioned.fill(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(_margin),
            child: Center(child: constrained),
          ),
        ),
      );
    }

    final spaceAbove = hole.top - insets.top;
    final spaceBelow = size.height - hole.bottom - insets.bottom;
    if (math.max(spaceAbove, spaceBelow) < _minCardSpace) {
      return Positioned(
        left: _margin,
        right: _margin,
        bottom: insets.bottom + _margin,
        child: constrained,
      );
    }
    if (spaceBelow >= spaceAbove) {
      return Positioned(
        left: _margin,
        right: _margin,
        top: hole.bottom + _margin,
        child: constrained,
      );
    }
    return Positioned(
      left: _margin,
      right: _margin,
      bottom: size.height - hole.top + _margin,
      child: constrained,
    );
  }
}

/// Swallows taps so they never reach the app underneath.
class _TapBlocker extends StatelessWidget {
  const _TapBlocker({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(),
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter(this.hole);

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Path()..addRect(Offset.zero & size);
    final hole = this.hole;
    if (hole == null) {
      canvas.drawPath(screen, Paint()..color = Colors.black54);
      return;
    }
    final rounded = RRect.fromRectAndRadius(hole, const Radius.circular(14));
    canvas.drawPath(
      Path.combine(PathOperation.difference, screen, Path()..addRRect(rounded)),
      Paint()..color = Colors.black54,
    );
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter oldDelegate) => oldDelegate.hole != hole;
}
