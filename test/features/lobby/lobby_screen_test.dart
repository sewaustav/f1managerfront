import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/lobby/data/lobby_repository.dart';
import 'package:f1manager/features/lobby/model/group_requests.dart';
import 'package:f1manager/features/lobby/presentation/lobby_screen.dart';

class _MockRepo extends Mock implements LobbyRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const CreateGroupRequest(name: 'x', password: 'y')));

  testWidgets('no-group state: create calls repo.createGroup', (tester) async {
    final repo = _MockRepo();
    when(() => repo.createGroup(any())).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        lobbyRepositoryProvider.overrideWithValue(repo),
        hasGroupProvider.overrideWith((ref) => false),
      ],
      child: const MaterialApp(home: LobbyScreen()),
    ));

    await tester.enterText(find.byKey(const Key('group_name_field')), 'Reds');
    await tester.enterText(find.byKey(const Key('create_password_field')), 'pw');
    await tester.tap(find.byKey(const Key('create_group_button')));
    await tester.pumpAndSettle();

    verify(() => repo.createGroup(const CreateGroupRequest(name: 'Reds', password: 'pw'))).called(1);
  });

  testWidgets('group state: shows Group ID with a copy button', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getPlayers()).thenAnswer((_) async => const []);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        lobbyRepositoryProvider.overrideWithValue(repo),
        hasGroupProvider.overrideWith((ref) => true),
        myGroupIdProvider.overrideWith((ref) => 42),
      ],
      child: const MaterialApp(home: LobbyScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('group_id_display')), findsOneWidget);
    expect(find.textContaining('42'), findsOneWidget);
    expect(find.byKey(const Key('copy_group_id_button')), findsOneWidget);
  });
}
