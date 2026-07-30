import '../../../core/ws/ws_message.dart';

sealed class DraftEvent {
  const DraftEvent();
}

class DraftTurn extends DraftEvent {
  const DraftTurn(this.round);
  final int round;
}

class DraftRetry extends DraftEvent {
  const DraftRetry(this.round, this.error);
  final int round;
  final String error;
}

class DraftPickMade extends DraftEvent {
  const DraftPickMade(this.userId, this.pick, this.itemId);
  final int userId;
  final int pick;
  final int itemId;
}

class DraftFinished extends DraftEvent {
  const DraftFinished();
}

int _int(Object? v) => v is int ? v : (v is num ? v.toInt() : 0);

DraftEvent? draftEventFromMessage(WsMessage m) {
  switch (m.type) {
    case 'draft_turn':
      return DraftTurn(_int(m.data['round']));
    case 'draft_retry':
      return DraftRetry(_int(m.data['round']), (m.data['error'] ?? '').toString());
    case 'draft_pick_made':
      return DraftPickMade(_int(m.data['user_id']), _int(m.data['pick']), _int(m.data['item_id']));
    case 'draft_finished':
      return const DraftFinished();
    default:
      return null;
  }
}
