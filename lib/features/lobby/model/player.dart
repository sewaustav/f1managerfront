import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    @JsonKey(name: 'ID') required int id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'TeamPrincipal') int? teamPrincipal,
    @JsonKey(name: 'Team') @Default(0) int team,
    @JsonKey(name: 'Budget') @Default(0) int budget,
    @JsonKey(name: 'Tokens') @Default(0) int tokens,
  }) = _Player;
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
