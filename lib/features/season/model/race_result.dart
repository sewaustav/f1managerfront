import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_result.freezed.dart';
part 'race_result.g.dart';

@freezed
class RaceResult with _$RaceResult {
  const factory RaceResult({
    @JsonKey(name: 'pilot_id') @Default(0) int pilotId,
    @JsonKey(name: 'garage_id') @Default(0) int garageId,
    @JsonKey(name: 'pilot_name') @Default('') String pilotName,
    @JsonKey(name: 'team_name') @Default('') String teamName,
    @JsonKey(name: 'quali_position') @Default(0) int qualiPosition,
    @JsonKey(name: 'race_position') @Default(0) int racePosition,
    @Default(0) int points,
    @JsonKey(name: 'is_dnf') @Default(false) bool isDnf,
    @JsonKey(name: 'dnf_reason') @Default('') String dnfReason,
  }) = _RaceResult;
  factory RaceResult.fromJson(Map<String, dynamic> json) => _$RaceResultFromJson(json);
}

@freezed
class RaceResultResponse with _$RaceResultResponse {
  const factory RaceResultResponse({
    @Default(0) int stage,
    @Default(<RaceResult>[]) List<RaceResult> results,
  }) = _RaceResultResponse;
  factory RaceResultResponse.fromJson(Map<String, dynamic> json) =>
      _$RaceResultResponseFromJson(json);
}
