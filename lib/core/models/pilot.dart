import 'package:freezed_annotation/freezed_annotation.dart';

part 'pilot.freezed.dart';
part 'pilot.g.dart';

@freezed
class Pilot with _$Pilot {
  const factory Pilot({
    @JsonKey(name: 'ID') required int id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'Garage') int? garage,
    @JsonKey(name: 'Team') int? team,
    @JsonKey(name: 'Rating') @Default(0) int rating,
    @JsonKey(name: 'QualifyingRating') @Default(0) int qualifyingRating,
    @JsonKey(name: 'DrivingStyle') @Default(0) int drivingStyle,
    @JsonKey(name: 'Experience') @Default(0) int experience,
    @JsonKey(name: 'Adaptiveness') @Default(0) int adaptiveness,
    @JsonKey(name: 'Emotions') @Default(0) int emotions,
    @JsonKey(name: 'Stability') @Default(0) int stability,
    @JsonKey(name: 'Rain') @Default(0) int rain,
    @JsonKey(name: 'SettingsAngle') @Default(0) int settingsAngle,
    @JsonKey(name: 'Starting') @Default(0) int starting,
    @JsonKey(name: 'TyreManagement') @Default(0) int tyreManagement,
    @JsonKey(name: 'MistakePossibility') @Default(0) int mistakePossibility,
    @JsonKey(name: 'Price') @Default(0) int price,
    @JsonKey(name: 'Sponsors') @Default(0) int sponsors,
    @JsonKey(name: 'CarFit') @Default(0) int carFit,
  }) = _Pilot;
  factory Pilot.fromJson(Map<String, dynamic> json) => _$PilotFromJson(json);
}
