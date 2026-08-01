import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/models/pilot.dart';
import '../../../core/models/team.dart';
import '../../../core/models/principal.dart';
import '../model/engine.dart';
import '../model/budget.dart';

class DraftRepository {
  DraftRepository(this._dio);
  final Dio _dio;

  Future<List<T>> _list<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final res = await _dio.get(path);
    return (res.data as List).cast<Map<String, dynamic>>().map(fromJson).toList();
  }

  Future<List<Pilot>> getPilots() => _list('/pilots', Pilot.fromJson);
  Future<List<Team>> getTeams() => _list('/teams', Team.fromJson);
  Future<List<Principal>> getPrincipals() => _list('/principals', Principal.fromJson);
  Future<List<Engine>> getEngines() => _list('/engines', Engine.fromJson);

  Future<Budget> getBudget() async {
    final res = await _dio.get('/budget');
    return Budget.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> pick({required int pick, required int itemId, int? engine}) {
    final data = <String, dynamic>{'pick': pick, 'item_id': itemId};
    if (engine != null) data['engine'] = engine;
    return _dio.post('/draft/pick', data: data);
  }

  Future<void> swapBots({
    required int teamA,
    required int teamB,
    required int pilotA,
    required int pilotB,
  }) =>
      _dio.post('/draft/bots/swap',
          data: {'team_a': teamA, 'team_b': teamB, 'pilot_a': pilotA, 'pilot_b': pilotB});
}

final draftRepositoryProvider =
    Provider<DraftRepository>((ref) => DraftRepository(ref.watch(dioProvider)));
