import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/lobby/data/lobby_repository.dart';
import 'package:f1manager/features/lobby/model/group_requests.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late LobbyRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = LobbyRepository(dio);
  });

  test('createGroup posts name+password', () async {
    adapter.onPost('/groups', (s) => s.reply(200, {'message': 'group registered'}),
        data: {'name': 'Reds', 'password': 'pw'});
    await repo.createGroup(const CreateGroupRequest(name: 'Reds', password: 'pw'));
  });

  test('joinGroup posts id+password', () async {
    adapter.onPost('/groups/join', (s) => s.reply(200, {'message': 'group joined'}),
        data: {'id': 7, 'password': 'pw'});
    await repo.joinGroup(const JoinGroupRequest(id: 7, password: 'pw'));
  });

  test('getPlayers parses PascalCase Player list', () async {
    adapter.onGet('/players', (s) => s.reply(200, [
          {'ID': 1, 'Name': 'Joe', 'TeamPrincipal': null, 'Team': 3, 'Budget': 110, 'Tokens': 35},
        ]));
    final players = await repo.getPlayers();
    expect(players.single.id, 1);
    expect(players.single.name, 'Joe');
    expect(players.single.teamPrincipal, isNull);
    expect(players.single.team, 3);
    expect(players.single.budget, 110);
    expect(players.single.tokens, 35);
  });
}
