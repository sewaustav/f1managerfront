import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/features/inter_season/model/transfer_events.dart';
import 'package:f1manager/features/inter_season/presentation/widgets/transfer_list.dart';
import 'package:f1manager/features/inter_season/presentation/widgets/incoming_offer_dialog.dart';

void main() {
  testWidgets('TransferList Buy calls onBuy with default price', (tester) async {
    Pilot? bought;
    int? price;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TransferList(
          pilots: const [Pilot(id: 5, name: 'Checo', price: 33)],
          onBuy: (p, pr) {
            bought = p;
            price = pr;
          },
        ),
      ),
    ));
    await tester.tap(find.text('Buy'));
    await tester.pump();
    expect(bought!.id, 5);
    expect(price, 33);
  });

  testWidgets('TransferList Buy with unparseable price falls back to pilot.price',
      (tester) async {
    Pilot? bought;
    int? price;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TransferList(
          pilots: const [Pilot(id: 5, name: 'Checo', price: 33)],
          onBuy: (p, pr) {
            bought = p;
            price = pr;
          },
        ),
      ),
    ));
    await tester.enterText(find.byType(TextField), 'not a number');
    await tester.tap(find.text('Buy'));
    await tester.pump();
    expect(bought!.id, 5);
    expect(price, 33);
  });

  testWidgets('TransferList Buy with custom valid price passes entered value',
      (tester) async {
    Pilot? bought;
    int? price;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TransferList(
          pilots: const [Pilot(id: 5, name: 'Checo', price: 33)],
          onBuy: (p, pr) {
            bought = p;
            price = pr;
          },
        ),
      ),
    ));
    await tester.enterText(find.byType(TextField), '99');
    await tester.tap(find.text('Buy'));
    await tester.pump();
    expect(bought!.id, 5);
    expect(price, 99);
  });

  testWidgets('showIncomingOfferDialog returns true on Accept', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async =>
                result = await showIncomingOfferDialog(ctx, const TransferRequest(7, 40)),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('showIncomingOfferDialog returns false on Decline', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async =>
                result = await showIncomingOfferDialog(ctx, const TransferRequest(7, 40)),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
