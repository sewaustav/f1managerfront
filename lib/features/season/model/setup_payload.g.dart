// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetupPayloadImpl _$$SetupPayloadImplFromJson(Map<String, dynamic> json) =>
    _$SetupPayloadImpl(
      name: json['name'] as String? ?? '',
      aeroDynamic: (json['aero_dynamic'] as num?)?.toInt() ?? 0,
      engine: (json['engine'] as num?)?.toInt() ?? 0,
      chassis: (json['chassis'] as num?)?.toInt() ?? 0,
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      tyres: (json['tyres'] as num?)?.toInt() ?? 0,
      reliability: (json['reliability'] as num?)?.toInt() ?? 0,
      settingsAngle: (json['settings_angle'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SetupPayloadImplToJson(_$SetupPayloadImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'aero_dynamic': instance.aeroDynamic,
      'engine': instance.engine,
      'chassis': instance.chassis,
      'floor': instance.floor,
      'tyres': instance.tyres,
      'reliability': instance.reliability,
      'settings_angle': instance.settingsAngle,
    };
