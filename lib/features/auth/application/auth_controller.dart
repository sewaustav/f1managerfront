import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/ws/ws_providers.dart';
import '../../lobby/application/lobby_controller.dart';
import '../data/auth_repository.dart';
import '../model/auth_requests.dart';

class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login(String login, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final pair = await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(login: login, password: password));
      await ref.read(tokenStoreProvider).save(
            access: pair.accessToken,
            refresh: pair.refreshToken,
          );
      ref.read(isAuthenticatedProvider.notifier).state = true;
    });
  }

  Future<void> register(String email, String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final pair = await ref
          .read(authRepositoryProvider)
          .register(RegisterRequest(email: email, username: username, password: password));
      await ref.read(tokenStoreProvider).save(
            access: pair.accessToken,
            refresh: pair.refreshToken,
          );
      ref.read(isAuthenticatedProvider.notifier).state = true;
    });
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // best-effort; clear locally regardless
    }
    await ref.read(tokenStoreProvider).clear();
    ref.read(isAuthenticatedProvider.notifier).state = false;
    ref.read(hasGroupProvider.notifier).state = false;
    // Tear down the live WS so the next session starts clean.
    ref.invalidate(wsMessagesProvider);
    ref.invalidate(wsServiceProvider);
  }
}

final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>(AuthController.new);
