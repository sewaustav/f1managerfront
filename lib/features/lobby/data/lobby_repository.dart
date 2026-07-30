import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../model/group_requests.dart';
import '../model/player.dart';

class LobbyRepository {
  LobbyRepository(this._dio);
  final Dio _dio;

  Future<void> createGroup(CreateGroupRequest r) => _dio.post('/groups', data: r.toJson());
  Future<void> joinGroup(JoinGroupRequest r) => _dio.post('/groups/join', data: r.toJson());

  Future<List<Player>> getPlayers() async {
    final res = await _dio.get('/players');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(Player.fromJson).toList();
  }

  Future<void> startDraft() => _dio.post('/draft/start');
}

final lobbyRepositoryProvider =
    Provider<LobbyRepository>((ref) => LobbyRepository(ref.watch(dioProvider)));
