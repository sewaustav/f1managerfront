// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EngineImpl _$$EngineImplFromJson(Map<String, dynamic> json) => _$EngineImpl(
  id: (json['ID'] as num).toInt(),
  engine: (json['Engine'] as num?)?.toInt() ?? 0,
  price: (json['Price'] as num?)?.toInt() ?? 0,
  baseLevel: (json['BaseLevel'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$EngineImplToJson(_$EngineImpl instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'Engine': instance.engine,
      'Price': instance.price,
      'BaseLevel': instance.baseLevel,
    };
