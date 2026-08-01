import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// True when [path] is the current top-level location of the app's router.
///
/// Used to guard WS-driven auto-navigation (`ref.listen(... ) { context.go(...) }`)
/// in screens that live inside a [StatefulShellRoute.indexedStack] branch:
/// those screens stay mounted offstage when another branch is active, so
/// without this guard a WS event received while the user is on a different
/// tab would hijack them off it.
///
/// Deliberately reads [GoRouter.routerDelegate]'s `currentConfiguration`
/// rather than `GoRouterState.of(context)`: the latter resolves to the
/// nearest enclosing `Page`, which for a screen inside a shell-route branch
/// is always that branch's own last-known match — it does not change when a
/// *different* branch becomes active, so it can't tell offstage from
/// onstage. The router delegate's configuration reflects the actual
/// top-level current location.
bool isCurrentLocation(BuildContext context, String path) =>
    GoRouter.of(context).routerDelegate.currentConfiguration.uri.path == path;
