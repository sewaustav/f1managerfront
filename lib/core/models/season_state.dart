import 'package:freezed_annotation/freezed_annotation.dart';

part 'season_state.freezed.dart';
part 'season_state.g.dart';

enum SeasonPhase {
  @JsonValue('draft')
  draft,
  @JsonValue('token_setup')
  tokenSetup,
  @JsonValue('racing')
  racing,
  @JsonValue('inter_season')
  interSeason,
  unknown,
}

@freezed
class SeasonState with _$SeasonState {
  const factory SeasonState({
    @JsonKey(unknownEnumValue: SeasonPhase.unknown) required SeasonPhase phase,
    @Default(0) int stage,
    @JsonKey(name: 'submitted_setups')
    @Default(<int>[])
    List<int> submittedSetups,
    @JsonKey(name: 'total_players') @Default(0) int totalPlayers,
  }) = _SeasonState;

  factory SeasonState.fromJson(Map<String, dynamic> json) =>
      _$SeasonStateFromJson(json);
}
