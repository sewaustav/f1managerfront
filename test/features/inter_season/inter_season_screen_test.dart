import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/core/router/app_shell.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';
import 'package:f1manager/features/inter_season/presentation/inter_season_screen.dart';
import 'package:f1manager/core/models/team.dart';

class _FakeWs extends WsService {
  _FakeWs() : super(wsUrl: 'ws://x', accessToken: (() async => 't'));
  @override
  void send(Map<String, dynamic> json) {}
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async => const [
        Pilot(id: 1, name: 'Free', team: null),
        Pilot(id: 2, name: 'Owned', team: 3),
      ];
  @override
  Future<List<Principal>> getPrincipals() async => const [Principal(id: 9, name: 'Toto')];
  @override
  Future<Budget> getBudget() async => const Budget(budget: 500, tokens: 3);
}

class _FakeRepo extends InterSeasonRepository {
  _FakeRepo() : super(Dio());
  String? firedWho;
  int? firedId;
  @override
  Future<MyTeamSummary> getMyTeam() async => const MyTeamSummary(
        id: 1,
        pilot1: Pilot(id: 10, name: 'Max'),
        pilot2: Pilot(id: 11, name: 'Lando'),
        team: Team(id: 3, name: 'RB'),
        principal: Principal(id: 9, name: 'Toto'),
      );
  @override
  Future<void> fire({required String who, required int id}) async {
    firedWho = who;
    firedId = id;
  }

  @override
  Future<void> buyPilot({required int pilotId, required int price}) async {}
}

void main() {
  testWidgets('renders four tabs', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: const MaterialApp(home: InterSeasonScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Transfers'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('Transfers tab shows roster, free pilot, owned pilot, and Fire buttons',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: const MaterialApp(home: InterSeasonScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Lando'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Owned'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Fire'), findsNWidgets(2));
  });

  testWidgets('tapping Fire on a roster pilot calls repo.fire and shows Pilot fired',
      (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        interSeasonRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: InterSeasonScreen()),
    ));
    await tester.pumpAndSettle();

    final maxTile = find.byKey(const ValueKey(10));
    final fireInMaxTile = find.descendant(of: maxTile, matching: find.text('Fire'));
    await tester.tap(fireInMaxTile);
    await tester.pump();
    await tester.pump();

    expect(repo.firedWho, 'pilot');
    expect(repo.firedId, 10);
    expect(find.text('Pilot fired'), findsOneWidget);
  });

  testWidgets('buying the free pilot shows Bought', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: const MaterialApp(home: InterSeasonScreen()),
    ));
    await tester.pumpAndSettle();

    final freeTile = find.ancestor(of: find.text('Free'), matching: find.byType(ListTile));
    final buyButton = find.descendant(of: freeTile, matching: find.widgetWithText(FilledButton, 'Buy'));
    await tester.tap(buyButton);
    await tester.pump();
    await tester.pump();
    expect(find.text('Bought'), findsOneWidget);
  });

  testWidgets('buying the owned pilot shows Offer sent', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: const MaterialApp(home: InterSeasonScreen()),
    ));
    await tester.pumpAndSettle();

    final ownedTile = find.ancestor(of: find.text('Owned'), matching: find.byType(ListTile));
    final buyButton = find.descendant(of: ownedTile, matching: find.widgetWithText(FilledButton, 'Buy'));
    await tester.tap(buyButton);
    await tester.pump();
    await tester.pump();
    expect(find.text('Offer sent'), findsOneWidget);
  });

  testWidgets(
      'season_started while an incoming-offer dialog is open does not throw '
      '(mounted guard after showIncomingOfferDialog)', (tester) async {
    final ws = StreamController<WsMessage>.broadcast();
    addTearDown(ws.close);

    // Both routes render through a keyless CustomTransitionPage, so
    // go_router/Flutter treat the /inter-season -> /token-setup navigation as
    // an in-place content swap of the same Page rather than a page
    // add/remove with an exit transition. That disposes InterSeasonScreen's
    // State immediately, while the offer dialog it opened (a separate,
    // still-mounted route pushed on top) is left open/orphaned — exactly the
    // "widget disposed while the dialog is still pending" situation the
    // mounted guard protects against.
    Page<void> samePage(Widget child) => CustomTransitionPage<void>(
          child: child,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, c) => c,
        );

    final router = GoRouter(
      initialLocation: '/inter-season',
      routes: [
        GoRoute(
          path: '/inter-season',
          pageBuilder: (_, __) => samePage(const InterSeasonScreen()),
        ),
        GoRoute(
          path: '/token-setup',
          pageBuilder: (_, __) => samePage(const Scaffold(body: Text('token-setup'))),
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        wsMessagesProvider.overrideWith((ref) => ws.stream),
        wsServiceProvider.overrideWithValue(_FakeWs()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    // Deliver a transfer_request over the WS stream: the screen's ref.listen
    // picks it up and opens the incoming-offer dialog via _drainOffers().
    ws.add(const WsMessage('transfer_request', {'type': 'transfer_request', 'pilot_id': 7, 'price': 40}));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Transfer offer'), findsOneWidget);

    // Deliver season_started while the dialog's Future is still pending.
    // This drives context.go('/token-setup'), which (per the router setup
    // above) disposes InterSeasonScreen's State right away, well before the
    // still-open dialog is ever resolved.
    ws.add(const WsMessage('season_started', {'type': 'season_started'}));
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }
    expect(find.byType(InterSeasonScreen), findsNothing,
        reason: 'InterSeasonScreen should already be disposed at this point');
    expect(find.text('Transfer offer'), findsOneWidget,
        reason: 'the offer dialog is orphaned, still open on top of /token-setup');

    // Now resolve the orphaned dialog (as if the user finally dismissed it).
    // Previously, the ref.read(...) calls after the await in _drainOffers()
    // ran on the already-disposed ConsumerState and threw
    // "Cannot use "ref" after the widget was disposed."
    await tester.tap(find.text('Decline'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('offstage nav guard', () {
    GoRouter buildShellRouter({required String initialLocation}) {
      return GoRouter(
        initialLocation: initialLocation,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) => AppShell(navigationShell: shell),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/inter-season',
                  builder: (_, __) => const InterSeasonScreen(),
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
        'season_started while a DIFFERENT branch is active does not navigate away',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final ws = StreamController<WsMessage>.broadcast();
      addTearDown(ws.close);

      // Start on the InterSeason branch so it gets built (StatefulShellBranch
      // branches are lazily built on first visit), then switch to the
      // Standings branch — exactly like a user tabbing away. IndexedStack
      // keeps InterSeasonScreen mounted offstage from then on.
      final router = buildShellRouter(initialLocation: '/inter-season');

      await tester.pumpWidget(ProviderScope(
        overrides: [
          wsMessagesProvider.overrideWith((ref) => ws.stream),
          wsServiceProvider.overrideWithValue(_FakeWs()),
          draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
          interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(InterSeasonScreen), findsOneWidget);

      await tester.tap(find.text('Standings'));
      await tester.pumpAndSettle();

      // InterSeasonScreen is mounted offstage (IndexedStack keeps every
      // branch alive), but the user is looking at Standings. Finders skip
      // offstage widgets by default, so opt back in to prove it's still
      // there — just not visible.
      expect(find.text('STANDINGS'), findsOneWidget);
      expect(find.byType(InterSeasonScreen, skipOffstage: false), findsOneWidget);

      ws.add(const WsMessage('season_started', {'type': 'season_started'}));
      await tester.pump();
      await tester.pumpAndSettle();

      // The WS-driven auto-navigation must NOT hijack the user off the tab
      // they're on.
      expect(find.text('STANDINGS'), findsOneWidget);
      expect(find.text('token-setup'), findsNothing);
    });

    testWidgets('season_started while the InterSeason branch is active navigates',
        (tester) async {
      final ws = StreamController<WsMessage>.broadcast();
      addTearDown(ws.close);

      final router = buildShellRouter(initialLocation: '/inter-season');

      await tester.pumpWidget(ProviderScope(
        overrides: [
          wsMessagesProvider.overrideWith((ref) => ws.stream),
          wsServiceProvider.overrideWithValue(_FakeWs()),
          draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
          interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();

      ws.add(const WsMessage('season_started', {'type': 'season_started'}));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('token-setup'), findsOneWidget);
    });
  });
}
