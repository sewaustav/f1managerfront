import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:f1manager/core/ws/ws_service.dart';

class _FakeChannel extends Mock implements WebSocketChannel {}

class _FakeSink extends Mock implements WebSocketSink {}

void main() {
  late _FakeChannel channel;
  late _FakeSink sink;

  setUp(() {
    channel = _FakeChannel();
    sink = _FakeSink();
    when(() => channel.sink).thenReturn(sink);
    when(() => sink.close()).thenAnswer((_) async {});
  });

  test(
    'failed connect escalates backoff and does not fire onReconnect',
    () async {
      when(
        () => channel.ready,
      ).thenAnswer((_) async => throw Exception('down'));
      when(() => channel.stream).thenAnswer((_) => const Stream.empty());

      var reconnectCalls = 0;
      final service = WsService(
        wsUrl: 'ws://example.com/ws',
        accessToken: () async => 'tok',
        connect: (_) => channel,
        onReconnect: () async {
          reconnectCalls++;
        },
      );

      await service.start();

      // The failed `ready` must advance _attempt so the NEXT scheduled
      // delay escalates (backoffDelay(1) = 2s), not stay pinned at
      // backoffDelay(0) = 1s.
      expect(service.attempt, 1);
      expect(backoffDelay(service.attempt), const Duration(seconds: 2));
      expect(reconnectCalls, 0);

      await service.dispose();
    },
  );

  test('successful connect resets attempt and fires onReconnect once', () async {
    final streamController = StreamController<dynamic>.broadcast();
    addTearDown(streamController.close);

    when(() => channel.ready).thenAnswer((_) async {});
    when(() => channel.stream).thenAnswer((_) => streamController.stream);

    var reconnectCalls = 0;
    final service = WsService(
      wsUrl: 'ws://example.com/ws',
      accessToken: () async => 'tok',
      connect: (_) => channel,
      onReconnect: () async {
        reconnectCalls++;
      },
    );

    await service.start();

    expect(service.attempt, 0);
    expect(reconnectCalls, 1);

    await service.dispose();
  });
}
