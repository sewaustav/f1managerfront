import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ws/ws_providers.dart';
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

class SeasonController extends AutoDisposeNotifier<SeasonState> {
  @override
  SeasonState build() {
    ref.listen(wsMessagesProvider, (_, next) {
      final msg = next.valueOrNull;
      if (msg == null) return;
      final event = raceFinishedFromMessage(msg);
      if (event != null) _onRaceFinished(event);
    });
    return const SeasonState();
  }

  Future<void> _onRaceFinished(RaceFinished event) async {
    if (event.status != 'race_finished') {
      state = state.copyWith(error: 'Race failed (${event.status})', waiting: false);
      return;
    }
    try {
      final result = await ref.read(seasonRepositoryProvider).getRaceResult();
      state = state.copyWith(result: result, waiting: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), waiting: false);
    }
  }

  Future<void> submitSetup(SetupPayload payload) async {
    state = state.copyWith(submitted: true, waiting: true, error: null);
    try {
      await ref.read(seasonRepositoryProvider).submitSetup(payload);
    } catch (e) {
      state = state.copyWith(error: e.toString(), waiting: false, submitted: false);
    }
  }

  void reset() => state = const SeasonState();
}

final seasonControllerProvider =
    AutoDisposeNotifierProvider<SeasonController, SeasonState>(SeasonController.new);
