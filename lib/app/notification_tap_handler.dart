import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/app/main_screen.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/features/training/domain/services/notification_target.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_host.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_route_observer.dart';

/// Routes the user is in the middle of an activity on. A tapped reminder
/// never takes them away from these.
const Set<String> _activityRouteNames = {
  'exercise',
  'activeBreakRoutine',
  'activeBreaksTimer',
};

/// Opens the destination of a tapped reminder.
///
/// It sits inside [MainScreen], which only shows once the user is signed in
/// and has finished onboarding, so a tap made before that waits until then.
class NotificationTapHandler extends ConsumerStatefulWidget {
  const NotificationTapHandler({
    super.key,
    required this.child,
    this.currentRouteName,
  });

  final Widget child;

  /// Name of the visible route. Defaults to the app router's
  /// [walkthroughRouteObserver].
  final String? Function()? currentRouteName;

  @override
  ConsumerState<NotificationTapHandler> createState() =>
      _NotificationTapHandlerState();
}

class _NotificationTapHandlerState
    extends ConsumerState<NotificationTapHandler> {
  @override
  void initState() {
    super.initState();
    NotificationScheduler.pendingTap.addListener(_scheduleOpen);
    _scheduleOpen();
  }

  @override
  void dispose() {
    NotificationScheduler.pendingTap.removeListener(_scheduleOpen);
    super.dispose();
  }

  void _scheduleOpen() {
    if (NotificationScheduler.pendingTap.value == null) return;
    // Wait for the frame, so the router and the tabs are ready. Ask for one:
    // a tap while the app is already showing does not cause a frame itself.
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _open())
      ..ensureVisualUpdate();
  }

  void _open() {
    if (!mounted) return;
    final target = NotificationScheduler.takePendingTap();
    if (target == null) return;

    // The tour drives the tabs itself; do not pull the user out of it.
    if (ref.read(walkthroughControllerProvider).isActive) return;

    final routeName = (widget.currentRouteName ??
        () => walkthroughRouteObserver.current)();
    if (_activityRouteNames.contains(routeName)) return;

    if (routeName != null && !walkthroughMainRouteNames.contains(routeName)) {
      GoRouter.maybeOf(context)?.go('/home');
    }
    ref
        .read(mainNavIndexProvider.notifier)
        .setIndex(switch (target) {
          NotificationTarget.training => MainScreen.trainingTab,
          NotificationTarget.activeBreaks => MainScreen.activeBreaksTab,
        });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
