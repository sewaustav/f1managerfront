import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/features/season/data/season_state_repository.dart';

void main() {
  test('getSeasonState parses phase/stage/submitted/total', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/season/state', (s) => s.reply(200, {
          'phase': 'racing',
          'stage': 3,
          'submitted_setups': [1, 2],
          'total_players': 4,
        }));
    final st = await SeasonStateRepository(dio).getSeasonState();
    expect(st.phase, SeasonPhase.racing);
    expect(st.stage, 3);
    expect(st.submittedSetups, [1, 2]);
    expect(st.totalPlayers, 4);
  });

  test('unknown phase string maps to SeasonPhase.unknown', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/season/state', (s) => s.reply(200, {'phase': 'weird'}));
    final st = await SeasonStateRepository(dio).getSeasonState();
    expect(st.phase, SeasonPhase.unknown);
  });
}
