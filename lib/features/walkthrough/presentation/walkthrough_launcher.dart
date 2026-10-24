import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_launch.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/features/walkthrough/presentation/walkthrough_dialogs.dart';

/// Users whose tour was already considered since the app started, so going
/// back to the main screen never asks twice. "Not now" asks again on the
/// next launch because this is not saved.
final walkthroughCheckedUsersProvider = Provider<Set<String>>((ref) => {});

/// Starts the tour for a new user, or invites anyone else who has not
/// finished or declined it, once per user and app launch. It shows [child]
/// unchanged.
class WalkthroughLauncher extends ConsumerStatefulWidget {
  const WalkthroughLauncher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WalkthroughLauncher> createState() =>
      _WalkthroughLauncherState();
}

class _WalkthroughLauncherState extends ConsumerState<WalkthroughLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launch());
  }

  Future<void> _launch() async {
    if (!mounted) return;
    final uid = ref.read(walkthroughUserIdProvider);
    if (uid == null) return;
    if (!ref.read(walkthroughCheckedUsersProvider).add(uid)) return;

    final controller = ref.read(walkthroughControllerProvider.notifier);
    await controller.loaded;
    if (!mounted) return;
    // A tour resumed after a restart is already running.
    if (ref.read(walkthroughControllerProvider).isActive) return;

    final bool hasCompletedWorkouts;
    try {
      final user = await ref.read(profileProvider.future);
      hasCompletedWorkouts = user.completedWorkouts.isNotEmpty;
    } catch (_) {
      return;
    }
    if (!mounted) return;

    final state = ref.read(walkthroughControllerProvider);
    if (!state.isLoaded || state.isActive) return;
    switch (decideWalkthroughLaunch(
      saved: state.saved,
      hasCompletedWorkouts: hasCompletedWorkouts,
    )) {
      case WalkthroughLaunch.autoStart:
        controller.start();
      case WalkthroughLaunch.invite:
        await offerWalkthrough(context, controller, state);
      case WalkthroughLaunch.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
