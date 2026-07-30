import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_message.dart';

void main() {
  test('parses type and payload', () {
    final m = WsMessage.parse('{"type":"draft_turn","round":3}');
    expect(m.type, 'draft_turn');
    expect(m.data['round'], 3);
  });

  test('missing type → empty string, no throw', () {
    final m = WsMessage.parse('{"round":1}');
    expect(m.type, '');
  });
}
