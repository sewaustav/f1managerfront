import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pilot.dart';
import '../../../core/models/principal.dart';
import '../../draft/data/draft_repository.dart';
import '../../draft/model/budget.dart';
import '../data/inter_season_repository.dart';
import '../model/my_team_summary.dart';

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

final ownedPilotsProvider = FutureProvider.autoDispose<List<Pilot>>((ref) async {
  final pilots = await ref.watch(allPilotsProvider.future);
  return pilots.where((p) => p.team != null).toList();
});

final interSeasonPrincipalsProvider = FutureProvider.autoDispose<List<Principal>>(
    (ref) => ref.watch(draftRepositoryProvider).getPrincipals());
