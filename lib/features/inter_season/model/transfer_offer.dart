/// Предложение выкупить моего пилота, лежащее на сервере до ответа.
///
/// Раньше обмен между игроками жил только в WS-переписке внутри одного
/// HTTP-запроса, поэтому был невозможен, если у владельца не было живого
/// сокета. Теперь предложение хранится и просто опрашивается.
class TransferOffer {
  const TransferOffer({
    required this.id,
    required this.pilotId,
    required this.pilotName,
    required this.buyerId,
    required this.buyerName,
    required this.price,
  });

  final int id;
  final int pilotId;
  final String pilotName;
  final int buyerId;
  final String buyerName;
  final int price;

  factory TransferOffer.fromJson(Map<String, dynamic> json) => TransferOffer(
        id: (json['id'] as num?)?.toInt() ?? 0,
        pilotId: (json['pilot_id'] as num?)?.toInt() ?? 0,
        pilotName: (json['pilot_name'] as String?) ?? '',
        buyerId: (json['buyer_id'] as num?)?.toInt() ?? 0,
        buyerName: (json['buyer_name'] as String?) ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
      );
}
