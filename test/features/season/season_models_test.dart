import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/features/season/model/setup_payload.dart';
import 'package:f1manager/features/season/model/setup_preset.dart';
import 'package:f1manager/features/season/model/track_info.dart';
import 'package:f1manager/features/season/model/race_result.dart';
import 'package:f1manager/features/season/model/standing.dart';

void main() {
  test('SetupPayload.toJson uses backend snake_case keys', () {
    const p = SetupPayload(
      name: 'race', aeroDynamic: 6, engine: 5, chassis: 4,
      floor: 3, tyres: 2, reliability: 10, settingsAngle: 1,
    );
    final j = p.toJson();
    expect(j['aero_dynamic'], 6);
    expect(j['settings_angle'], 1);
    expect(j['reliability'], 10);
    expect(j.containsKey('aeroDynamic'), isFalse);
  });

  test('SetupPayload.fromPreset copies fields', () {
    const preset = SetupPreset(name: 'x', aeroDynamic: 7, settingsAngle: 1);
    final p = SetupPayload.fromPreset(preset, name: 'race');
    expect(p.aeroDynamic, 7);
    expect(p.settingsAngle, 1);
    expect(p.name, 'race');
  });

  test('TrackInfo maps PascalCase', () {
    final t = TrackInfo.fromJson({
      'ID': 3, 'Name': 'Monaco', 'DownForceLevel': 0, 'Type': 1,
      'Difficulty': 80, 'QualifyingImpact': 0, 'RainPossibility': 40, 'Tyre': 2,
    });
    expect(t.name, 'Monaco');
    expect(t.difficulty, 80);
    expect(t.rainPossibility, 40);
  });

  test('RaceResultResponse maps stage + snake_case results', () {
    final r = RaceResultResponse.fromJson({
      'stage': 5,
      'results': [
        {'pilot_id': 1, 'garage_id': 2, 'pilot_name': 'Max', 'team_name': 'Reds',
         'quali_position': 1, 'race_position': 1, 'points': 25, 'is_dnf': false, 'dnf_reason': ''},
      ],
    });
    expect(r.stage, 5);
    expect(r.results.single.pilotName, 'Max');
    expect(r.results.single.racePosition, 1);
    expect(r.results.single.isDnf, isFalse);
  });

  test('Standing maps driver/team point maps', () {
    final s = Standing.fromJson({'drivers': {'1': 25, '2': 18}, 'teams': {'1': 43}});
    expect(s.drivers['1'], 25);
    expect(s.teams['1'], 43);
  });
}
