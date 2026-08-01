import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/core/models/principal.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';
import 'package:f1manager/features/my_team/presentation/my_team_screen.dart';

class _FakeIsRepo extends InterSeasonRepository {
  _FakeIsRepo() : super(Dio());
  @override
  Future<MyTeamSummary> getMyTeam() async => const MyTeamSummary(
        id: 1,
        pilot1: Pilot(id: 10, name: 'Max', rating: 95),
        pilot2: Pilot(id: 11, name: 'Lando', rating: 88),
        team: Team(id: 3, name: 'RB', carLevel: 7, baseLevel: 4),
        principal: Principal(id: 9, name: 'Toto', level: 5),
      );
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<Budget> getBudget() async => const Budget(budget: 120, tokens: 30);
}

void main() {
  testWidgets('renders team, pilots, principal, budget', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        interSeasonRepositoryProvider.overrideWithValue(_FakeIsRepo()),
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
}
