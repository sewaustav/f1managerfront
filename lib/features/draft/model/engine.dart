import 'package:freezed_annotation/freezed_annotation.dart';

part 'engine.freezed.dart';
part 'engine.g.dart';

/// ICEName integer values from the backend (models.ICEName iota).
const int kIceSelf = 9;

@freezed
class Engine with _$Engine {
  const factory Engine({
    @JsonKey(name: 'ID') required int id,
    @JsonKey(name: 'Engine') @Default(0) int engine,
    @JsonKey(name: 'Price') @Default(0) int price,
    @JsonKey(name: 'BaseLevel') @Default(0) int baseLevel,
  }) = _Engine;
  factory Engine.fromJson(Map<String, dynamic> json) => _$EngineFromJson(json);
}
