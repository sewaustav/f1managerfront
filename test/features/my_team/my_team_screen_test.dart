import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/lobby/data/lobby_repository.dart';
import 'package:f1manager/features/my_team/presentation/my_team_screen.dart';

class _FakeIsRepo extends InterSeasonRepository {
  _FakeIsRepo(this._team) : super(Dio());
  final MyTeamSummary _team;
  @override
  Future<MyTeamSummary> getMyTeam() async => _team;
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<Budget> getBudget() async => const Budget(budget: 120, tokens: 30);
}

class _MockLobbyRepo extends Mock implements LobbyRepository {}

const _fullTeam = MyTeamSummary(
  id: 1,
  pilot1: Pilot(id: 10, name: 'Max', rating: 95),
  pilot2: Pilot(id: 11, name: 'Lando', rating: 88),
  team: Team(id: 3, name: 'RB', carLevel: 7, baseLevel: 4),
  principal: Principal(id: 9, name: 'Toto', level: 5),
);

const _emptyTeam = MyTeamSummary(
  id: 1,
  pilot1: Pilot(id: 0, name: ''),
  pilot2: Pilot(id: 0, name: ''),
  team: Team(id: 0, name: ''),
  principal: Principal(id: 0, name: ''),
);

void main() {
  testWidgets('renders team, pilots, principal, budget', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        interSeasonRepositoryProvider.overrideWithValue(_FakeIsRepo(_fullTeam)),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
      ],
      child: const MaterialApp(home: MyTeamScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('RB'), findsOneWidget);
    expect(find.textContaining('Max'), findsOneWidget);
    expect(find.textContaining('Toto'), findsOneWidget);
    expect(find.textContaining('120'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  // Before a player finishes drafting (or the draft hasn't started), the
  // backend now returns zero-value team/pilots/principal instead of a
  // "redis: not found" error — the screen must show friendly placeholders
  // rather than blank names.
  testWidgets('shows placeholders when nothing has been picked yet', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        interSeasonRepositoryProvider.overrideWithValue(_FakeIsRepo(_emptyTeam)),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
      ],
      child: const MaterialApp(home: MyTeamScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Команда ещё не выбрана'), findsOneWidget);
    expect(find.text('Пилоты ещё не выбраны'), findsOneWidget);
    expect(find.text('Руководитель ещё не выбран'), findsOneWidget);
  });

  testWidgets('organizer sees the end-game-early action', (tester) async {
    final lobbyRepo = _MockLobbyRepo();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        interSeasonRepositoryProvider.overrideWithValue(_FakeIsRepo(_fullTeam)),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        lobbyRepositoryProvider.overrideWithValue(lobbyRepo),
        myGroupIdProvider.overrideWith((ref) => 42),
        currentUserIdProvider.overrideWith((ref) => 42),
      ],
      child: const MaterialApp(home: MyTeamScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('end_game_early_button')), findsOneWidget);
  });

  testWidgets('non-organizer does not see the end-game-early action', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        interSeasonRepositoryProvider.overrideWithValue(_FakeIsRepo(_fullTeam)),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
        myGroupIdProvider.overrideWith((ref) => 7),
        currentUserIdProvider.overrideWith((ref) => 42),
      ],
      child: const MaterialApp(home: MyTeamScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('end_game_early_button')), findsNothing);
  });
}
