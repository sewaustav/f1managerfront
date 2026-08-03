import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../model/my_team_summary.dart';
import '../model/transfer_offer.dart';

class InterSeasonRepository {
  InterSeasonRepository(this._dio);
  final Dio _dio;

  Future<MyTeamSummary> getMyTeam() async {
    final res = await _dio.get('/my-team');
    return MyTeamSummary.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<void> buyPilot({required int pilotId, required int price}) =>
      _dio.post('/transfers/pilot', data: {'pilot_id': pilotId, 'price': price});

  Future<void> hirePrincipal({required int principalId, required int price}) =>
      _dio.post('/transfers/principal', data: {'principal_id': principalId, 'price': price});

  Future<void> fire({required String who, required int id}) =>
      _dio.post('/fire', data: {'who': who, 'id': id});

  Future<void> updateBase({
    required int base,
    required int engineer,
    required int tube,
    required int sim,
  }) =>
      _dio.post('/base', data: {'base': base, 'engineer': engineer, 'tube': tube, 'sim': sim});

  Future<void> markReady() => _dio.post('/ready');

  /// Входящие предложения выкупить моего пилота. Опрашивается клиентом:
  /// доставка через WS оказалась ненадёжной, а владелец может быть офлайн
  /// в момент отправки предложения.
  Future<List<TransferOffer>> getIncomingOffers() async {
    final res = await _dio.get('/transfers/offers');
    final list = (res.data as List?) ?? const [];
    return list
        .cast<Map<String, dynamic>>()
        .map(TransferOffer.fromJson)
        .toList();
  }

  Future<void> respondToOffer({required int offerId, required bool accept}) =>
      _dio.post('/transfers/offers/respond',
          data: {'offer_id': offerId, 'accept': accept});
}

final interSeasonRepositoryProvider =
    Provider<InterSeasonRepository>((ref) => InterSeasonRepository(ref.watch(dioProvider)));
