import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
