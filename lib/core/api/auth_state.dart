import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_store.dart';

/// Overridden in main() with SecureTokenStore.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  throw UnimplementedError('tokenStoreProvider must be overridden');
});

/// Whether an access token currently exists (drives auth routing).
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
