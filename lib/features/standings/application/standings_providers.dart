import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../draft/data/draft_repository.dart';
import '../../season/data/season_repository.dart';

class StandingRow {
  const StandingRow(this.name, this.points);
  final String name;
  final int points;
}

List<StandingRow> _rank(Map<String, int> points, Map<int, String> names) {
  final rows = points.entries.map((e) {
    final id = int.tryParse(e.key) ?? -1;
    return StandingRow(names[id] ?? '#${e.key}', e.value);
  }).toList()
    ..sort((a, b) => b.points.compareTo(a.points));
  return rows;
}

final driverStandingsProvider = FutureProvider.autoDispose<List<StandingRow>>((ref) async {
  final standing = await ref.watch(seasonRepositoryProvider).getStanding();
  final pilots = await ref.watch(draftRepositoryProvider).getPilots();
  return _rank(standing.drivers, {for (final p in pilots) p.id: p.name});
});

final teamStandingsProvider = FutureProvider.autoDispose<List<StandingRow>>((ref) async {
  final standing = await ref.watch(seasonRepositoryProvider).getStanding();
  final teams = await ref.watch(draftRepositoryProvider).getTeams();
  return _rank(standing.teams, {for (final t in teams) t.id: t.name});
});
