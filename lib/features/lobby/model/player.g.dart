// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
  id: (json['ID'] as num).toInt(),
  name: json['Name'] as String,
  teamPrincipal: (json['TeamPrincipal'] as num?)?.toInt(),
  team: (json['Team'] as num?)?.toInt() ?? 0,
  budget: (json['Budget'] as num?)?.toInt() ?? 0,
  tokens: (json['Tokens'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'TeamPrincipal': instance.teamPrincipal,
      'Team': instance.team,
      'Budget': instance.budget,
      'Tokens': instance.tokens,
    };
