import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_info.freezed.dart';
part 'track_info.g.dart';

@freezed
class TrackInfo with _$TrackInfo {
  const factory TrackInfo({
    @JsonKey(name: 'ID') required int id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'DownForceLevel') @Default(0) int downForceLevel,
    @JsonKey(name: 'Type') @Default(0) int type,
    @JsonKey(name: 'Difficulty') @Default(0) int difficulty,
    @JsonKey(name: 'QualifyingImpact') @Default(0) int qualifyingImpact,
    @JsonKey(name: 'RainPossibility') @Default(0) int rainPossibility,
    @JsonKey(name: 'Tyre') @Default(0) int tyre,
  }) = _TrackInfo;
  factory TrackInfo.fromJson(Map<String, dynamic> json) => _$TrackInfoFromJson(json);
}
