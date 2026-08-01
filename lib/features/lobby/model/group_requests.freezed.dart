// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_requests.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateGroupRequest _$CreateGroupRequestFromJson(Map<String, dynamic> json) {
  return _CreateGroupRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateGroupRequest {
  String get name => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this CreateGroupRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateGroupRequestCopyWith<CreateGroupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateGroupRequestCopyWith<$Res> {
  factory $CreateGroupRequestCopyWith(
    CreateGroupRequest value,
    $Res Function(CreateGroupRequest) then,
  ) = _$CreateGroupRequestCopyWithImpl<$Res, CreateGroupRequest>;
  @useResult
  $Res call({String name, String password});
}

/// @nodoc
class _$CreateGroupRequestCopyWithImpl<$Res, $Val extends CreateGroupRequest>
    implements $CreateGroupRequestCopyWith<$Res> {
  _$CreateGroupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateGroupRequestImplCopyWith<$Res>
    implements $CreateGroupRequestCopyWith<$Res> {
  factory _$$CreateGroupRequestImplCopyWith(
    _$CreateGroupRequestImpl value,
    $Res Function(_$CreateGroupRequestImpl) then,
  ) = __$$CreateGroupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String password});
}

/// @nodoc
class __$$CreateGroupRequestImplCopyWithImpl<$Res>
    extends _$CreateGroupRequestCopyWithImpl<$Res, _$CreateGroupRequestImpl>
    implements _$$CreateGroupRequestImplCopyWith<$Res> {
  __$$CreateGroupRequestImplCopyWithImpl(
    _$CreateGroupRequestImpl _value,
    $Res Function(_$CreateGroupRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? password = null}) {
    return _then(
      _$CreateGroupRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateGroupRequestImpl implements _CreateGroupRequest {
  const _$CreateGroupRequestImpl({required this.name, required this.password});

  factory _$CreateGroupRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateGroupRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String password;

  @override
  String toString() {
    return 'CreateGroupRequest(name: $name, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateGroupRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, password);

  /// Create a copy of CreateGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateGroupRequestImplCopyWith<_$CreateGroupRequestImpl> get copyWith =>
      __$$CreateGroupRequestImplCopyWithImpl<_$CreateGroupRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateGroupRequestImplToJson(this);
  }
}

abstract class _CreateGroupRequest implements CreateGroupRequest {
  const factory _CreateGroupRequest({
    required final String name,
    required final String password,
  }) = _$CreateGroupRequestImpl;

  factory _CreateGroupRequest.fromJson(Map<String, dynamic> json) =
      _$CreateGroupRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get password;

  /// Create a copy of CreateGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateGroupRequestImplCopyWith<_$CreateGroupRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JoinGroupRequest _$JoinGroupRequestFromJson(Map<String, dynamic> json) {
  return _JoinGroupRequest.fromJson(json);
}

/// @nodoc
mixin _$JoinGroupRequest {
  int get id => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this JoinGroupRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JoinGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JoinGroupRequestCopyWith<JoinGroupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JoinGroupRequestCopyWith<$Res> {
  factory $JoinGroupRequestCopyWith(
    JoinGroupRequest value,
    $Res Function(JoinGroupRequest) then,
  ) = _$JoinGroupRequestCopyWithImpl<$Res, JoinGroupRequest>;
  @useResult
  $Res call({int id, String password});
}

/// @nodoc
class _$JoinGroupRequestCopyWithImpl<$Res, $Val extends JoinGroupRequest>
    implements $JoinGroupRequestCopyWith<$Res> {
  _$JoinGroupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JoinGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JoinGroupRequestImplCopyWith<$Res>
    implements $JoinGroupRequestCopyWith<$Res> {
  factory _$$JoinGroupRequestImplCopyWith(
    _$JoinGroupRequestImpl value,
    $Res Function(_$JoinGroupRequestImpl) then,
  ) = __$$JoinGroupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String password});
}

/// @nodoc
class __$$JoinGroupRequestImplCopyWithImpl<$Res>
    extends _$JoinGroupRequestCopyWithImpl<$Res, _$JoinGroupRequestImpl>
    implements _$$JoinGroupRequestImplCopyWith<$Res> {
  __$$JoinGroupRequestImplCopyWithImpl(
    _$JoinGroupRequestImpl _value,
    $Res Function(_$JoinGroupRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JoinGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? password = null}) {
    return _then(
      _$JoinGroupRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JoinGroupRequestImpl implements _JoinGroupRequest {
  const _$JoinGroupRequestImpl({required this.id, required this.password});

  factory _$JoinGroupRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$JoinGroupRequestImplFromJson(json);

  @override
  final int id;
  @override
  final String password;

  @override
  String toString() {
    return 'JoinGroupRequest(id: $id, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinGroupRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, password);

  /// Create a copy of JoinGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinGroupRequestImplCopyWith<_$JoinGroupRequestImpl> get copyWith =>
      __$$JoinGroupRequestImplCopyWithImpl<_$JoinGroupRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JoinGroupRequestImplToJson(this);
  }
}

abstract class _JoinGroupRequest implements JoinGroupRequest {
  const factory _JoinGroupRequest({
    required final int id,
    required final String password,
  }) = _$JoinGroupRequestImpl;

  factory _JoinGroupRequest.fromJson(Map<String, dynamic> json) =
      _$JoinGroupRequestImpl.fromJson;

  @override
  int get id;
  @override
  String get password;

  /// Create a copy of JoinGroupRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinGroupRequestImplCopyWith<_$JoinGroupRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
