import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/pilot.dart';
import '../../../core/models/team.dart';
import '../../../core/models/principal.dart';
import '../data/draft_repository.dart';
import '../model/engine.dart';

final pilotsProvider = FutureProvider.autoDispose<List<Pilot>>(
    (ref) => ref.watch(draftRepositoryProvider).getPilots());
final teamsProvider = FutureProvider.autoDispose<List<Team>>(
    (ref) => ref.watch(draftRepositoryProvider).getTeams());
final principalsProvider = FutureProvider.autoDispose<List<Principal>>(
    (ref) => ref.watch(draftRepositoryProvider).getPrincipals());
final enginesProvider = FutureProvider.autoDispose<List<Engine>>(
    (ref) => ref.watch(draftRepositoryProvider).getEngines());
