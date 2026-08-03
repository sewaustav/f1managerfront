import '../../../core/ws/ws_message.dart';

/// Обмен пилотами между игроками больше не ходит через WS: предложения
/// хранятся на сервере и опрашиваются (см. TransferOffer и
/// incomingOffersProvider). Здесь остался только сигнал о старте сезона.
bool isSeasonStarted(WsMessage m) => m.type == 'season_started';
