// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceResultImpl _$$RaceResultImplFromJson(Map<String, dynamic> json) =>
    _$RaceResultImpl(
      pilotId: (json['pilot_id'] as num?)?.toInt() ?? 0,
      garageId: (json['garage_id'] as num?)?.toInt() ?? 0,
      pilotName: json['pilot_name'] as String? ?? '',
      teamName: json['team_name'] as String? ?? '',
      qualiPosition: (json['quali_position'] as num?)?.toInt() ?? 0,
      racePosition: (json['race_position'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      isDnf: json['is_dnf'] as bool? ?? false,
      dnfReason: json['dnf_reason'] as String? ?? '',
    );

Map<String, dynamic> _$$RaceResultImplToJson(_$RaceResultImpl instance) =>
    <String, dynamic>{
      'pilot_id': instance.pilotId,
      'garage_id': instance.garageId,
      'pilot_name': instance.pilotName,
      'team_name': instance.teamName,
      'quali_position': instance.qualiPosition,
      'race_position': instance.racePosition,
      'points': instance.points,
      'is_dnf': instance.isDnf,
      'dnf_reason': instance.dnfReason,
    };

_$RaceResultResponseImpl _$$RaceResultResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RaceResultResponseImpl(
  stage: (json['stage'] as num?)?.toInt() ?? 0,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => RaceResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RaceResult>[],
);

Map<String, dynamic> _$$RaceResultResponseImplToJson(
  _$RaceResultResponseImpl instance,
) => <String, dynamic>{'stage': instance.stage, 'results': instance.results};
