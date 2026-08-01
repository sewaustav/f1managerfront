import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/api/auth_state.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/lobby/application/lobby_controller.dart';
import 'package:f1manager/features/season/data/season_state_repository.dart';
import 'package:f1manager/features/season/application/season_state_provider.dart';

class _FakeRepo extends SeasonStateRepository {
  _FakeRepo() : super(Dio());
  SeasonState value = const SeasonState(phase: SeasonPhase.draft);
  int calls = 0;
  @override
  Future<SeasonState> getSeasonState() async {
    calls++;
    return value;
  }
}

/// Every test that lets the controller reach the repo-fetch branch needs
/// wsMessagesProvider overridden — build() now listens to it, and the real
/// provider would spin up a WsService and attempt a live socket connection.
List<Override> _sessionOverrides(SeasonStateRepository repo) => [
      seasonStateRepositoryProvider.overrideWithValue(repo),
      isAuthenticatedProvider.overrideWith((ref) => true),
      hasGroupProvider.overrideWith((ref) => true),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ];

void main() {
  test('provider fetches then refresh re-fetches', () async {
    final repo = _FakeRepo();
    final c = ProviderContainer(overrides: _sessionOverrides(repo));
    addTearDown(c.dispose);
    expect((await c.read(seasonStateProvider.future)).phase, SeasonPhase.draft);
    repo.value = const SeasonState(phase: SeasonPhase.racing, stage: 2);
    await c.read(seasonStateProvider.notifier).refresh();
    expect(c.read(seasonStateProvider).value!.phase, SeasonPhase.racing);
  });

  test('not authed+group: build() yields unknown and never calls the repo', () async {
    final repo = _FakeRepo();
    final c = ProviderContainer(overrides: [
      seasonStateRepositoryProvider.overrideWithValue(repo),
      // isAuthenticatedProvider/hasGroupProvider left at their defaults (false).
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(c.dispose);

    final result = await c.read(seasonStateProvider.future);

    expect(result.phase, SeasonPhase.unknown);
    expect(repo.calls, 0);
  });

  test('a phase-relevant WS message triggers a re-fetch', () async {
    final repo = _FakeRepo();
    final wsController = StreamController<WsMessage>();
    addTearDown(wsController.close);

    final c = ProviderContainer(overrides: [
      seasonStateRepositoryProvider.overrideWithValue(repo),
      isAuthenticatedProvider.overrideWith((ref) => true),
      hasGroupProvider.overrideWith((ref) => true),
      wsMessagesProvider.overrideWith((ref) => wsController.stream),
    ]);
    addTearDown(c.dispose);

    // Keep the (autoDispose) controller alive across the async hops below.
    c.listen(seasonStateProvider, (_, __) {});

    expect((await c.read(seasonStateProvider.future)).phase, SeasonPhase.draft);
    expect(repo.calls, 1);

    repo.value = const SeasonState(phase: SeasonPhase.racing, stage: 3);
    wsController.add(const WsMessage('draft_turn', {'type': 'draft_turn'}));

    // Let the WS listener's refresh() (AsyncValue.guard's async gap) settle.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repo.calls, 2);
    expect(c.read(seasonStateProvider).value!.phase, SeasonPhase.racing);
  });
}
