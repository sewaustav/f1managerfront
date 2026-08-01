import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/token_pair.dart';
import 'package:f1manager/core/models/season_state.dart';

void main() {
  test('TokenPair.fromJson maps snake_case', () {
    final t = TokenPair.fromJson({'access_token': 'a', 'refresh_token': 'r'});
    expect(t.accessToken, 'a');
    expect(t.refreshToken, 'r');
  });

  test('SeasonState maps phase string + snake_case fields', () {
    final s = SeasonState.fromJson({
      'phase': 'token_setup',
      'stage': 3,
      'submitted_setups': [1, 2],
      'total_players': 4,
    });
    expect(s.phase, SeasonPhase.tokenSetup);
    expect(s.stage, 3);
    expect(s.submittedSetups, [1, 2]);
    expect(s.totalPlayers, 4);
  });

  test('SeasonState unknown phase falls back', () {
    final s = SeasonState.fromJson({
      'phase': 'weird',
      'stage': 0,
      'submitted_setups': [],
      'total_players': 0,
    });
    expect(s.phase, SeasonPhase.unknown);
  });
}
