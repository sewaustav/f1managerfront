import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel platformConnect(Uri uri, String? token) => IOWebSocketChannel.connect(
      uri,
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    );
