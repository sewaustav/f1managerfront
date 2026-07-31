import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late InterSeasonRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = InterSeasonRepository(dio);
  });

  test('getMyTeam parses nested my-team', () async {
    adapter.onGet('/my-team', (s) => s.reply(200, {
          'id': 1,
          'pilot1': {'ID': 10, 'Name': 'Max'},
          'pilot2': {'ID': 11, 'Name': 'Lando'},
          'team': {'ID': 3, 'Name': 'RB', 'BaseLevel': 4},
          'team_principal': {'ID': 9, 'Name': 'Toto'},
        }));
    final t = await repo.getMyTeam();
    expect(t.pilot1.id, 10);
    expect(t.team.baseLevel, 4);
  });

  test('buyPilot posts pilot_id + price', () async {
    adapter.onPost('/transfers/pilot', (s) => s.reply(200, {'ok': true}),
        data: {'pilot_id': 7, 'price': 40});
    await repo.buyPilot(pilotId: 7, price: 40);
  });

  test('hirePrincipal posts principal_id + price', () async {
    adapter.onPost('/transfers/principal', (s) => s.reply(200, {'ok': true}),
        data: {'principal_id': 9, 'price': 20});
    await repo.hirePrincipal(principalId: 9, price: 20);
  });

  test('fire posts who + id', () async {
    adapter.onPost('/fire', (s) => s.reply(200, {'ok': true}), data: {'who': 'pilot', 'id': 10});
    await repo.fire(who: 'pilot', id: 10);
  });

  test('updateBase posts all four levels', () async {
    adapter.onPost('/base', (s) => s.reply(200, {'ok': true}),
        data: {'base': 8, 'engineer': 3, 'tube': 2, 'sim': 4});
    await repo.updateBase(base: 8, engineer: 3, tube: 2, sim: 4);
  });

  test('markReady posts to /ready', () async {
    adapter.onPost('/ready', (s) => s.reply(200, {'ok': true}));
    await repo.markReady();
  });
}
