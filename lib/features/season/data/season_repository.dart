import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../draft/model/budget.dart';
import '../model/setup_payload.dart';
import '../model/track_info.dart';
import '../model/race_result.dart';
import '../model/standing.dart';

class SeasonRepository {
  SeasonRepository(this._dio);
  final Dio _dio;

  Future<List<TrackInfo>> getTracks() async {
    final res = await _dio.get('/track');
    return (res.data as List).cast<Map<String, dynamic>>().map(TrackInfo.fromJson).toList();
  }

  Future<RaceResultResponse> getRaceResult() async {
    final res = await _dio.get('/race-result');
    return RaceResultResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Standing> getStanding() async {
    final res = await _dio.get('/standing');
    return Standing.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Budget> getBudget() async {
    final res = await _dio.get('/budget');
    return Budget.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> submitTokenSetup(SetupPayload p) => _dio.post('/token-setup', data: p.toJson());
  Future<void> submitSetup(SetupPayload p) => _dio.post('/setup', data: p.toJson());

  Future<void> makeUpdate({required int type, required int coast, required int stage}) =>
      _dio.post('/updates', data: {'type': type, 'coast': coast, 'stage': stage});

  Future<void> initRound(int stage) => _dio.post('/rounds/$stage/init');
}

final seasonRepositoryProvider =
    Provider<SeasonRepository>((ref) => SeasonRepository(ref.watch(dioProvider)));
