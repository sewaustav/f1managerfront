import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/models/team.dart';
import 'package:f1manager/features/inter_season/presentation/widgets/base_investment_form.dart';

void main() {
  testWidgets('prefills from team and submits current values', (tester) async {
    Map<String, int>? submitted;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BaseInvestmentForm(
          initial: const Team(id: 1, name: 'RB', baseLevel: 6, engineer: 3, tubeLevel: 2, simLevel: 4),
          onSubmit: ({required base, required engineer, required tube, required sim}) =>
              submitted = {'base': base, 'engineer': engineer, 'tube': tube, 'sim': sim},
        ),
      ),
    ));
    // sliders render with prefilled values
    expect(find.byType(Slider), findsNWidgets(4));
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(submitted, {'base': 6, 'engineer': 3, 'tube': 2, 'sim': 4});
  });
}
