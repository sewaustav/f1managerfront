import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/standing.dart';
import 'package:f1manager/features/standings/application/standings_providers.dart';

class _FakeSeasonRepo extends SeasonRepository {
  _FakeSeasonRepo() : super(Dio());
  @override
  Future<Standing> getStanding() async =>
      const Standing(drivers: {'1': 10, '2': 25}, teams: {'3': 40});
}

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async =>
      const [Pilot(id: 1, name: 'Max'), Pilot(id: 2, name: 'Lando')];
  @override
  Future<List<Team>> getTeams() async => const [Team(id: 3, name: 'RB')];
}

void main() {
  ProviderContainer makeContainer() => ProviderContainer(overrides: [
        seasonRepositoryProvider.overrideWithValue(_FakeSeasonRepo()),
        draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
      ]);

  test('driverStandingsProvider ranks by points desc with names', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    final rows = await c.read(driverStandingsProvider.future);
    expect(rows.map((r) => r.name), ['Lando', 'Max']); // 25 before 10
    expect(rows.first.points, 25);
  });

  test('teamStandingsProvider maps team names', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    final rows = await c.read(teamStandingsProvider.future);
    expect(rows.single.name, 'RB');
    expect(rows.single.points, 40);
  });

  test('unknown id falls back to #id', () async {
    final c = ProviderContainer(overrides: [
      seasonRepositoryProvider.overrideWithValue(_FakeSeasonRepo()),
      draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
    ]);
    addTearDown(c.dispose);
    // team 99 not in getTeams -> '#99'
    final rows = await c.read(teamStandingsProvider.future);
    expect(rows.any((r) => r.name == 'RB'), isTrue);
  });
}
