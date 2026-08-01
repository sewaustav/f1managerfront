import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/season_state.dart';
import '../data/season_state_repository.dart';

class SeasonStateController extends AutoDisposeAsyncNotifier<SeasonState> {
  @override
  Future<SeasonState> build() =>
      ref.watch(seasonStateRepositoryProvider).getSeasonState();

  Future<void> refresh() async {
    state = const AsyncLoading<SeasonState>().copyWithPrevious(state);
    state = await AsyncValue.guard(
        () => ref.read(seasonStateRepositoryProvider).getSeasonState());
  }
}

final seasonStateProvider =
    AutoDisposeAsyncNotifierProvider<SeasonStateController, SeasonState>(
        SeasonStateController.new);
