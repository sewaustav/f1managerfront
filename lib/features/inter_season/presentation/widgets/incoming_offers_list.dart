import 'package:flutter/material.dart';
import '../../model/transfer_offer.dart';

/// Список входящих предложений выкупить моего пилота.
///
/// Показывается прямо на вкладке трансферов, а не всплывающим окном: раньше
/// предложение существовало только в момент запроса покупателя, и если
/// владелец в эту секунду не смотрел в экран — обмен срывался.
class IncomingOffersList extends StatelessWidget {
  const IncomingOffersList({
    super.key,
    required this.offers,
    required this.onRespond,
    this.busyOfferId,
  });

  final List<TransferOffer> offers;
  final void Function(TransferOffer offer, bool accept) onRespond;

  /// Предложение, по которому уже идёт запрос — его кнопки блокируются,
  /// чтобы двойной тап не отправил ответ дважды.
  final int? busyOfferId;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final o in offers)
          Card(
            key: Key('offer_${o.id}'),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.pilotName,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${o.buyerName} предлагает ${o.price}М',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        key: Key('decline_offer_${o.id}'),
                        onPressed: busyOfferId == o.id
                            ? null
                            : () => onRespond(o, false),
                        child: const Text('Отклонить'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        key: Key('accept_offer_${o.id}'),
                        onPressed: busyOfferId == o.id
                            ? null
                            : () => onRespond(o, true),
                        child: const Text('Принять'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
