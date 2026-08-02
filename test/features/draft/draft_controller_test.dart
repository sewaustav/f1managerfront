import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/draft/application/draft_controller.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';

class _MockRepo extends Mock implements DraftRepository {}

const _inactive = DraftTurnState(active: false, round: 0, isMyTurn: false, finished: false);

/// A repo with GET /draft/state stubbed to "no active draft" — the neutral
/// default for tests that only care about WS-driven behavior, since build()
/// now fires an unawaited recovery fetch on every controller creation.
_MockRepo _repoWithInactiveState() {
  final repo = _MockRepo();
  when(() => repo.getDraftState()).thenAnswer((_) async => _inactive);
  return repo;
}

void main() {
  test('draft_turn sets myTurn+round; pick_made appends history and clears turn', () async {
    final ctrl = StreamController<WsMessage>.broadcast();
    addTearDown(ctrl.close);
    final repo = _repoWithInactiveState();
    final container = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => ctrl.stream),
    ]);
    addTearDown(container.dispose);
    container.listen(draftControllerProvider, (_, __) {});

    ctrl.add(WsMessage.parse('{"type":"draft_turn","round":1}'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(draftControllerProvider).isMyTurn, isTrue);
    expect(container.read(draftControllerProvider).round, 1);

    ctrl.add(WsMessage.parse('{"type":"draft_pick_made","user_id":9,"pick":0,"item_id":3}'));
    await Future<void>.delayed(Duration.zero);
    final st = container.read(draftControllerProvider);
    expect(st.isMyTurn, isFalse);
    expect(st.history.length, 1);
    expect(st.history.single.itemId, 3);
  });

  test('draft_finished sets finished', () async {
    final ctrl = StreamController<WsMessage>.broadcast();
    addTearDown(ctrl.close);
    final container = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(_repoWithInactiveState()),
      wsMessagesProvider.overrideWith((ref) => ctrl.stream),
    ]);
    addTearDown(container.dispose);
    container.listen(draftControllerProvider, (_, __) {});

    ctrl.add(WsMessage.parse('{"type":"draft_finished"}'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(draftControllerProvider).finished, isTrue);
  });

  // --- GET /draft/state recovery: draft_turn is otherwise a single, one-shot
  // WS message silently dropped if the recipient's socket wasn't connected
  // at that exact instant, which deadlocks the whole draft forever.

  test('build() recovers isMyTurn+round from GET /draft/state on load', () async {
    final repo = _MockRepo();
    when(() => repo.getDraftState()).thenAnswer((_) async =>
        const DraftTurnState(active: true, round: 2, isMyTurn: true, finished: false));
    final container = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(container.dispose);
    container.listen(draftControllerProvider, (_, __) {});

    await Future<void>.delayed(Duration.zero);
    final st = container.read(draftControllerProvider);
    expect(st.isMyTurn, isTrue);
    expect(st.round, 2);
  });

  test('build() recovers finished from GET /draft/state on load', () async {
    final repo = _MockRepo();
    when(() => repo.getDraftState()).thenAnswer((_) async =>
        const DraftTurnState(active: false, round: 0, isMyTurn: false, finished: true));
    final container = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(container.dispose);
    container.listen(draftControllerProvider, (_, __) {});

    await Future<void>.delayed(Duration.zero);
    expect(container.read(draftControllerProvider).finished, isTrue);
  });

  test('a failed recovery fetch leaves the default state (no crash)', () async {
    final repo = _MockRepo();
    when(() => repo.getDraftState()).thenThrow(Exception('network error'));
    final container = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(container.dispose);
    container.listen(draftControllerProvider, (_, __) {});

    await Future<void>.delayed(Duration.zero);
    expect(container.read(draftControllerProvider).isMyTurn, isFalse);
  });

  test('refreshTurnState() lets a stuck player self-recover on demand', () async {
    final repo = _MockRepo();
    when(() => repo.getDraftState()).thenAnswer((_) async => _inactive);
    final container = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(container.dispose);
    container.listen(draftControllerProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);
    expect(container.read(draftControllerProvider).isMyTurn, isFalse);

    // the WS message was missed earlier; the server now confirms it's my turn
    when(() => repo.getDraftState()).thenAnswer((_) async =>
        const DraftTurnState(active: true, round: 0, isMyTurn: true, finished: false));
    await container.read(draftControllerProvider.notifier).refreshTurnState();

    expect(container.read(draftControllerProvider).isMyTurn, isTrue);
  });
}
