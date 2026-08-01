import 'package:web_socket_channel/web_socket_channel.dart';

// Browsers cannot set custom headers on a WebSocket handshake; auth rides on the
// ?token= query param (backend PR in Plan 7). token arg is unused on web.
WebSocketChannel platformConnect(Uri uri, String? token) => WebSocketChannel.connect(uri);
