import 'package:freezed_annotation/freezed_annotation.dart';
import 'setup_preset.dart';

part 'setup_payload.freezed.dart';
part 'setup_payload.g.dart';

@freezed
class SetupPayload with _$SetupPayload {
  const factory SetupPayload({
    @Default('') String name,
    @JsonKey(name: 'aero_dynamic') @Default(0) int aeroDynamic,
    @Default(0) int engine,
    @Default(0) int chassis,
    @Default(0) int floor,
    @Default(0) int tyres,
    @Default(0) int reliability,
    @JsonKey(name: 'settings_angle') @Default(0) int settingsAngle,
  }) = _SetupPayload;
  factory SetupPayload.fromJson(Map<String, dynamic> json) => _$SetupPayloadFromJson(json);

  factory SetupPayload.fromPreset(SetupPreset p, {String name = ''}) => SetupPayload(
        name: name.isEmpty ? p.name : name,
        aeroDynamic: p.aeroDynamic,
        engine: p.engine,
        chassis: p.chassis,
        floor: p.floor,
        tyres: p.tyres,
        reliability: p.reliability,
        settingsAngle: p.settingsAngle,
      );
}
