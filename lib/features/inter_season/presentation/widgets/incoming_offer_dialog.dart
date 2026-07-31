import 'package:flutter/material.dart';
import '../../model/transfer_events.dart';

Future<bool?> showIncomingOfferDialog(BuildContext context, TransferRequest offer) =>
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer offer'),
        content: Text('A player offers ${offer.price} for your pilot #${offer.pilotId}.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Decline')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Accept')),
        ],
      ),
    );
