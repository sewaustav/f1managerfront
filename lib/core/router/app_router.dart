import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/season_state.dart';
import '../api/auth_state.dart';
import '../../shared/widgets/placeholder_screen.dart';

String routeForPhase(SeasonPhase phase) {
  switch (phase) {
    case SeasonPhase.draft:
      return '/draft';
    case SeasonPhase.tokenSetup:
      return '/token-setup';
    case SeasonPhase.racing:
      return '/season';
    case SeasonPhase.interSeason:
      return '/inter-season';
    case SeasonPhase.unknown:
      return '/lobby';
  }
}

/// Pure redirect decision. Returns target path or null (no redirect).
String? redirectLogic({
  required bool authed,
  required bool hasGroup,
  required SeasonPhase? phase,
  required String location,
}) {
  if (!authed) return location == '/auth' ? null : '/auth';
  if (!hasGroup) return location == '/lobby' ? null : '/lobby';
  if (phase == null) return null;
  final target = routeForPhase(phase);
  return location == target ? null : target;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authed = ref.read(isAuthenticatedProvider);
      // hasGroup / phase are wired in the Auth+Lobby + Season plans via providers;
      // for the foundation they default to (false, null) so routing lands on
      // /lobby once authenticated.
      return redirectLogic(
        authed: authed,
        hasGroup: false,
        phase: null,
        location: state.uri.path,
      );
    },
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const PlaceholderScreen('Auth')),
      GoRoute(path: '/lobby', builder: (_, __) => const PlaceholderScreen('Lobby')),
      GoRoute(path: '/draft', builder: (_, __) => const PlaceholderScreen('Draft')),
      GoRoute(path: '/token-setup', builder: (_, __) => const PlaceholderScreen('Token Setup')),
      GoRoute(path: '/season', builder: (_, __) => const PlaceholderScreen('Season')),
      GoRoute(path: '/inter-season', builder: (_, __) => const PlaceholderScreen('Inter-Season')),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
  }
}
