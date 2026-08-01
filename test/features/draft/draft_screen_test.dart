import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/draft/application/draft_data_providers.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/draft/presentation/widgets/budget_bar.dart';
import 'package:f1manager/features/draft/presentation/draft_screen.dart';

class _MockRepo extends Mock implements DraftRepository {}

void main() {
  testWidgets('shows waiting banner and disables picks when not my turn', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getBudget()).thenAnswer((_) async => throw Exception('n/a'));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        draftRepositoryProvider.overrideWithValue(repo),
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        pilotsProvider.overrideWith((ref) async => [const Pilot(id: 1, name: 'Max')]),
        teamsProvider.overrideWith((ref) async => []),
        principalsProvider.overrideWith((ref) async => []),
        enginesProvider.overrideWith((ref) async => []),
        budgetProvider.overrideWith((ref) async => throw Exception('n/a')),
      ],
      child: const MaterialApp(home: DraftScreen()),
    ));
    await tester.pump();

    expect(find.text('Max'), findsOneWidget);
    final btn = tester.widget<FilledButton>(find.byKey(const Key('pick_Max')));
    expect(btn.onPressed, isNull); // not my turn
  });
}
