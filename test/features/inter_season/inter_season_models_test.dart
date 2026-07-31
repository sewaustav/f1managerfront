import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/inter_season/model/transfer_events.dart';
import 'package:f1manager/features/inter_season/model/my_team_summary.dart';

void main() {
  test('transferRequestFromMessage parses pilot_id + price', () {
    final m = WsMessage('transfer_request', {'type': 'transfer_request', 'pilot_id': 7, 'price': 40});
    final r = transferRequestFromMessage(m)!;
    expect(r.pilotId, 7);
    expect(r.price, 40);
  });

  test('transferRequestFromMessage returns null for other types', () {
    expect(transferRequestFromMessage(WsMessage('draft_turn', {'type': 'draft_turn'})), isNull);
  });

  test('isSeasonStarted true only for season_started', () {
    expect(isSeasonStarted(WsMessage('season_started', {'type': 'season_started'})), isTrue);
    expect(isSeasonStarted(WsMessage('race_finished', {'type': 'race_finished'})), isFalse);
  });

  test('transferResponsePayload shape', () {
    expect(transferResponsePayload(pilotId: 7, accept: true),
        {'type': 'transfer_response', 'pilot_id': 7, 'accept': true});
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
