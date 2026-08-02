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

  // The refresh action lets a player stuck on "Waiting for other players"
  // self-recover — draft_turn is otherwise a single, one-shot WS message
  // silently dropped if their socket wasn't connected at that exact instant,
  // which deadlocks the whole draft with no other way to notice it's
  // actually their turn.
  testWidgets('refresh button re-fetches draft state and unlocks picks', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getBudget()).thenAnswer((_) async => throw Exception('n/a'));
    when(() => repo.getDraftState()).thenAnswer((_) async =>
        const DraftTurnState(active: false, round: 0, isMyTurn: false, finished: false));

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
    expect(tester.widget<FilledButton>(find.byKey(const Key('pick_Max'))).onPressed, isNull);

    // the server now confirms it's actually my turn (the WS message was missed)
    when(() => repo.getDraftState()).thenAnswer((_) async =>
        const DraftTurnState(active: true, round: 0, isMyTurn: true, finished: false));
    await tester.tap(find.byKey(const Key('refresh_turn_button')));
    await tester.pump();

    expect(tester.widget<FilledButton>(find.byKey(const Key('pick_Max'))).onPressed, isNotNull);
  });
}
