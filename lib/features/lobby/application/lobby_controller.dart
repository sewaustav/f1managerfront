import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/lobby_repository.dart';
import '../model/group_requests.dart';
import '../model/player.dart';

final hasGroupProvider = StateProvider<bool>((ref) => false);

final playersProvider = FutureProvider.autoDispose<List<Player>>(
    (ref) => ref.watch(lobbyRepositoryProvider).getPlayers());

class LobbyController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(String name, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(lobbyRepositoryProvider).createGroup(
            CreateGroupRequest(name: name, password: password),
          );
      ref.read(hasGroupProvider.notifier).state = true;
    });
  }

  Future<void> join(int id, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(lobbyRepositoryProvider).joinGroup(
            JoinGroupRequest(id: id, password: password),
          );
      ref.read(hasGroupProvider.notifier).state = true;
    });
  }

  Future<void> startDraft() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(lobbyRepositoryProvider).startDraft());
  }
}

final lobbyControllerProvider =
    AutoDisposeAsyncNotifierProvider<LobbyController, void>(LobbyController.new);
