import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/lobby/data/lobby_repository.dart';
import 'package:f1manager/features/lobby/model/group_requests.dart';
import 'package:f1manager/features/lobby/model/player.dart';
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

  // Завершение игры переехало на экран команды: в лобби оно лишнее.
  // Выйти из группы должен уметь любой участник, включая организатора —
  // группа переживает его уход, и он может вернуться по тому же ID.
  testWidgets('в лобби есть выход и нет завершения игры', (tester) async {
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

    expect(find.byKey(const Key('leave_group_button')), findsOneWidget);
    expect(find.byKey(const Key('end_game_early_button')), findsNothing);
  });

  testWidgets('организатор тоже может выйти', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getPlayers()).thenAnswer((_) async => const []);
    when(() => repo.leaveGroup()).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        lobbyRepositoryProvider.overrideWithValue(repo),
        hasGroupProvider.overrideWith((ref) => true),
        // id группы == id организатора
        myGroupIdProvider.overrideWith((ref) => 42),
        currentUserIdProvider.overrideWith((ref) => 42),
      ],
      child: const MaterialApp(home: LobbyScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('leave_group_button')));
    await tester.pumpAndSettle();
    // ничего необратимого без подтверждения
    verifyNever(() => repo.leaveGroup());
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();

    verify(() => repo.leaveGroup()).called(1);
  });

  testWidgets('отмена не выводит из группы', (tester) async {
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

    await tester.tap(find.byKey(const Key('leave_group_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    verifyNever(() => repo.leaveGroup());
  });

  testWidgets('организатор может удалить участника', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getPlayers()).thenAnswer(
        (_) async => const [Player(id: 42, name: 'Хозяин'), Player(id: 7, name: 'Гость')]);
    when(() => repo.kickPlayer(any())).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        lobbyRepositoryProvider.overrideWithValue(repo),
        hasGroupProvider.overrideWith((ref) => true),
        myGroupIdProvider.overrideWith((ref) => 42),
        currentUserIdProvider.overrideWith((ref) => 42),
      ],
      child: const MaterialApp(home: LobbyScreen()),
    ));
    await tester.pumpAndSettle();

    // у самого организатора кнопки удаления нет
    expect(find.byKey(const Key('kick_42')), findsNothing);

    await tester.tap(find.byKey(const Key('kick_7')));
    await tester.pumpAndSettle();
    verifyNever(() => repo.kickPlayer(any()));

    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    verify(() => repo.kickPlayer(7)).called(1);
  });

  testWidgets('обычный участник не видит кнопок удаления', (tester) async {
    final repo = _MockRepo();
    when(() => repo.getPlayers()).thenAnswer(
        (_) async => const [Player(id: 42, name: 'Хозяин'), Player(id: 7, name: 'Гость')]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        lobbyRepositoryProvider.overrideWithValue(repo),
        hasGroupProvider.overrideWith((ref) => true),
        myGroupIdProvider.overrideWith((ref) => 42),
        currentUserIdProvider.overrideWith((ref) => 7),
      ],
      child: const MaterialApp(home: LobbyScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('kick_7')), findsNothing);
    expect(find.byKey(const Key('kick_42')), findsNothing);
  });
}
