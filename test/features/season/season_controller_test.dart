import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/season/application/season_controller.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/race_result.dart';

class _MockRepo extends Mock implements SeasonRepository {}

void main() {
  test('race_finished success fetches result and clears waiting', () async {
    final ctrl = StreamController<WsMessage>.broadcast();
    addTearDown(ctrl.close);
    final repo = _MockRepo();
    when(() => repo.getRaceResult()).thenAnswer((_) async =>
        const RaceResultResponse(stage: 4, results: [RaceResult(pilotName: 'Max', racePosition: 1)]));

    final container = ProviderContainer(overrides: [
      seasonRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => ctrl.stream),
    ]);
    addTearDown(container.dispose);
    container.listen(seasonControllerProvider, (_, __) {});

    ctrl.add(WsMessage.parse('{"type":"race_finished","status":"race_finished","stage":4}'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final st = container.read(seasonControllerProvider);
    expect(st.waiting, isFalse);
    expect(st.result?.stage, 4);
    expect(st.result?.results.single.pilotName, 'Max');
  });

  test('race_finished error sets error message', () async {
    final ctrl = StreamController<WsMessage>.broadcast();
    addTearDown(ctrl.close);
    final container = ProviderContainer(overrides: [
      seasonRepositoryProvider.overrideWithValue(_MockRepo()),
      wsMessagesProvider.overrideWith((ref) => ctrl.stream),
    ]);
    addTearDown(container.dispose);
    container.listen(seasonControllerProvider, (_, __) {});

    ctrl.add(WsMessage.parse('{"type":"race_finished","status":"error","stage":4}'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(seasonControllerProvider).error, isNotNull);
  });
}
