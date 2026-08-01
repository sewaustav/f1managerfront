import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../inter_season/model/my_team_summary.dart';

class InfoRepository {
  InfoRepository(this._dio);
  final Dio _dio;

  Future<List<MyTeamSummary>> getSquads() async {
    final res = await _dio.get('/players/squads');
    return (res.data as List)
        .map((e) => MyTeamSummary.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}

final infoRepositoryProvider =
    Provider<InfoRepository>((ref) => InfoRepository(ref.watch(dioProvider)));
