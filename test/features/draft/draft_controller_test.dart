import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/draft/application/draft_controller.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';

class _MockRepo extends Mock implements DraftRepository {}

void main() {
  test('draft_turn sets myTurn+round; pick_made appends history and clears turn', () async {
    final ctrl = StreamController<WsMessage>.broadcast();
    addTearDown(ctrl.close);
    final repo = _MockRepo();
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
      draftRepositoryProvider.overrideWithValue(_MockRepo()),
      wsMessagesProvider.overrideWith((ref) => ctrl.stream),
    ]);
    addTearDown(container.dispose);
    container.listen(draftControllerProvider, (_, __) {});

    ctrl.add(WsMessage.parse('{"type":"draft_finished"}'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(draftControllerProvider).finished, isTrue);
  });
}
