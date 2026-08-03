import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ws/ws_providers.dart';
import '../../../shared/widgets/error_snackbar.dart';
import '../data/season_repository.dart';
import '../model/race_result.dart';
import '../model/setup_payload.dart';
import 'season_events.dart';

class SeasonState {
  const SeasonState({
    this.submitted = false,
    this.waiting = false,
    this.result,
    this.error,
  });

  final bool submitted;
  final bool waiting;
  final RaceResultResponse? result;
  final String? error;

  static const _sentinel = Object();

  SeasonState copyWith({
    bool? submitted,
    bool? waiting,
    Object? result = _sentinel,
    Object? error = _sentinel,
  }) =>
      SeasonState(
        submitted: submitted ?? this.submitted,
        waiting: waiting ?? this.waiting,
        result: identical(result, _sentinel) ? this.result : result as RaceResultResponse?,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );
}

/// How often a player waiting on a race asks the server whether it has
/// finished. race_finished is a one-shot WS broadcast: miss it and the race
/// screen sits on "Waiting for other players…" forever even though the race
/// already ran and the standings were written. Polling is the dependable
/// path; WS just makes the common case instant.
const raceResultPollInterval = Duration(seconds: 3);

class SeasonController extends AutoDisposeNotifier<SeasonState> {
  Timer? _pollTimer;

  /// Stage this player submitted a setup for — used to tell "my race
  /// finished" apart from a result left over from an earlier stage.
  int? _awaitingStage;

  @override
  SeasonState build() {
    ref.listen(wsMessagesProvider, (_, next) {
      final msg = next.valueOrNull;
      if (msg == null) return;
      final event = raceFinishedFromMessage(msg);
      if (event != null) _onRaceFinished(event);
    });
    ref.onDispose(() => _pollTimer?.cancel());
    return const SeasonState();
  }

  Future<void> _onRaceFinished(RaceFinished event) async {
    _stopPolling();
    if (event.status != 'race_finished') {
      state = state.copyWith(error: 'Race failed (${event.status})', waiting: false);
      return;
    }
    try {
      final result = await ref.read(seasonRepositoryProvider).getRaceResult();
      state = state.copyWith(result: result, waiting: false, error: null);
    } catch (e) {
      state = state.copyWith(error: errorMessage(e), waiting: false);
    }
  }

  Future<void> submitSetup(SetupPayload payload, {int? stage}) async {
    _awaitingStage = stage;
    state = state.copyWith(submitted: true, waiting: true, error: null);
    try {
      await ref.read(seasonRepositoryProvider).submitSetup(payload);
      if (stage != null) _startPolling();
    } catch (e) {
      state = state.copyWith(error: errorMessage(e), waiting: false, submitted: false);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(raceResultPollInterval, (_) => pollForResult());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Asks the server for the latest race result and, if it is the race this
  /// player was waiting on, shows it. A result from an earlier stage means
  /// our race simply hasn't run yet, so we keep waiting.
  Future<void> pollForResult() async {
    final awaiting = _awaitingStage;
    if (!state.waiting || awaiting == null) {
      _stopPolling();
      return;
    }
    try {
      final result = await ref.read(seasonRepositoryProvider).getRaceResult();
      if (result.results.isEmpty || result.stage < awaiting) return;
      _stopPolling();
      state = state.copyWith(result: result, waiting: false, error: null);
    } catch (_) {
      // transient; keep polling
    }
  }

  void reset() {
    _stopPolling();
    _awaitingStage = null;
    state = const SeasonState();
  }
}

final seasonControllerProvider =
    AutoDisposeNotifierProvider<SeasonController, SeasonState>(SeasonController.new);
