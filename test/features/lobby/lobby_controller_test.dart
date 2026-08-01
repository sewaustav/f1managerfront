import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/storage/token_store.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/lobby/data/lobby_repository.dart';
import 'package:f1manager/features/lobby/model/group_requests.dart';

class _MockRepo extends Mock implements LobbyRepository {}

String _fakeJwt(int sub) {
  String seg(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${seg({
        'alg': 'RS256'
      })}.${seg({
        'sub': '$sub'
      })}.sig';
}

void main() {
  setUpAll(() {
    registerFallbackValue(const CreateGroupRequest(name: 'x', password: 'y'));
    registerFallbackValue(const JoinGroupRequest(id: 1, password: 'y'));
  });

  test('successful create sets hasGroup true and decodes own id as group id', () async {
    final repo = _MockRepo();
    when(() => repo.createGroup(any())).thenAnswer((_) async {});
    final tokenStore = InMemoryTokenStore();
    await tokenStore.save(access: _fakeJwt(42), refresh: 'r');
    final container = ProviderContainer(overrides: [
      lobbyRepositoryProvider.overrideWithValue(repo),
      tokenStoreProvider.overrideWithValue(tokenStore),
    ]);
    addTearDown(container.dispose);
    container.listen(lobbyControllerProvider, (_, __) {}); // keep alive (autoDispose)

    await container.read(lobbyControllerProvider.notifier).create('Reds', 'pw');

    expect(container.read(hasGroupProvider), isTrue);
    expect(container.read(lobbyControllerProvider).hasError, isFalse);
    expect(container.read(myGroupIdProvider), 42);
  });

  test('successful join sets hasGroup true and remembers the entered id', () async {
    final repo = _MockRepo();
    when(() => repo.joinGroup(any())).thenAnswer((_) async {});
    final container = ProviderContainer(
        overrides: [lobbyRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    container.listen(lobbyControllerProvider, (_, __) {}); // keep alive (autoDispose)

    await container.read(lobbyControllerProvider.notifier).join(7, 'pw');

    expect(container.read(hasGroupProvider), isTrue);
    expect(container.read(myGroupIdProvider), 7);
  });

  test('failed join keeps hasGroup false and surfaces error', () async {
    final repo = _MockRepo();
    when(() => repo.joinGroup(any())).thenThrow(Exception('wrong password'));
    final container = ProviderContainer(
        overrides: [lobbyRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    container.listen(lobbyControllerProvider, (_, __) {}); // keep alive (autoDispose)

    await container.read(lobbyControllerProvider.notifier).join(7, 'nope');

    expect(container.read(hasGroupProvider), isFalse);
    expect(container.read(lobbyControllerProvider).hasError, isTrue);
    expect(container.read(myGroupIdProvider), isNull);
  });
}
