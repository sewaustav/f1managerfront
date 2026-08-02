import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/features/draft/model/draft_events.dart';

void main() {
  test('parses draft_turn', () {
    final e = draftEventFromMessage(WsMessage.parse('{"type":"draft_turn","round":2,"user_id":5}'));
    expect(e, isA<DraftTurn>());
    expect((e as DraftTurn).round, 2);
    expect(e.userId, 5);
  });

  test('parses draft_pick_made', () {
    final e = draftEventFromMessage(
        WsMessage.parse('{"type":"draft_pick_made","user_id":7,"pick":1,"item_id":9}'));
    expect(e, isA<DraftPickMade>());
    final p = e as DraftPickMade;
    expect(p.userId, 7);
    expect(p.pick, 1);
    expect(p.itemId, 9);
  });

  test('parses draft_retry and draft_finished', () {
    expect(draftEventFromMessage(WsMessage.parse('{"type":"draft_retry","round":1,"error":"no budget"}')),
        isA<DraftRetry>());
    expect(draftEventFromMessage(WsMessage.parse('{"type":"draft_finished"}')), isA<DraftFinished>());
  });

  test('non-draft message returns null', () {
    expect(draftEventFromMessage(WsMessage.parse('{"type":"race_finished","stage":1}')), isNull);
  });
}
