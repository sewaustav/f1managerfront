import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/models/token_pair.dart';
import 'package:f1manager/core/storage/token_store.dart';
import 'package:f1manager/features/auth/application/auth_controller.dart';
import 'package:f1manager/features/auth/data/auth_repository.dart';
import 'package:f1manager/features/auth/model/auth_requests.dart';

class _MockRepo extends Mock implements AuthRepository {}

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
    registerFallbackValue(const LoginRequest(login: 'x', password: 'y'));
    registerFallbackValue(const RegisterRequest(email: 'a@b.c', username: 'u', password: 'p'));
  });

  test('login stores tokens and marks authenticated', () async {
    final repo = _MockRepo();
    final store = InMemoryTokenStore();
    when(() => repo.login(any()))
        .thenAnswer((_) async => const TokenPair(accessToken: 'A', refreshToken: 'R'));

    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      tokenStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, __) {}); // keep alive (autoDispose)

    await container.read(authControllerProvider.notifier).login('joe', 'secretpw');

    expect(await store.readAccess(), 'A');
    expect(container.read(isAuthenticatedProvider), isTrue);
    expect(container.read(authControllerProvider).hasError, isFalse);
  });

  test('login decodes own userID from the access token', () async {
    final repo = _MockRepo();
    final store = InMemoryTokenStore();
    when(() => repo.login(any())).thenAnswer(
        (_) async => TokenPair(accessToken: _fakeJwt(42), refreshToken: 'R'));

    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      tokenStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, __) {});

    await container.read(authControllerProvider.notifier).login('joe', 'secretpw');

    expect(container.read(currentUserIdProvider), 42);
  });

  test('logout clears the decoded userID', () async {
    final repo = _MockRepo();
    final store = InMemoryTokenStore();
    when(() => repo.login(any())).thenAnswer(
        (_) async => TokenPair(accessToken: _fakeJwt(42), refreshToken: 'R'));
    when(() => repo.logout()).thenAnswer((_) async {});

    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      tokenStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, __) {});

    await container.read(authControllerProvider.notifier).login('joe', 'secretpw');
    expect(container.read(currentUserIdProvider), 42);

    await container.read(authControllerProvider.notifier).logout();
    expect(container.read(currentUserIdProvider), isNull);
  });

  test('login failure surfaces AsyncError and does not authenticate', () async {
    final repo = _MockRepo();
    final store = InMemoryTokenStore();
    when(() => repo.login(any())).thenThrow(Exception('bad creds'));

    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      tokenStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    container.listen(authControllerProvider, (_, __) {}); // keep alive (autoDispose)

    await container.read(authControllerProvider.notifier).login('joe', 'nope');

    expect(container.read(authControllerProvider).hasError, isTrue);
    expect(container.read(isAuthenticatedProvider), isFalse);
    expect(await store.readAccess(), isNull);
  });
}
