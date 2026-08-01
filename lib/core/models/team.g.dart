// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamImpl _$$TeamImplFromJson(Map<String, dynamic> json) => _$TeamImpl(
  id: (json['ID'] as num).toInt(),
  name: json['Name'] as String,
  ice: (json['ICE'] as num?)?.toInt() ?? 0,
  carLevel: (json['CarLevel'] as num?)?.toInt() ?? 0,
  baseLevel: (json['BaseLevel'] as num?)?.toInt() ?? 0,
  engineer: (json['Engineer'] as num?)?.toInt() ?? 0,
  simLevel: (json['SimLevel'] as num?)?.toInt() ?? 0,
  tubeLevel: (json['TubeLevel'] as num?)?.toInt() ?? 0,
  updateRating: (json['UpdateRating'] as num?)?.toInt() ?? 0,
  tokens: (json['Tokens'] as num?)?.toInt() ?? 0,
  budget: (json['Budget'] as num?)?.toInt() ?? 0,
  isManufacturer: (json['IsManufacturer'] as num?)?.toInt() ?? 0,
  carSettings: (json['CarSettings'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$TeamImplToJson(_$TeamImpl instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'ICE': instance.ice,
      'CarLevel': instance.carLevel,
      'BaseLevel': instance.baseLevel,
      'Engineer': instance.engineer,
      'SimLevel': instance.simLevel,
      'TubeLevel': instance.tubeLevel,
      'UpdateRating': instance.updateRating,
      'Tokens': instance.tokens,
      'Budget': instance.budget,
      'IsManufacturer': instance.isManufacturer,
      'CarSettings': instance.carSettings,
    };
