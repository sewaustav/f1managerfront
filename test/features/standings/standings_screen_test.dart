import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f1manager/features/standings/application/standings_providers.dart';
import 'package:f1manager/features/standings/presentation/standings_screen.dart';

void main() {
  testWidgets('renders WDC list from provider', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        driverStandingsProvider.overrideWith((ref) async =>
            const [StandingRow('Lando', 25), StandingRow('Max', 10)]),
        teamStandingsProvider.overrideWith((ref) async => const [StandingRow('RB', 40)]),
      ],
      child: const MaterialApp(home: StandingsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Личный зачёт'), findsOneWidget);
    expect(find.text('Кубок конструкторов'), findsOneWidget);
    expect(find.textContaining('Lando'), findsOneWidget);
    expect(find.textContaining('25'), findsOneWidget);
  });
}
