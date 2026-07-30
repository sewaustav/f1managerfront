import 'package:web_socket_channel/web_socket_channel.dart';
import 'ws_channel_factory_io.dart'
    if (dart.library.html) 'ws_channel_factory_web.dart';

/// Builds the authenticated WS URI (token as query param, for browsers that
/// cannot set headers; IO also sends the Authorization header separately).
Uri authWsUri(String wsUrl, String? token) {
  final base = Uri.parse(wsUrl);
  return base.replace(queryParameters: {
    ...base.queryParameters,
    'token': token ?? '',
  });
}

/// Platform-specific connect (defined in the io/web part files).
WebSocketChannel connectWithAuth(String wsUrl, String? token) =>
    platformConnect(authWsUri(wsUrl, token), token);
