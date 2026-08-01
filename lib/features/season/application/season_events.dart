import '../../../core/ws/ws_message.dart';

class RaceFinished {
  const RaceFinished(this.status, this.stage);
  final String status;
  final int stage;
}

int _int(Object? v) => v is int ? v : (v is num ? v.toInt() : 0);

RaceFinished? raceFinishedFromMessage(WsMessage m) {
  if (m.type != 'race_finished') return null;
  return RaceFinished((m.data['status'] ?? '').toString(), _int(m.data['stage']));
}
