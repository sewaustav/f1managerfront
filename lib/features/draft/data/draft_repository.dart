import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/models/pilot.dart';
import '../../../core/models/team.dart';
import '../../../core/models/principal.dart';
import '../model/engine.dart';
import '../model/budget.dart';

/// Recovers "whose turn is it" — see GET /draft/state. draft_turn is
/// otherwise a single, targeted, one-shot WS message that is silently
/// dropped if the recipient's socket wasn't connected at that exact instant,
/// which would otherwise deadlock the whole draft with no way to recover.
class DraftTurnState {
  const DraftTurnState({
    required this.active,
    required this.round,
    required this.isMyTurn,
    required this.finished,
    this.currentUserId = 0,
  });

  final bool active;
  final int round;
  final bool isMyTurn;
  final bool finished;
  final int currentUserId;

  factory DraftTurnState.fromJson(Map<String, dynamic> json) => DraftTurnState(
        active: json['active'] as bool? ?? false,
        round: (json['round'] as num?)?.toInt() ?? 0,
        isMyTurn: json['is_my_turn'] as bool? ?? false,
        finished: json['finished'] as bool? ?? false,
        currentUserId: (json['current_user_id'] as num?)?.toInt() ?? 0,
      );
}

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

  Future<DraftTurnState> getDraftState() async {
    final res = await _dio.get('/draft/state');
    return DraftTurnState.fromJson((res.data as Map).cast<String, dynamic>());
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
