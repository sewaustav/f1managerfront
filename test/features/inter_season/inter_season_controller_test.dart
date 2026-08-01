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
  test('incoming transfer_request appears; respond sends transfer_response + dequeues', () async {
    final ws = StreamController<WsMessage>.broadcast();
    final fakeWs = _FakeWs();
    final c = ProviderContainer(overrides: [
      wsMessagesProvider.overrideWith((ref) => ws.stream),
      wsServiceProvider.overrideWithValue(fakeWs),
      interSeasonRepositoryProvider.overrideWithValue(_FakeRepo()),
    ]);
    addTearDown(c.dispose);
    c.listen(interSeasonControllerProvider, (_, __) {}); // start listening (keeps autoDispose alive)

    ws.add(const WsMessage('transfer_request', {'type': 'transfer_request', 'pilot_id': 7, 'price': 40}));
    await Future<void>.delayed(Duration.zero);
    final offer = c.read(interSeasonControllerProvider).incomingOffers.single;
    expect(offer.pilotId, 7);

    c.read(interSeasonControllerProvider.notifier).respondToOffer(offer, accept: true);
    expect(fakeWs.sent.single, {'type': 'transfer_response', 'pilot_id': 7, 'accept': true});
    expect(c.read(interSeasonControllerProvider).incomingOffers, isEmpty);
  });

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
