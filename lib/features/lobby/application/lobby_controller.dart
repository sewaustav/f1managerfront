import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/api/jwt_decode.dart';
import '../data/lobby_repository.dart';
import '../model/group_requests.dart';
import '../model/player.dart';

final hasGroupProvider = StateProvider<bool>((ref) => false);

/// The current group's numeric id — needed to invite others via "Join a
/// group". The backend's create-group response carries no id, and its scheme
/// is `groupID == creator's own userID`, so on create we decode it from our
/// own JWT; on join we already typed the id in, so we just remember it.
final myGroupIdProvider = StateProvider<int?>((ref) => null);

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
      final token = await ref.read(tokenStoreProvider).readAccess();
      ref.read(myGroupIdProvider.notifier).state =
          token == null ? null : userIdFromJwt(token);
      ref.read(hasGroupProvider.notifier).state = true;
    });
  }

  Future<void> join(int id, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(lobbyRepositoryProvider).joinGroup(
            JoinGroupRequest(id: id, password: password),
          );
      ref.read(myGroupIdProvider.notifier).state = id;
      ref.read(hasGroupProvider.notifier).state = true;
    });
  }

  Future<void> startDraft() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(lobbyRepositoryProvider).startDraft());
  }

  /// "End the game early" — wipes the group's gameplay data back to a fresh
  /// pre-draft lobby. Does NOT change group membership: hasGroupProvider
  /// stays true, the player remains in the lobby.
  Future<void> resetGroup() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(lobbyRepositoryProvider).resetGroup());
  }
}

final lobbyControllerProvider =
    AutoDisposeAsyncNotifierProvider<LobbyController, void>(LobbyController.new);
