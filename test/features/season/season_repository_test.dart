import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/setup_payload.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late SeasonRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = SeasonRepository(dio);
  });

  test('submitTokenSetup posts the payload', () async {
    adapter.onPost('/token-setup', (s) => s.reply(200, {'ok': true}),
        data: {'name': 'S1', 'aero_dynamic': 6, 'engine': 5, 'chassis': 4,
               'floor': 3, 'tyres': 2, 'reliability': 10, 'settings_angle': 1});
    await repo.submitTokenSetup(const SetupPayload(
      name: 'S1', aeroDynamic: 6, engine: 5, chassis: 4,
      floor: 3, tyres: 2, reliability: 10, settingsAngle: 1));
  });

  test('getRaceResult parses stage + results', () async {
    adapter.onGet('/race-result', (s) => s.reply(200, {
          'stage': 2,
          'results': [
            {'pilot_id': 1, 'pilot_name': 'Max', 'race_position': 1, 'points': 25, 'is_dnf': false},
          ],
        }));
    final r = await repo.getRaceResult();
    expect(r.stage, 2);
    expect(r.results.single.pilotName, 'Max');
  });

  test('initRound posts to /rounds/:stage/init', () async {
    adapter.onPost('/rounds/3/init', (s) => s.reply(200, {'message': 'ok'}));
    await repo.initRound(3);
  });

  test('makeUpdate posts type/coast/stage', () async {
    adapter.onPost('/updates', (s) => s.reply(200, {'ok': true}),
        data: {'type': 0, 'coast': 12, 'stage': 3});
    await repo.makeUpdate(type: 0, coast: 12, stage: 3);
  });
}
