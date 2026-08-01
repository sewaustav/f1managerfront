import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/models/season_state.dart';

class SeasonStateRepository {
  SeasonStateRepository(this._dio);
  final Dio _dio;

  Future<SeasonState> getSeasonState() async {
    final res = await _dio.get('/season/state');
    return SeasonState.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

final seasonStateRepositoryProvider =
    Provider<SeasonStateRepository>((ref) => SeasonStateRepository(ref.watch(dioProvider)));
