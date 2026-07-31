// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetupPresetImpl _$$SetupPresetImplFromJson(Map<String, dynamic> json) =>
    _$SetupPresetImpl(
      name: json['name'] as String,
      aeroDynamic: (json['aeroDynamic'] as num?)?.toInt() ?? 0,
      engine: (json['engine'] as num?)?.toInt() ?? 0,
      chassis: (json['chassis'] as num?)?.toInt() ?? 0,
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      tyres: (json['tyres'] as num?)?.toInt() ?? 0,
      reliability: (json['reliability'] as num?)?.toInt() ?? 0,
      settingsAngle: (json['settingsAngle'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SetupPresetImplToJson(_$SetupPresetImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'aeroDynamic': instance.aeroDynamic,
      'engine': instance.engine,
      'chassis': instance.chassis,
      'floor': instance.floor,
      'tyres': instance.tyres,
      'reliability': instance.reliability,
      'settingsAngle': instance.settingsAngle,
    };
