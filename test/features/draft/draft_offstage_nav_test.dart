import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:f1manager/core/router/app_shell.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/draft/application/draft_data_providers.dart';
import 'package:f1manager/features/draft/presentation/draft_screen.dart';
import 'package:f1manager/features/draft/presentation/widgets/budget_bar.dart';
import 'package:f1manager/features/draft/model/budget.dart';

class _FakeWs extends WsService {
  _FakeWs() : super(wsUrl: 'ws://x', accessToken: (() async => 't'));
  @override
  void send(Map<String, dynamic> json) {}
}

/// Mirrors the InterSeasonScreen offstage-nav-guard tests in
/// test/features/inter_season/inter_season_screen_test.dart: DraftScreen's
/// `ref.listen(draftControllerProvider.select((s) => s.finished), ...)` in
/// lib/features/draft/presentation/draft_screen.dart calls
/// `context.go('/token-setup')` only when `isCurrentLocation(context,
/// '/draft')` is true, so that a `draft_finished` WS event received while
/// DraftScreen is mounted-but-offstage (kept alive by the shell's
/// IndexedStack while another tab is active) doesn't hijack the user off the
/// tab they're actually looking at.
void main() {
  List<Override> overrides(StreamController<WsMessage> ws) => [
        wsMessagesProvider.overrideWith((ref) => ws.stream),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        pilotsProvider.overrideWith((ref) async => []),
        teamsProvider.overrideWith((ref) async => []),
        principalsProvider.overrideWith((ref) async => []),
        enginesProvider.overrideWith((ref) async => []),
        budgetProvider.overrideWith((ref) async => const Budget(budget: 500, tokens: 3)),
      ];

  GoRouter buildShellRouter({required String initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/draft',
                builder: (_, __) => const DraftScreen(),
              ),
              GoRoute(
                path: '/token-setup',
                builder: (_, __) => const Scaffold(body: Text('token-setup')),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/standings', builder: (_, __) => const Text('STANDINGS')),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/info', builder: (_, __) => const Text('INFO')),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/my-team', builder: (_, __) => const Text('MYTEAM')),
            ]),
          ],
        ),
      ],
    );
  }

  testWidgets(
      'draft_finished while a DIFFERENT branch is active does not navigate away',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final ws = StreamController<WsMessage>.broadcast();
    addTearDown(ws.close);

    // Start on the Draft branch so it gets built (StatefulShellBranch
    // branches are lazily built on first visit), then switch to the
    // Standings branch — exactly like a user tabbing away. IndexedStack
    // keeps DraftScreen mounted offstage from then on.
    final router = buildShellRouter(initialLocation: '/draft');

    await tester.pumpWidget(ProviderScope(
      overrides: overrides(ws),
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(DraftScreen), findsOneWidget);

    await tester.tap(find.text('Зачёт'));
    await tester.pumpAndSettle();

    // DraftScreen is mounted offstage (IndexedStack keeps every branch
    // alive), but the user is looking at Standings. Finders skip offstage
    // widgets by default, so opt back in to prove it's still there — just
    // not visible.
    expect(find.text('STANDINGS'), findsOneWidget);
    expect(find.byType(DraftScreen, skipOffstage: false), findsOneWidget);

    ws.add(const WsMessage('draft_finished', {'type': 'draft_finished'}));
    await tester.pump();
    await tester.pumpAndSettle();

    // The WS-driven auto-navigation must NOT hijack the user off the tab
    // they're on.
    expect(find.text('STANDINGS'), findsOneWidget);
    expect(find.text('token-setup'), findsNothing);
  });

  testWidgets('draft_finished while the Draft branch is active navigates',
      (tester) async {
    final ws = StreamController<WsMessage>.broadcast();
    addTearDown(ws.close);

    final router = buildShellRouter(initialLocation: '/draft');

    await tester.pumpWidget(ProviderScope(
      overrides: overrides(ws),
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    ws.add(const WsMessage('draft_finished', {'type': 'draft_finished'}));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('token-setup'), findsOneWidget);
  });
}
