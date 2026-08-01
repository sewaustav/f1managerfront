import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/storage/token_store.dart';
import 'package:f1manager/features/auth/application/auth_controller.dart';
import 'package:f1manager/features/auth/data/auth_repository.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';

class _FakeTokenStore implements TokenStore {
  String? access = 'a';
  String? refresh = 'r';
  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }
  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _FakeAuthRepo extends AuthRepository {
  // A real (but unused) Dio: logout() is overridden below so the
  // underlying client is never touched. `throw UnimplementedError()`
  // can't be used here since super-constructor arguments are evaluated
  // eagerly and would throw before construction completes.
  _FakeAuthRepo() : super(Dio());
  @override
  Future<void> logout() async {}
}

void main() {
  test('logout resets hasGroup + auth flags', () async {
    final c = ProviderContainer(overrides: [
      tokenStoreProvider.overrideWithValue(_FakeTokenStore()),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
    ]);
    addTearDown(c.dispose);
    c.read(isAuthenticatedProvider.notifier).state = true;
    c.read(hasGroupProvider.notifier).state = true;

    await c.read(authControllerProvider.notifier).logout();

    expect(c.read(isAuthenticatedProvider), isFalse);
    expect(c.read(hasGroupProvider), isFalse);
  });
}
