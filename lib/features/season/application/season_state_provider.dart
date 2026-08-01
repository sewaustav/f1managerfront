import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/models/season_state.dart';
import '../../../core/ws/ws_message.dart';
import '../../../core/ws/ws_providers.dart';
import '../../lobby/application/lobby_controller.dart';
import '../data/season_state_repository.dart';

/// WS broadcast types that indicate the season phase (or the waiting
/// counter) may have changed server-side.
const _phaseRelevantWsTypes = {
  'draft_turn',
  'draft_finished',
  'race_finished',
  'season_started',
};

class SeasonStateController extends AutoDisposeAsyncNotifier<SeasonState> {
  @override
  Future<SeasonState> build() {
    final authed = ref.watch(isAuthenticatedProvider);
    final hasGroup = ref.watch(hasGroupProvider);

    ref.listen<AsyncValue<WsMessage>>(wsMessagesProvider, (previous, next) {
      final message = next.valueOrNull;
      if (message != null && _phaseRelevantWsTypes.contains(message.type)) {
        refresh();
      }
    });

    final timer = Timer.periodic(const Duration(seconds: 5), (_) => refresh());
    ref.onDispose(timer.cancel);

    if (!(authed && hasGroup)) {
      return Future.value(const SeasonState(phase: SeasonPhase.unknown));
    }
    return ref.watch(seasonStateRepositoryProvider).getSeasonState();
  }

  Future<void> refresh() async {
    if (!(ref.read(isAuthenticatedProvider) && ref.read(hasGroupProvider))) {
      state = const AsyncData<SeasonState>(SeasonState(phase: SeasonPhase.unknown));
      return;
    }
    state = const AsyncLoading<SeasonState>().copyWithPrevious(state);
    state = await AsyncValue.guard(
        () => ref.read(seasonStateRepositoryProvider).getSeasonState());
  }
}

final seasonStateProvider =
    AutoDisposeAsyncNotifierProvider<SeasonStateController, SeasonState>(
        SeasonStateController.new);
