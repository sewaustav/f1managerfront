import '../../../core/ws/ws_message.dart';

class TransferRequest {
  const TransferRequest(this.pilotId, this.price);
  final int pilotId;
  final int price;
}

int _int(Object? v) => v is int ? v : (v is num ? v.toInt() : 0);

TransferRequest? transferRequestFromMessage(WsMessage m) {
  if (m.type != 'transfer_request') return null;
  return TransferRequest(_int(m.data['pilot_id']), _int(m.data['price']));
}

bool isSeasonStarted(WsMessage m) => m.type == 'season_started';

Map<String, dynamic> transferResponsePayload({required int pilotId, required bool accept}) =>
    {'type': 'transfer_response', 'pilot_id': pilotId, 'accept': accept};
