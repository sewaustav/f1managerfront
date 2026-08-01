import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/lobby/data/lobby_repository.dart';
import 'package:f1manager/features/lobby/presentation/lobby_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements LobbyRepository {}

void main() {
  testWidgets('group lobby watches wsMessagesProvider (starts socket)', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getPlayers()).thenAnswer((_) async => []);
    var wsWatched = false;

    await tester.pumpWidget(ProviderScope(
      overrides: [
        lobbyRepositoryProvider.overrideWithValue(repo),
        hasGroupProvider.overrideWith((ref) => true),
        wsMessagesProvider.overrideWith((ref) {
          wsWatched = true;
          return const Stream<WsMessage>.empty();
        }),
      ],
      child: const MaterialApp(home: LobbyScreen()),
    ));
    await tester.pump();

    expect(wsWatched, isTrue);
  });
}
