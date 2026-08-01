// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pilot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PilotImpl _$$PilotImplFromJson(Map<String, dynamic> json) => _$PilotImpl(
  id: (json['ID'] as num).toInt(),
  name: json['Name'] as String,
  garage: (json['Garage'] as num?)?.toInt(),
  team: (json['Team'] as num?)?.toInt(),
  rating: (json['Rating'] as num?)?.toInt() ?? 0,
  qualifyingRating: (json['QualifyingRating'] as num?)?.toInt() ?? 0,
  drivingStyle: (json['DrivingStyle'] as num?)?.toInt() ?? 0,
  experience: (json['Experience'] as num?)?.toInt() ?? 0,
  adaptiveness: (json['Adaptiveness'] as num?)?.toInt() ?? 0,
  emotions: (json['Emotions'] as num?)?.toInt() ?? 0,
  stability: (json['Stability'] as num?)?.toInt() ?? 0,
  rain: (json['Rain'] as num?)?.toInt() ?? 0,
  settingsAngle: (json['SettingsAngle'] as num?)?.toInt() ?? 0,
  starting: (json['Starting'] as num?)?.toInt() ?? 0,
  tyreManagement: (json['TyreManagement'] as num?)?.toInt() ?? 0,
  mistakePossibility: (json['MistakePossibility'] as num?)?.toInt() ?? 0,
  price: (json['Price'] as num?)?.toInt() ?? 0,
  sponsors: (json['Sponsors'] as num?)?.toInt() ?? 0,
  carFit: (json['CarFit'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PilotImplToJson(_$PilotImpl instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Garage': instance.garage,
      'Team': instance.team,
      'Rating': instance.rating,
      'QualifyingRating': instance.qualifyingRating,
      'DrivingStyle': instance.drivingStyle,
      'Experience': instance.experience,
      'Adaptiveness': instance.adaptiveness,
      'Emotions': instance.emotions,
      'Stability': instance.stability,
      'Rain': instance.rain,
      'SettingsAngle': instance.settingsAngle,
      'Starting': instance.starting,
      'TyreManagement': instance.tyreManagement,
      'MistakePossibility': instance.mistakePossibility,
      'Price': instance.price,
      'Sponsors': instance.sponsors,
      'CarFit': instance.carFit,
    };
