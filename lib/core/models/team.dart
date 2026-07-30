import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';
part 'team.g.dart';

@freezed
class Team with _$Team {
  const factory Team({
    @JsonKey(name: 'ID') required int id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'ICE') @Default(0) int ice,
    @JsonKey(name: 'CarLevel') @Default(0) int carLevel,
    @JsonKey(name: 'BaseLevel') @Default(0) int baseLevel,
    @JsonKey(name: 'Engineer') @Default(0) int engineer,
    @JsonKey(name: 'SimLevel') @Default(0) int simLevel,
    @JsonKey(name: 'TubeLevel') @Default(0) int tubeLevel,
    @JsonKey(name: 'UpdateRating') @Default(0) int updateRating,
    @JsonKey(name: 'Tokens') @Default(0) int tokens,
    @JsonKey(name: 'Budget') @Default(0) int budget,
    @JsonKey(name: 'IsManufacturer') @Default(0) int isManufacturer,
    @JsonKey(name: 'CarSettings') @Default(0) int carSettings,
  }) = _Team;
  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}
