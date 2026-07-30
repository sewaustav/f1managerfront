// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateGroupRequestImpl _$$CreateGroupRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateGroupRequestImpl(
  name: json['name'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$CreateGroupRequestImplToJson(
  _$CreateGroupRequestImpl instance,
) => <String, dynamic>{'name': instance.name, 'password': instance.password};

_$JoinGroupRequestImpl _$$JoinGroupRequestImplFromJson(
  Map<String, dynamic> json,
) => _$JoinGroupRequestImpl(
  id: (json['id'] as num).toInt(),
  password: json['password'] as String,
);

Map<String, dynamic> _$$JoinGroupRequestImplToJson(
  _$JoinGroupRequestImpl instance,
) => <String, dynamic>{'id': instance.id, 'password': instance.password};
