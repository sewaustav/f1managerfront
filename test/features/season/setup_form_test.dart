import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/features/season/application/setup_math.dart';
import 'package:f1manager/features/season/presentation/widgets/setup_form.dart';

void main() {
  testWidgets('a fully-spent pool disables the untouched sliders (no overspend)',
      (tester) async {
    // pool = 10, all 10 allocated to aero -> remaining 0.
    const initial = SetupValues(aeroDynamic: 10);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SetupForm(pool: 10, initial: initial, onChanged: (_) {}),
      ),
    ));

    // Engine slider sits at 0 with no budget left: it must be disabled (max 0),
    // so the total can never be pushed past the pool.
    final engine = tester.widget<Slider>(find.byKey(const Key('slider_engine')));
    expect(engine.onChanged, isNull);
    expect(engine.max, 0);

    // The aero slider (value 10) can still move within its own ceiling.
    final aero = tester.widget<Slider>(find.byKey(const Key('slider_aero')));
    expect(aero.onChanged, isNotNull);
    expect(aero.max, 10);

    expect(find.byKey(const Key('tokens_remaining')), findsOneWidget);
  });
}
