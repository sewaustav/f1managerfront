import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ws/ws_providers.dart';
import '../data/draft_repository.dart';
import '../model/draft_events.dart';

class DraftState {
  const DraftState({
    this.isMyTurn = false,
    this.round = 0,
    this.history = const [],
    this.finished = false,
    this.lastError,
    this.submitting = false,
  });

  final bool isMyTurn;
  final int round;
  final List<DraftPickMade> history;
  final bool finished;
  final String? lastError;
  final bool submitting;

  DraftState copyWith({
    bool? isMyTurn,
    int? round,
    List<DraftPickMade>? history,
    bool? finished,
    Object? lastError = _sentinel,
    bool? submitting,
  }) =>
      DraftState(
        isMyTurn: isMyTurn ?? this.isMyTurn,
        round: round ?? this.round,
        history: history ?? this.history,
        finished: finished ?? this.finished,
        lastError: identical(lastError, _sentinel) ? this.lastError : lastError as String?,
        submitting: submitting ?? this.submitting,
      );

  static const _sentinel = Object();
}

class DraftController extends AutoDisposeNotifier<DraftState> {
  @override
  DraftState build() {
    ref.listen(wsMessagesProvider, (_, next) {
      final msg = next.valueOrNull;
      if (msg == null) return;
      final event = draftEventFromMessage(msg);
      if (event != null) _apply(event);
    });
    // Best-effort recovery of a missed draft_turn WS message (see
    // GET /draft/state): draft_turn is a single, targeted, one-shot message
    // that is silently dropped if this client's WS wasn't connected at that
    // exact instant, otherwise deadlocking the whole draft forever. A
    // failure here just leaves the UI relying on WS as before.
    refreshTurnState();
    return const DraftState();
  }

  Future<void> refreshTurnState() async {
    try {
      final st = await ref.read(draftRepositoryProvider).getDraftState();
      if (st.finished) {
        state = state.copyWith(finished: true, isMyTurn: false);
      } else if (st.active) {
        state = state.copyWith(isMyTurn: st.isMyTurn, round: st.round);
      }
    } catch (_) {
      // best-effort; the WS path remains the primary source of truth
    }
  }

  void _apply(DraftEvent event) {
    switch (event) {
      case DraftTurn(:final round):
        state = state.copyWith(isMyTurn: true, round: round, lastError: null);
      case DraftRetry(:final error):
        state = state.copyWith(lastError: error, isMyTurn: true, submitting: false);
      case DraftPickMade():
        state = state.copyWith(
          history: [...state.history, event],
          isMyTurn: false,
          submitting: false,
        );
      case DraftFinished():
        state = state.copyWith(finished: true, isMyTurn: false);
    }
  }

  Future<void> submitPick({required int pick, required int itemId, int? engine}) async {
    state = state.copyWith(submitting: true, lastError: null);
    try {
      await ref.read(draftRepositoryProvider).pick(pick: pick, itemId: itemId, engine: engine);
      // success/turn advance arrives via WS broadcast; keep submitting until then.
    } catch (e) {
      state = state.copyWith(submitting: false, lastError: e.toString());
    }
  }

  void clearError() => state = state.copyWith(lastError: null);
}

final draftControllerProvider =
    AutoDisposeNotifierProvider<DraftController, DraftState>(DraftController.new);
