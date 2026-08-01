import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/auth_state.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_store.dart';
import 'features/season/data/setup_preset_store.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStore = SecureTokenStore();
  final hasToken = (await tokenStore.readAccess()) != null;
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(tokenStore),
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
  );

  // Seed auth state synchronously, before the first build/redirect.
  if (hasToken) {
    container.read(isAuthenticatedProvider.notifier).state = true;
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const _Bootstrap(),
    ),
  );
}

class _Bootstrap extends ConsumerWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
