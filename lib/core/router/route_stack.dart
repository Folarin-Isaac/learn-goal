import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension RouteStack on BuildContext {
  // Pops back when the screen directly underneath is the [routeName] route
  // whose `extra` satisfies [sameTarget]; returns false (and does nothing)
  // otherwise. Used where two screens link to each other (class details ↔
  // class chat) so hopping back and forth doesn't pile up copies.
  bool popIfPrevious(
    String routeName, {
    required bool Function(Object? extra) sameTarget,
  }) {
    final matches = GoRouter.of(this)
        .routerDelegate
        .currentConfiguration
        .matches;
    if (matches.length < 2) return false;
    final previous = matches[matches.length - 2];
    if (previous is! ImperativeRouteMatch) return false;
    if (previous.route.name != routeName) return false;
    if (!sameTarget(previous.matches.extra)) return false;
    pop();
    return true;
  }
}
