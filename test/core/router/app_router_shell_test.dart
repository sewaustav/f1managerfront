import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/router/app_router.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/standing.dart';

class _FakeWs extends WsService {
  _FakeWs() : super(wsUrl: 'ws://x', accessToken: (() async => 't'));
  @override
  void send(Map<String, dynamic> json) {}
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async => const [];
  @override
  Future<List<Team>> getTeams() async => const [];
}

class _FakeSeasonRepo extends SeasonRepository {
  _FakeSeasonRepo() : super(Dio());
  @override
  Future<Standing> getStanding() async => const Standing();
}

void main() {
  testWidgets('authed+group renders shell and can switch to Standings', (tester) async {
    final container = ProviderContainer(overrides: [
      isAuthenticatedProvider.overrideWith((ref) => true),
      hasGroupProvider.overrideWith((ref) => true),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
      wsServiceProvider.overrideWithValue(_FakeWs()),
      draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
      seasonRepositoryProvider.overrideWithValue(_FakeSeasonRepo()),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    router.go('/standings');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Standings'), findsWidgets);
    expect(find.text('WDC'), findsOneWidget);
  });
}
