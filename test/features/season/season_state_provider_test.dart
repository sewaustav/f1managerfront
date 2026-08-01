import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/season_state.dart';
import 'package:f1manager/features/season/data/season_state_repository.dart';
import 'package:f1manager/features/season/application/season_state_provider.dart';

class _FakeRepo extends SeasonStateRepository {
  _FakeRepo() : super(Dio());
  SeasonState value = const SeasonState(phase: SeasonPhase.draft);
  @override
  Future<SeasonState> getSeasonState() async => value;
}

void main() {
  test('provider fetches then refresh re-fetches', () async {
    final repo = _FakeRepo();
    final c = ProviderContainer(overrides: [
      seasonStateRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(c.dispose);
    expect((await c.read(seasonStateProvider.future)).phase, SeasonPhase.draft);
    repo.value = const SeasonState(phase: SeasonPhase.racing, stage: 2);
    await c.read(seasonStateProvider.notifier).refresh();
    expect(c.read(seasonStateProvider).value!.phase, SeasonPhase.racing);
  });
}
