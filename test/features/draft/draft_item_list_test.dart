import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/features/draft/presentation/widgets/draft_item_list.dart';

void main() {
  testWidgets('filters by search and picks when enabled', (tester) async {
    final picked = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DraftItemList<String>(
          items: const ['Max Verstappen', 'Lewis Hamilton'],
          title: (s) => s,
          subtitle: (s) => '',
          searchText: (s) => s,
          enabled: true,
          onPick: picked.add,
        ),
      ),
    ));

    expect(find.text('Max Verstappen'), findsOneWidget);
    expect(find.text('Lewis Hamilton'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Lewis');
    await tester.pump();
    expect(find.text('Max Verstappen'), findsNothing);
    expect(find.text('Lewis Hamilton'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pick_Lewis Hamilton')));
    expect(picked, ['Lewis Hamilton']);
  });

  testWidgets('pick buttons disabled when not enabled', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DraftItemList<String>(
          items: const ['A'],
          title: (s) => s, subtitle: (s) => '', searchText: (s) => s,
          enabled: false, onPick: (_) {},
        ),
      ),
    ));
    final btn = tester.widget<FilledButton>(find.byKey(const Key('pick_A')));
    expect(btn.onPressed, isNull);
  });
}
