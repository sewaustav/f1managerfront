import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../draft/data/draft_repository.dart';
import '../../draft/model/budget.dart';
import '../../inter_season/data/inter_season_repository.dart';
import '../../inter_season/model/my_team_summary.dart';

final myTeamDetailProvider = FutureProvider.autoDispose<MyTeamSummary>(
    (ref) => ref.watch(interSeasonRepositoryProvider).getMyTeam());

final myTeamBudgetProvider = FutureProvider.autoDispose<Budget>(
    (ref) => ref.watch(draftRepositoryProvider).getBudget());
