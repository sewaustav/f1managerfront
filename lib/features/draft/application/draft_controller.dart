import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_state.dart';
import '../../../core/ws/ws_providers.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../../lobby/application/lobby_controller.dart' show playersProvider;
import '../data/draft_repository.dart';
import '../model/draft_events.dart';
import 'draft_data_providers.dart';

class DraftState {
  const DraftState({
    this.isMyTurn = false,
    this.round = 0,
    this.history = const [],
    this.finished = false,
    this.lastError,
    this.submitting = false,
    this.currentUserId,
  });

  final bool isMyTurn;
  final int round;
  final List<DraftPickMade> history;
  final bool finished;
  final String? lastError;
  final bool submitting;

  /// Whose turn it currently is, group-wide — null when unknown (draft not
  /// active, or not yet recovered/received over WS).
  final int? currentUserId;

  DraftState copyWith({
    bool? isMyTurn,
    int? round,
    List<DraftPickMade>? history,
    bool? finished,
    Object? lastError = _sentinel,
    bool? submitting,
    Object? currentUserId = _sentinel,
  }) =>
      DraftState(
        isMyTurn: isMyTurn ?? this.isMyTurn,
        round: round ?? this.round,
        history: history ?? this.history,
        finished: finished ?? this.finished,
        lastError: identical(lastError, _sentinel) ? this.lastError : lastError as String?,
        submitting: submitting ?? this.submitting,
        currentUserId:
            identical(currentUserId, _sentinel) ? this.currentUserId : currentUserId as int?,
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
        state = state.copyWith(finished: true, isMyTurn: false, currentUserId: null);
      } else if (st.active) {
        state = state.copyWith(isMyTurn: st.isMyTurn, round: st.round, currentUserId: st.currentUserId);
      } else {
        // No active draft and not finished either (never started, or
        // cancelled via "end game early"): clear any turn state a client
        // may have been holding onto from before — otherwise a stale
        // isMyTurn=true from an earlier WS message survives forever, since
        // there's no other signal to correct it once the draft is gone.
        state = state.copyWith(isMyTurn: false, currentUserId: null);
      }
    } catch (_) {
      // best-effort; the WS path remains the primary source of truth
    }
  }

  void _apply(DraftEvent event) {
    switch (event) {
      case DraftTurn(:final round, :final userId):
        final myId = ref.read(currentUserIdProvider);
        state = state.copyWith(
          isMyTurn: myId != null && myId == userId,
          round: round,
          lastError: null,
          currentUserId: userId,
        );
      case DraftRetry(:final error):
        state = state.copyWith(lastError: error, isMyTurn: true, submitting: false);
      case DraftPickMade():
        state = state.copyWith(
          history: [...state.history, event],
          isMyTurn: false,
          submitting: false,
        );
        // A pilot/team/principal just became unavailable to everyone (this
        // broadcasts to the whole group, not just the picker) — refetch so
        // it drops out of the pick lists instead of lingering as a stale,
        // already-taken option that fails with a confusing error on click.
        ref.invalidate(pilotsProvider);
        ref.invalidate(teamsProvider);
        ref.invalidate(principalsProvider);
        ref.invalidate(playersProvider);
      case DraftFinished():
        state = state.copyWith(finished: true, isMyTurn: false, currentUserId: null);
    }
  }

  Future<void> submitPick({required int pick, required int itemId, int? engine}) async {
    state = state.copyWith(submitting: true, lastError: null);
    try {
      await ref.read(draftRepositoryProvider).pick(pick: pick, itemId: itemId, engine: engine);
      // success/turn advance arrives via WS broadcast; keep submitting until then.
    } catch (e) {
      state = state.copyWith(submitting: false, lastError: errorMessage(e));
    }
  }

  void clearError() => state = state.copyWith(lastError: null);
}

final draftControllerProvider =
    AutoDisposeNotifierProvider<DraftController, DraftState>(DraftController.new);
