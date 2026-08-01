import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'ws_message.dart';

Duration backoffDelay(int attempt) {
  final secs = 1 << attempt; // 1,2,4,8,16,32...
  return Duration(seconds: secs > 30 ? 30 : secs);
}

typedef ChannelFactory = WebSocketChannel Function(Uri uri);

class WsService {
  WsService({
    required this.wsUrl,
    required this.accessToken,
    ChannelFactory? connect,
    this.onReconnect,
  }) : _connect = connect ?? WebSocketChannel.connect;

  final String wsUrl;
  final Future<String?> Function() accessToken;
  final ChannelFactory _connect;

  /// Called after every successful (re)connect — used to re-fetch season state.
  final Future<void> Function()? onReconnect;

  final _controller = StreamController<WsMessage>.broadcast();
  Stream<WsMessage> get messages => _controller.stream;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  int _attempt = 0;
  bool _disposed = false;
  Timer? _retryTimer;

  @visibleForTesting
  int get attempt => _attempt;

  Future<void> start() async {
    if (_disposed) return;
    final token = await accessToken();
    final uri = Uri.parse('$wsUrl?token=${token ?? ''}');
    try {
      final channel = _connect(uri);
      _channel = channel;
      // WebSocketChannel.connect() returns synchronously and connects in the
      // background — a real failure (server down/unreachable) surfaces
      // asynchronously via `ready`, not as a synchronous throw. Gate
      // "connection succeeded" on `ready` so backoff only resets and
      // onReconnect only fires once the socket is actually usable.
      await channel.ready;
      if (_disposed) return;
      _attempt = 0;
      await onReconnect?.call();
      _sub = channel.stream.listen(
        (event) => _controller.add(WsMessage.parse(event.toString())),
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void send(Map<String, dynamic> json) => _channel?.sink.add(jsonEncode(json));

  void _scheduleReconnect() {
    if (_disposed) return;
    _sub?.cancel();
    final delay = backoffDelay(_attempt);
    // Cap the counter once the delay has saturated at backoffDelay's 30s
    // ceiling (reached at attempt == 5, since 1 << 5 == 32 > 30) so it can
    // never grow large enough for `1 << _attempt` to overflow a 64-bit int
    // and wrap negative.
    if (_attempt < 5) _attempt++;
    _retryTimer = Timer(delay, start);
  }

  Future<void> dispose() async {
    _disposed = true;
    _retryTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close();
    await _controller.close();
  }
}
