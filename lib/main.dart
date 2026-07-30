import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api/auth_state.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_store.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStore = SecureTokenStore();
  final hasToken = (await tokenStore.readAccess()) != null;

  runApp(
    ProviderScope(
      overrides: [tokenStoreProvider.overrideWithValue(tokenStore)],
      child: _Bootstrap(initiallyAuthed: hasToken),
    ),
  );
}

class _Bootstrap extends ConsumerWidget {
  const _Bootstrap({required this.initiallyAuthed});
  final bool initiallyAuthed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seed auth state once from stored token.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initiallyAuthed) {
        ref.read(isAuthenticatedProvider.notifier).state = true;
      }
    });
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'F1 Manager',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
