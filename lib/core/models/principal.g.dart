// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'principal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrincipalImpl _$$PrincipalImplFromJson(Map<String, dynamic> json) =>
    _$PrincipalImpl(
      id: (json['ID'] as num).toInt(),
      name: json['Name'] as String,
      price: (json['Price'] as num?)?.toInt() ?? 0,
      teamId: (json['TeamID'] as num?)?.toInt() ?? 0,
      level: (json['Level'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PrincipalImplToJson(_$PrincipalImpl instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Price': instance.price,
      'TeamID': instance.teamId,
      'Level': instance.level,
    };
