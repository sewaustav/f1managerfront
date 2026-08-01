// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonStateImpl _$$SeasonStateImplFromJson(Map<String, dynamic> json) =>
    _$SeasonStateImpl(
      phase: $enumDecode(
        _$SeasonPhaseEnumMap,
        json['phase'],
        unknownValue: SeasonPhase.unknown,
      ),
      stage: (json['stage'] as num?)?.toInt() ?? 0,
      submittedSetups:
          (json['submitted_setups'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      totalPlayers: (json['total_players'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SeasonStateImplToJson(_$SeasonStateImpl instance) =>
    <String, dynamic>{
      'phase': _$SeasonPhaseEnumMap[instance.phase]!,
      'stage': instance.stage,
      'submitted_setups': instance.submittedSetups,
      'total_players': instance.totalPlayers,
    };

const _$SeasonPhaseEnumMap = {
  SeasonPhase.draft: 'draft',
  SeasonPhase.tokenSetup: 'token_setup',
  SeasonPhase.racing: 'racing',
  SeasonPhase.interSeason: 'inter_season',
  SeasonPhase.unknown: 'unknown',
};
