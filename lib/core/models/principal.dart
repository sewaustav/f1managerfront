import 'package:freezed_annotation/freezed_annotation.dart';

part 'principal.freezed.dart';
part 'principal.g.dart';

@freezed
class Principal with _$Principal {
  const factory Principal({
    @JsonKey(name: 'ID') required int id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'Price') @Default(0) int price,
    @JsonKey(name: 'TeamID') @Default(0) int teamId,
    @JsonKey(name: 'Level') @Default(0) int level,
  }) = _Principal;
  factory Principal.fromJson(Map<String, dynamic> json) => _$PrincipalFromJson(json);
}
