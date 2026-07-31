// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackInfoImpl _$$TrackInfoImplFromJson(Map<String, dynamic> json) =>
    _$TrackInfoImpl(
      id: (json['ID'] as num).toInt(),
      name: json['Name'] as String,
      downForceLevel: (json['DownForceLevel'] as num?)?.toInt() ?? 0,
      type: (json['Type'] as num?)?.toInt() ?? 0,
      difficulty: (json['Difficulty'] as num?)?.toInt() ?? 0,
      qualifyingImpact: (json['QualifyingImpact'] as num?)?.toInt() ?? 0,
      rainPossibility: (json['RainPossibility'] as num?)?.toInt() ?? 0,
      tyre: (json['Tyre'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TrackInfoImplToJson(_$TrackInfoImpl instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'DownForceLevel': instance.downForceLevel,
      'Type': instance.type,
      'Difficulty': instance.difficulty,
      'QualifyingImpact': instance.qualifyingImpact,
      'RainPossibility': instance.rainPossibility,
      'Tyre': instance.tyre,
    };
