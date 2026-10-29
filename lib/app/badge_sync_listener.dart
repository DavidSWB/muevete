import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/gamification/presentation/badge_sync.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';

/// Checks for newly earned badges whenever the profile loads or reloads,
/// which it does after every recorded completion, and when the tour is
/// completed. It joins the tour and the profile so neither imports the
/// other.
class BadgeSyncListener extends ConsumerStatefulWidget {
  const BadgeSyncListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BadgeSyncListener> createState() => _BadgeSyncListenerState();
}

class _BadgeSyncListenerState extends ConsumerState<BadgeSyncListener> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(profileProvider, (_, next) {
      if (next.hasValue && !next.isLoading) _sync();
    }, fireImmediately: true);
    ref.listenManual(walkthroughControllerProvider.select(_tourCompleted), (
      _,
      completed,
    ) {
      if (completed) _sync();
    });
  }

  static bool _tourCompleted(WalkthroughState state) =>
      state.saved?.status == WalkthroughStatus.completed;

  void _sync() {
    final user = ref.read(profileProvider).value;
    if (user == null) return;
    ref
        .read(badgeSyncProvider)
        .sync(
          user,
          walkthroughCompleted: _tourCompleted(
            ref.read(walkthroughControllerProvider),
          ),
        );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
