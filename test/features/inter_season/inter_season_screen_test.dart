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
import 'package:f1manager/features/inter_season/model/transfer_offer.dart';
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

  List<TransferOffer> offers = const [];
  int? respondedOfferId;
  bool? respondedAccept;

  @override
  Future<List<TransferOffer>> getIncomingOffers() async => offers;

  @override
  Future<void> respondToOffer({required int offerId, required bool accept}) async {
    respondedOfferId = offerId;
    respondedAccept = accept;
    offers = offers.where((o) => o.id != offerId).toList();
  }
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
    expect(find.text('Предложение отправлено'), findsOneWidget);
  });

  // Обмен между игроками больше не живёт во всплывающем диалоге, привязанном
  // к моменту запроса покупателя: предложения хранятся на сервере и
  // отвечаются обычным запросом, поэтому владелец может быть офлайн.
  testWidgets('входящее предложение видно и принимается', (tester) async {
    final repo = _FakeRepo();
    repo.offers = [
      const TransferOffer(
          id: 5, pilotId: 7, pilotName: 'Леклер', buyerId: 2, buyerName: 'Второй', price: 40),
    ];

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

    expect(find.text('Леклер'), findsOneWidget);
    expect(find.textContaining('Второй'), findsOneWidget);

    await tester.tap(find.byKey(const Key('accept_offer_5')));
    await tester.pumpAndSettle();

    expect(repo.respondedOfferId, 5);
    expect(repo.respondedAccept, isTrue);
  });

  testWidgets('входящее предложение отклоняется', (tester) async {
    final repo = _FakeRepo();
    repo.offers = [
      const TransferOffer(
          id: 6, pilotId: 7, pilotName: 'Леклер', buyerId: 2, buyerName: 'Второй', price: 40),
    ];

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

    await tester.tap(find.byKey(const Key('decline_offer_6')));
    await tester.pumpAndSettle();

    expect(repo.respondedOfferId, 6);
    expect(repo.respondedAccept, isFalse);
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
