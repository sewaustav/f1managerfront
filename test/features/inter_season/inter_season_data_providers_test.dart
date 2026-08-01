import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:f1manager/core/models/pilot.dart';
import 'package:f1manager/features/draft/data/draft_repository.dart';
import 'package:f1manager/features/inter_season/application/inter_season_data_providers.dart';

class _FakeDraftRepo extends DraftRepository {
  _FakeDraftRepo() : super(Dio());
  @override
  Future<List<Pilot>> getPilots() async => const [
        Pilot(id: 1, name: 'Free', team: null),
        Pilot(id: 2, name: 'Owned', team: 3),
      ];
}

void main() {
  test('freePilotsProvider keeps team==null; owned keeps rest', () async {
    final c = ProviderContainer(overrides: [
      draftRepositoryProvider.overrideWithValue(_FakeDraftRepo()),
    ]);
    addTearDown(c.dispose);
    final free = await c.read(freePilotsProvider.future);
    final owned = await c.read(ownedPilotsProvider.future);
    expect(free.map((p) => p.id), [1]);
    expect(owned.map((p) => p.id), [2]);
  });
}
