// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StandingImpl _$$StandingImplFromJson(Map<String, dynamic> json) =>
    _$StandingImpl(
      drivers:
          (json['drivers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      teams:
          (json['teams'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
    );

Map<String, dynamic> _$$StandingImplToJson(_$StandingImpl instance) =>
    <String, dynamic>{'drivers': instance.drivers, 'teams': instance.teams};
