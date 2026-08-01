import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/features/inter_season/presentation/widgets/my_pilots_list.dart';

void main() {
  testWidgets('renders pilot names and Fire buttons; tapping Fire invokes onFire',
      (tester) async {
    Pilot? fired;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MyPilotsList(
          pilots: const [
            Pilot(id: 10, name: 'Max'),
            Pilot(id: 11, name: 'Lando'),
          ],
          onFire: (p) => fired = p,
        ),
      ),
    ));

    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Lando'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Fire'), findsNWidgets(2));

    await tester.tap(find
        .descendant(of: find.byKey(const ValueKey(11)), matching: find.text('Fire')));
    await tester.pump();

    expect(fired?.id, 11);
  });
}
