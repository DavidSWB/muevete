import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walkthroughAnchorRegistryProvider = Provider<WalkthroughAnchorRegistry>(
  (ref) => WalkthroughAnchorRegistry(),
);

/// The anchors currently on screen, by target id.
class WalkthroughAnchorRegistry {
  final Map<String, List<BuildContext>> _anchors = {};

  void _add(String id, BuildContext context) =>
      (_anchors[id] ??= []).add(context);

  void _remove(String id, BuildContext context) {
    final list = _anchors[id];
    list?.remove(context);
    if (list != null && list.isEmpty) _anchors.remove(id);
  }

  /// The anchor for [id] on the route the user is looking at. Screens lower
  /// in the stack stay mounted, so an id can be registered more than once.
  BuildContext? find(String id) {
    final list = _anchors[id];
    if (list == null) return null;
    for (final context in list.reversed) {
      if (!context.mounted) continue;
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) continue;
      if (_isOffstage(context)) continue;
      final box = context.findRenderObject();
      if (box is RenderBox && box.attached && box.hasSize) return context;
    }
    return null;
  }
}

/// Hidden tabs of the main screen stay mounted but offstage, or invisible
/// inside an [IndexedStack].
bool _isOffstage(BuildContext context) {
  var offstage = false;
  context.visitAncestorElements((element) {
    final widget = element.widget;
    offstage =
        (widget is Offstage && widget.offstage) ||
        (widget is Visibility && !widget.visible);
    return !offstage;
  });
  return offstage;
}

/// The back arrow an [AppBar] shows by itself, marked as [id] for the tour.
/// Null when the route has nothing to go back to, as the app bar would.
Widget? walkthroughBackButton(BuildContext context, String id) {
  final canGoBack = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
  return canGoBack
      ? WalkthroughAnchor(id: id, child: const BackButton())
      : null;
}

/// Marks [child] as something the tour can highlight. It changes nothing
/// about how [child] looks or behaves.
class WalkthroughAnchor extends ConsumerStatefulWidget {
  const WalkthroughAnchor({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  ConsumerState<WalkthroughAnchor> createState() => _WalkthroughAnchorState();
}

class _WalkthroughAnchorState extends ConsumerState<WalkthroughAnchor> {
  late final WalkthroughAnchorRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = ref.read(walkthroughAnchorRegistryProvider);
    _registry._add(widget.id, context);
  }

  @override
  void didUpdateWidget(WalkthroughAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _registry._remove(oldWidget.id, context);
      _registry._add(widget.id, context);
    }
  }

  @override
  void dispose() {
    _registry._remove(widget.id, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
