import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/season_state.dart';
import '../api/auth_state.dart';
import '../../features/season/application/season_state_provider.dart';
import '../../features/lobby/application/lobby_controller.dart';
import '../../features/lobby/presentation/lobby_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/draft/presentation/draft_screen.dart';
import '../../features/season/presentation/token_setup_screen.dart';
import '../../features/season/presentation/race_screen.dart';
import '../../features/inter_season/presentation/inter_season_screen.dart';
import 'app_shell.dart';
import '../../features/standings/presentation/standings_screen.dart';
import '../../features/info/presentation/info_screen.dart';
import '../../features/my_team/presentation/my_team_screen.dart';

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
  bool onAlwaysAvailableTab = false,
}) {
  if (!authed) return location == '/auth' ? null : '/auth';
  if (!hasGroup) return location == '/lobby' ? null : '/lobby';
  if (onAlwaysAvailableTab) return null; // never yank the user off a tab
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
      final hasGroup = ref.read(hasGroupProvider);
      final phase = ref.read(seasonStateProvider).valueOrNull?.phase;
      final loc = state.uri.path;
      const tabs = {'/standings', '/info', '/my-team'};
      return redirectLogic(
        authed: authed,
        hasGroup: hasGroup,
        phase: phase,
        location: loc,
        onAlwaysAvailableTab: tabs.contains(loc),
      );
    },
    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/lobby', builder: (_, __) => const LobbyScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/draft', builder: (_, __) => const DraftScreen()),
            GoRoute(path: '/token-setup', builder: (_, __) => const TokenSetupScreen()),
            GoRoute(path: '/season', builder: (_, __) => const RaceScreen()),
            GoRoute(path: '/inter-season', builder: (_, __) => const InterSeasonScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/standings', builder: (_, __) => const StandingsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/info', builder: (_, __) => const InfoScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/my-team', builder: (_, __) => const MyTeamScreen()),
          ]),
        ],
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
    ref.listen(hasGroupProvider, (_, __) => notifyListeners());
    ref.listen(seasonStateProvider, (_, __) => notifyListeners());
  }
}
