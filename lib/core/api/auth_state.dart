import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_store.dart';
import 'api_config.dart';
import 'dio_client.dart';

/// Overridden in main() with SecureTokenStore.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  throw UnimplementedError('tokenStoreProvider must be overridden');
});

/// Whether an access token currently exists (drives auth routing).
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig.fromEnv());

final dioProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return buildDio(
    config: ref.watch(apiConfigProvider),
    tokenStore: store,
    onAuthFailure: () async =>
        ref.read(isAuthenticatedProvider.notifier).state = false,
  );
});
