// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'principal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Principal _$PrincipalFromJson(Map<String, dynamic> json) {
  return _Principal.fromJson(json);
}

/// @nodoc
mixin _$Principal {
  @JsonKey(name: 'ID')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Price')
  int get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'TeamID')
  int get teamId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Level')
  int get level => throw _privateConstructorUsedError;

  /// Serializes this Principal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Principal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrincipalCopyWith<Principal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrincipalCopyWith<$Res> {
  factory $PrincipalCopyWith(Principal value, $Res Function(Principal) then) =
      _$PrincipalCopyWithImpl<$Res, Principal>;
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Price') int price,
    @JsonKey(name: 'TeamID') int teamId,
    @JsonKey(name: 'Level') int level,
  });
}

/// @nodoc
class _$PrincipalCopyWithImpl<$Res, $Val extends Principal>
    implements $PrincipalCopyWith<$Res> {
  _$PrincipalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Principal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? teamId = null,
    Object? level = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int,
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrincipalImplCopyWith<$Res>
    implements $PrincipalCopyWith<$Res> {
  factory _$$PrincipalImplCopyWith(
    _$PrincipalImpl value,
    $Res Function(_$PrincipalImpl) then,
  ) = __$$PrincipalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Price') int price,
    @JsonKey(name: 'TeamID') int teamId,
    @JsonKey(name: 'Level') int level,
  });
}

/// @nodoc
class __$$PrincipalImplCopyWithImpl<$Res>
    extends _$PrincipalCopyWithImpl<$Res, _$PrincipalImpl>
    implements _$$PrincipalImplCopyWith<$Res> {
  __$$PrincipalImplCopyWithImpl(
    _$PrincipalImpl _value,
    $Res Function(_$PrincipalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Principal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? teamId = null,
    Object? level = null,
  }) {
    return _then(
      _$PrincipalImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int,
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrincipalImpl implements _Principal {
  const _$PrincipalImpl({
    @JsonKey(name: 'ID') required this.id,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'Price') this.price = 0,
    @JsonKey(name: 'TeamID') this.teamId = 0,
    @JsonKey(name: 'Level') this.level = 0,
  });

  factory _$PrincipalImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrincipalImplFromJson(json);

  @override
  @JsonKey(name: 'ID')
  final int id;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'Price')
  final int price;
  @override
  @JsonKey(name: 'TeamID')
  final int teamId;
  @override
  @JsonKey(name: 'Level')
  final int level;

  @override
  String toString() {
    return 'Principal(id: $id, name: $name, price: $price, teamId: $teamId, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrincipalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, price, teamId, level);

  /// Create a copy of Principal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrincipalImplCopyWith<_$PrincipalImpl> get copyWith =>
      __$$PrincipalImplCopyWithImpl<_$PrincipalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrincipalImplToJson(this);
  }
}

abstract class _Principal implements Principal {
  const factory _Principal({
    @JsonKey(name: 'ID') required final int id,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'Price') final int price,
    @JsonKey(name: 'TeamID') final int teamId,
    @JsonKey(name: 'Level') final int level,
  }) = _$PrincipalImpl;

  factory _Principal.fromJson(Map<String, dynamic> json) =
      _$PrincipalImpl.fromJson;

  @override
  @JsonKey(name: 'ID')
  int get id;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'Price')
  int get price;
  @override
  @JsonKey(name: 'TeamID')
  int get teamId;
  @override
  @JsonKey(name: 'Level')
  int get level;

  /// Create a copy of Principal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrincipalImplCopyWith<_$PrincipalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
