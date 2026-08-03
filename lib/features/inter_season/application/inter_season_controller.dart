import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ws/ws_providers.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../data/inter_season_repository.dart';
import '../model/transfer_events.dart';

class InterSeasonState {
  const InterSeasonState({
    this.seasonStarted = false,
    this.ready = false,
    this.busy = false,
    this.error,
  });

  final bool seasonStarted;
  final bool ready;
  final bool busy;
  final String? error;

  static const _sentinel = Object();

  InterSeasonState copyWith({
    bool? seasonStarted,
    bool? ready,
    bool? busy,
    Object? error = _sentinel,
  }) =>
      InterSeasonState(
        seasonStarted: seasonStarted ?? this.seasonStarted,
        ready: ready ?? this.ready,
        busy: busy ?? this.busy,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );
}

class InterSeasonController extends AutoDisposeNotifier<InterSeasonState> {
  @override
  InterSeasonState build() {
    ref.listen(wsMessagesProvider, (_, next) {
      final msg = next.valueOrNull;
      if (msg == null) return;
      if (isSeasonStarted(msg)) {
        state = state.copyWith(seasonStarted: true);
      }
    });
    return const InterSeasonState();
  }

  Future<void> markReady() async {
    state = state.copyWith(busy: true, error: null);
    try {
      await ref.read(interSeasonRepositoryProvider).markReady();
      state = state.copyWith(ready: true, busy: false);
    } catch (e) {
      state = state.copyWith(busy: false, error: errorMessage(e));
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final interSeasonControllerProvider =
    AutoDisposeNotifierProvider<InterSeasonController, InterSeasonState>(InterSeasonController.new);
