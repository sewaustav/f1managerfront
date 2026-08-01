import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
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
  Future<List<Pilot>> getPilots() async => const [Pilot(id: 1, name: 'Free', team: null)];
  @override
  Future<List<Principal>> getPrincipals() async => const [Principal(id: 9, name: 'Toto')];
}

class _FakeRepo extends InterSeasonRepository {
  _FakeRepo() : super(Dio());
  @override
  Future<MyTeamSummary> getMyTeam() async => const MyTeamSummary(
        id: 1,
        pilot1: Pilot(id: 10, name: 'Max'),
        pilot2: Pilot(id: 11, name: 'Lando'),
        team: Team(id: 3, name: 'RB'),
        principal: Principal(id: 9, name: 'Toto'),
      );
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
}
