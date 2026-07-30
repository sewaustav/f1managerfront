import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/auth_state.dart';
import 'ws_channel_factory.dart';
import 'ws_message.dart';
import 'ws_service.dart';

final wsServiceProvider = Provider<WsService>((ref) {
  final config = ref.watch(apiConfigProvider);
  final store = ref.watch(tokenStoreProvider);
  return WsService(
    wsUrl: config.wsUrl,
    accessToken: store.readAccess,
    connect: (uri) => connectWithAuth(config.wsUrl, uri.queryParameters['token']),
  );
});

final wsMessagesProvider = StreamProvider<WsMessage>((ref) {
  final svc = ref.watch(wsServiceProvider);
  svc.start();
  ref.onDispose(svc.dispose);
  return svc.messages;
});
