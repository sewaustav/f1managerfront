import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/core/ws/ws_service.dart';
import 'package:f1manager/features/inter_season/data/inter_season_repository.dart';
import 'package:f1manager/features/inter_season/application/inter_season_controller.dart';

class _FakeWs extends WsService {
  _FakeWs() : super(wsUrl: 'ws://x', accessToken: (() async => 't'));
  final sent = <Map<String, dynamic>>[];
  @override
  void send(Map<String, dynamic> json) => sent.add(json);
}

class _FakeRepo extends InterSeasonRepository {
  _FakeRepo() : super(Dio());
  bool readyCalled = false;
  @override
  Future<void> markReady() async => readyCalled = true;
}

void main() {

  test('season_started sets flag', () async {
    final ws = StreamController<WsMessage>.broadcast();
    final c = ProviderContainer(overrides: [
      wsMessagesProvider.overrideWith((ref) => ws.stream),
      wsServiceProvider.overrideWithValue(_FakeWs()),
      interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
    ]);
    addTearDown(c.dispose);
    c.listen(interSeasonControllerProvider, (_, __) {});
    ws.add(const WsMessage('season_started', {'type': 'season_started'}));
    await Future<void>.delayed(Duration.zero);
    expect(c.read(interSeasonControllerProvider).seasonStarted, isTrue);
  });

  test('markReady calls repo and sets ready', () async {
    final repo = _FakeRepo();
    final c = ProviderContainer(overrides: [
      wsMessagesProvider.overrideWith((ref) => const Stream.empty()),
      wsServiceProvider.overrideWithValue(_FakeWs()),
      interSeasonRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);
    await c.read(interSeasonControllerProvider.notifier).markReady();
    expect(repo.readyCalled, isTrue);
    expect(c.read(interSeasonControllerProvider).ready, isTrue);
  });
}
