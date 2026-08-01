import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/core/storage/token_store.dart';
import 'package:f1manager/core/ws/ws_channel_factory.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/season/application/season_state_provider.dart';
import 'package:f1manager/features/season/data/season_state_repository.dart';
import 'package:dio/dio.dart';

class _FakeTokenStore implements TokenStore {
  @override
  Future<void> save({required String access, required String refresh}) async {}
  @override
  Future<String?> readAccess() async => 'tok';
  @override
  Future<String?> readRefresh() async => null;
  @override
  Future<void> clear() async {}
}

class _FakeSeasonStateRepo extends SeasonStateRepository {
  _FakeSeasonStateRepo() : super(Dio());
  int calls = 0;
  @override
  Future<SeasonState> getSeasonState() async {
    calls++;
    return SeasonState(phase: SeasonPhase.racing, stage: calls);
  }
}

void main() {
  test('authWsUri appends token query param', () {
    final uri = authWsUri('ws://localhost:8080/api/v1/ws', 'JWT123');
    expect(uri.queryParameters['token'], 'JWT123');
    expect(uri.scheme, 'ws');
    expect(uri.path, '/api/v1/ws');
  });

  test('authWsUri with null token yields empty token param', () {
    final uri = authWsUri('ws://localhost:8080/api/v1/ws', null);
    expect(uri.queryParameters['token'], '');
  });

  test('wsServiceProvider wires onReconnect to refresh season state', () async {
    final repo = _FakeSeasonStateRepo();
    final container = ProviderContainer(overrides: [
      tokenStoreProvider.overrideWithValue(_FakeTokenStore()),
      seasonStateRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    // Seed the initial fetch (build()) so we can isolate the reconnect call.
    await container.read(seasonStateProvider.future);
    expect(repo.calls, 1);

    final ws = container.read(wsServiceProvider);
    expect(ws.onReconnect, isNotNull);
    await ws.onReconnect!.call();

    expect(repo.calls, 2);
  });
}
