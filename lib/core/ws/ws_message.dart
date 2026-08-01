import 'dart:convert';

class WsMessage {
  const WsMessage(this.type, this.data);
  final String type;
  final Map<String, dynamic> data;

  factory WsMessage.parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final t = decoded['type'];
      return WsMessage(t is String ? t : '', decoded);
    }
    return const WsMessage('', <String, dynamic>{});
  }
}
