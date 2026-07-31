import 'package:freezed_annotation/freezed_annotation.dart';

part 'setup_preset.freezed.dart';
part 'setup_preset.g.dart';

@freezed
class SetupPreset with _$SetupPreset {
  const factory SetupPreset({
    required String name,
    @Default(0) int aeroDynamic,
    @Default(0) int engine,
    @Default(0) int chassis,
    @Default(0) int floor,
    @Default(0) int tyres,
    @Default(0) int reliability,
    @Default(0) int settingsAngle,
  }) = _SetupPreset;

  factory SetupPreset.fromJson(Map<String, dynamic> json) =>
      _$SetupPresetFromJson(json);
}
