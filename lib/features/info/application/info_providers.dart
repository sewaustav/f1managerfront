import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pilot.dart';
import '../../draft/data/draft_repository.dart';
import '../../season/data/season_repository.dart';
import '../../season/model/track_info.dart';
import '../../inter_season/model/my_team_summary.dart';
import '../data/info_repository.dart';

final tracksProvider = FutureProvider.autoDispose<List<TrackInfo>>(
    (ref) => ref.watch(seasonRepositoryProvider).getTracks());

final squadsProvider = FutureProvider.autoDispose<List<MyTeamSummary>>(
    (ref) => ref.watch(infoRepositoryProvider).getSquads());

final allPilotsInfoProvider = FutureProvider.autoDispose<List<Pilot>>(
    (ref) => ref.watch(draftRepositoryProvider).getPilots());
