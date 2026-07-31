import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/draft/model/budget.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/track_info.dart';
import 'package:f1manager/features/season/presentation/race_screen.dart';
import 'package:f1manager/features/season/presentation/token_setup_screen.dart';

class _MockRepo extends Mock implements SeasonRepository {}

void main() {
  testWidgets('renders track and a confirm-setup button', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getTracks()).thenAnswer((_) async =>
        [const TrackInfo(id: 1, name: 'Monaco', difficulty: 80, rainPossibility: 40, tyre: 2, type: 1)]);
    when(() => repo.getBudget()).thenAnswer((_) async => const Budget(budget: 100, tokens: 35));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        seasonRepositoryProvider.overrideWithValue(repo),
        wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
        tokenPoolProvider.overrideWith((ref) async => 35),
      ],
      child: const MaterialApp(home: RaceScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Monaco'), findsOneWidget);
    expect(find.byKey(const Key('confirm_setup')), findsOneWidget);
  });
}
