import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/models/pilot.dart';
import '../../../core/models/principal.dart';
import '../../draft/data/draft_repository.dart';
import '../../draft/model/budget.dart';
import '../data/inter_season_repository.dart';
import '../model/my_team_summary.dart';
import '../model/transfer_offer.dart';

final myTeamProvider = FutureProvider.autoDispose<MyTeamSummary>(
    (ref) => ref.watch(interSeasonRepositoryProvider).getMyTeam());

final interSeasonBudgetProvider = FutureProvider.autoDispose<Budget>(
    (ref) => ref.watch(draftRepositoryProvider).getBudget());

final allPilotsProvider = FutureProvider.autoDispose<List<Pilot>>(
    (ref) => ref.watch(draftRepositoryProvider).getPilots());

final freePilotsProvider = FutureProvider.autoDispose<List<Pilot>>((ref) async {
  final pilots = await ref.watch(allPilotsProvider.future);
  return pilots.where((p) => p.team == null).toList();
});

/// Пилоты, принадлежащие ДРУГИМ игрокам — их можно попробовать выкупить.
/// Свои собственные сюда попадать не должны: предложить выкуп у самого себя
/// нельзя, и сервер такой запрос отклонит.
final ownedPilotsProvider = FutureProvider.autoDispose<List<Pilot>>((ref) async {
  final pilots = await ref.watch(allPilotsProvider.future);
  final myId = ref.watch(currentUserIdProvider);
  return pilots.where((p) => p.team != null && p.team != myId).toList();
});

final interSeasonPrincipalsProvider = FutureProvider.autoDispose<List<Principal>>(
    (ref) => ref.watch(draftRepositoryProvider).getPrincipals());

/// Как часто перечитываются входящие предложения. Сервер о них не сигналит,
/// а WS-доставка здесь себя не оправдала — без опроса владелец не узнает,
/// что ему что-то предложили.
const offersPollInterval = Duration(seconds: 5);

final incomingOffersProvider =
    FutureProvider.autoDispose<List<TransferOffer>>((ref) {
  final timer = Timer.periodic(offersPollInterval, (_) => ref.invalidateSelf());
  ref.onDispose(timer.cancel);
  return ref.watch(interSeasonRepositoryProvider).getIncomingOffers();
});
