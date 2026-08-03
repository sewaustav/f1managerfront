import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:f1manager/core/ws/ws_message.dart';
import 'package:f1manager/core/ws/ws_providers.dart';
import 'package:f1manager/features/season/application/season_controller.dart';
import 'package:f1manager/features/season/data/season_repository.dart';
import 'package:f1manager/features/season/model/race_result.dart';
import 'package:f1manager/features/season/model/setup_payload.dart';

class _MockRepo extends Mock implements SeasonRepository {}

const _payload = SetupPayload(name: 'race');

void main() {
  setUpAll(() => registerFallbackValue(_payload));

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

  // race_finished is a one-shot WS broadcast. When it was missed the race
  // screen sat on "Waiting for other players…" forever, even though the race
  // had already run and the standings were written server-side. Polling must
  // recover that on its own.
  test('a missed race_finished still resolves via pollForResult', () async {
    final repo = _MockRepo();
    when(() => repo.submitSetup(any())).thenAnswer((_) async {});
    when(() => repo.getRaceResult()).thenAnswer((_) async => const RaceResultResponse(
        stage: 1, results: [RaceResult(pilotName: 'Russell', racePosition: 1)]));

    final container = ProviderContainer(overrides: [
      seasonRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(container.dispose);
    container.listen(seasonControllerProvider, (_, __) {});

    final notifier = container.read(seasonControllerProvider.notifier);
    await notifier.submitSetup(_payload, stage: 1);
    expect(container.read(seasonControllerProvider).waiting, isTrue);

    // no WS message ever arrives — the poll is the only thing that can save us
    await notifier.pollForResult();

    final st = container.read(seasonControllerProvider);
    expect(st.waiting, isFalse);
    expect(st.result?.results.single.pilotName, 'Russell');
  });

  test('a result from an earlier stage keeps the player waiting', () async {
    final repo = _MockRepo();
    when(() => repo.submitSetup(any())).thenAnswer((_) async {});
    // the last finished race is stage 1; we are waiting on stage 2
    when(() => repo.getRaceResult()).thenAnswer((_) async => const RaceResultResponse(
        stage: 1, results: [RaceResult(pilotName: 'Russell', racePosition: 1)]));

    final container = ProviderContainer(overrides: [
      seasonRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(container.dispose);
    container.listen(seasonControllerProvider, (_, __) {});

    final notifier = container.read(seasonControllerProvider.notifier);
    await notifier.submitSetup(_payload, stage: 2);
    await notifier.pollForResult();

    final st = container.read(seasonControllerProvider);
    expect(st.waiting, isTrue, reason: 'our race has not run yet');
    expect(st.result, isNull);
  });

  // If the screen cannot supply the stage, polling must still happen —
  // "no stage" used to mean "no polling", i.e. waiting forever on a dropped
  // race_finished. We fall back to "anything newer than the last result".
  test('an unknown stage still polls, using the last result as the baseline', () async {
    final repo = _MockRepo();
    when(() => repo.submitSetup(any())).thenAnswer((_) async {});
    // last recorded race is stage 2, so our race must be stage 3+
    var current = const RaceResultResponse(stage: 2, results: [RaceResult(pilotName: 'Old')]);
    when(() => repo.getRaceResult()).thenAnswer((_) async => current);

    final container = ProviderContainer(overrides: [
      seasonRepositoryProvider.overrideWithValue(repo),
      wsMessagesProvider.overrideWith((ref) => const Stream<WsMessage>.empty()),
    ]);
    addTearDown(container.dispose);
    container.listen(seasonControllerProvider, (_, __) {});

    final notifier = container.read(seasonControllerProvider.notifier);
    await notifier.submitSetup(_payload); // no stage available

    await notifier.pollForResult();
    expect(container.read(seasonControllerProvider).waiting, isTrue,
        reason: 'stage 2 is the result that already existed before we raced');

    current = const RaceResultResponse(stage: 3, results: [RaceResult(pilotName: 'Fresh')]);
    await notifier.pollForResult();

    final st = container.read(seasonControllerProvider);
    expect(st.waiting, isFalse);
    expect(st.result?.results.single.pilotName, 'Fresh');
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
