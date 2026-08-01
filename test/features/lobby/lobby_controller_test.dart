import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/lobby/data/lobby_repository.dart';
import 'package:f1manager/features/lobby/model/group_requests.dart';

class _MockRepo extends Mock implements LobbyRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CreateGroupRequest(name: 'x', password: 'y'));
    registerFallbackValue(const JoinGroupRequest(id: 1, password: 'y'));
  });

  test('successful create sets hasGroup true', () async {
    final repo = _MockRepo();
    when(() => repo.createGroup(any())).thenAnswer((_) async {});
    final container = ProviderContainer(
        overrides: [lobbyRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    container.listen(lobbyControllerProvider, (_, __) {}); // keep alive (autoDispose)

    await container.read(lobbyControllerProvider.notifier).create('Reds', 'pw');

    expect(container.read(hasGroupProvider), isTrue);
    expect(container.read(lobbyControllerProvider).hasError, isFalse);
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
  });
}
