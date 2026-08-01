import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/info/data/info_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late InfoRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = InfoRepository(dio);
  });

  test('getSquads parses a list of MyTeam objects', () async {
    adapter.onGet('/players/squads', (s) => s.reply(200, [
          {
            'id': 1,
            'pilot1': {'ID': 10, 'Name': 'Max'},
            'pilot2': {'ID': 11, 'Name': 'Lando'},
            'team': {'ID': 3, 'Name': 'RB'},
            'team_principal': {'ID': 9, 'Name': 'Toto'},
          },
          {
            'id': 2,
            'pilot1': {'ID': 20, 'Name': 'Lewis'},
            'pilot2': {'ID': 21, 'Name': 'George'},
            'team': {'ID': 4, 'Name': 'Merc'},
            'team_principal': {'ID': 8, 'Name': 'Fred'},
          },
        ]));
    final squads = await repo.getSquads();
    expect(squads.length, 2);
    expect(squads.first.team.name, 'RB');
    expect(squads[1].pilot1.name, 'Lewis');
  });
}
