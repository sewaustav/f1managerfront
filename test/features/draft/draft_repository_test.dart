import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late DraftRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
    adapter = DioAdapter(dio: dio);
    repo = DraftRepository(dio);
  });

  test('getPilots parses PascalCase list', () async {
    adapter.onGet('/pilots', (s) => s.reply(200, [
          {'ID': 1, 'Name': 'Max', 'Rating': 98, 'Price': 40, 'Sponsors': 5},
        ]));
    final pilots = await repo.getPilots();
    expect(pilots.single.name, 'Max');
    expect(pilots.single.rating, 98);
  });

  test('getBudget parses {budget, tokens}', () async {
    adapter.onGet('/budget', (s) => s.reply(200, {'budget': 110, 'tokens': 35}));
    final b = await repo.getBudget();
    expect(b.budget, 110);
    expect(b.tokens, 35);
  });

  test('pick posts pick/item_id/engine', () async {
    adapter.onPost('/draft/pick', (s) => s.reply(200, {'message': 'ok'}),
        data: {'pick': 1, 'item_id': 7, 'engine': 2});
    await repo.pick(pick: 1, itemId: 7, engine: 2);
  });

  test('pick omits engine when null', () async {
    adapter.onPost('/draft/pick', (s) => s.reply(200, {'message': 'ok'}),
        data: {'pick': 0, 'item_id': 3});
    await repo.pick(pick: 0, itemId: 3);
  });

  test('getDraftState parses active/round/is_my_turn/finished/current_user_id', () async {
    adapter.onGet('/draft/state', (s) => s.reply(200, {
          'active': true,
          'round': 2,
          'is_my_turn': true,
          'finished': false,
          'current_user_id': 5,
        }));
    final st = await repo.getDraftState();
    expect(st.active, isTrue);
    expect(st.round, 2);
    expect(st.isMyTurn, isTrue);
    expect(st.finished, isFalse);
    expect(st.currentUserId, 5);
  });
}
