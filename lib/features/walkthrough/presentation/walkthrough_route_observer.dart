import 'dart:async';

import 'package:flutter/widgets.dart';

/// Reports the name of the route that becomes visible. The router is a
/// global object, so the tour listens to [revealed] instead of being given
/// to the observer.
class WalkthroughRouteObserver extends NavigatorObserver {
  final StreamController<String?> _revealed =
      StreamController<String?>.broadcast(sync: true);

  Stream<String?> get revealed => _revealed.stream;

  /// Name of the route last revealed, or null before any.
  String? get current => _current;
  String? _current;

  void _reveal(Route<dynamic>? route) {
    if (route == null || route is PopupRoute) return;
    _current = route.settings.name;
    _revealed.add(_current);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _reveal(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) return;
    _reveal(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null && newRoute.isCurrent) _reveal(newRoute);
  }
}

final walkthroughRouteObserver = WalkthroughRouteObserver();
