import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/inter_season/model/transfer_events.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';

void main() {


  test('isSeasonStarted true only for season_started', () {
    expect(isSeasonStarted(const WsMessage('season_started', {'type': 'season_started'})), isTrue);
    expect(isSeasonStarted(const WsMessage('race_finished', {'type': 'race_finished'})), isFalse);
  });


  test('MyTeamSummary.fromJson maps nested PascalCase', () {
    final s = MyTeamSummary.fromJson({
      'id': 1,
      'pilot1': {'ID': 10, 'Name': 'Max', 'Price': 50, 'Sponsors': 5},
      'pilot2': {'ID': 11, 'Name': 'Lando', 'Price': 30},
      'team': {'ID': 3, 'Name': 'RB', 'BaseLevel': 4, 'Engineer': 2, 'TubeLevel': 3, 'SimLevel': 1},
      'team_principal': {'ID': 9, 'Name': 'Toto', 'Price': 20, 'Level': 5},
    });
    expect(s.pilot1.id, 10);
    expect(s.pilot1.sponsors, 5);
    expect(s.team.baseLevel, 4);
    expect(s.principal.level, 5);
  });
}
