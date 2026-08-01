// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Engine _$EngineFromJson(Map<String, dynamic> json) {
  return _Engine.fromJson(json);
}

/// @nodoc
mixin _$Engine {
  @JsonKey(name: 'ID')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Engine')
  int get engine => throw _privateConstructorUsedError;
  @JsonKey(name: 'Price')
  int get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'BaseLevel')
  int get baseLevel => throw _privateConstructorUsedError;

  /// Serializes this Engine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Engine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EngineCopyWith<Engine> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EngineCopyWith<$Res> {
  factory $EngineCopyWith(Engine value, $Res Function(Engine) then) =
      _$EngineCopyWithImpl<$Res, Engine>;
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Engine') int engine,
    @JsonKey(name: 'Price') int price,
    @JsonKey(name: 'BaseLevel') int baseLevel,
  });
}

/// @nodoc
class _$EngineCopyWithImpl<$Res, $Val extends Engine>
    implements $EngineCopyWith<$Res> {
  _$EngineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Engine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? engine = null,
    Object? price = null,
    Object? baseLevel = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            engine: null == engine
                ? _value.engine
                : engine // ignore: cast_nullable_to_non_nullable
                      as int,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int,
            baseLevel: null == baseLevel
                ? _value.baseLevel
                : baseLevel // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EngineImplCopyWith<$Res> implements $EngineCopyWith<$Res> {
  factory _$$EngineImplCopyWith(
    _$EngineImpl value,
    $Res Function(_$EngineImpl) then,
  ) = __$$EngineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Engine') int engine,
    @JsonKey(name: 'Price') int price,
    @JsonKey(name: 'BaseLevel') int baseLevel,
  });
}

/// @nodoc
class __$$EngineImplCopyWithImpl<$Res>
    extends _$EngineCopyWithImpl<$Res, _$EngineImpl>
    implements _$$EngineImplCopyWith<$Res> {
  __$$EngineImplCopyWithImpl(
    _$EngineImpl _value,
    $Res Function(_$EngineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Engine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? engine = null,
    Object? price = null,
    Object? baseLevel = null,
  }) {
    return _then(
      _$EngineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        engine: null == engine
            ? _value.engine
            : engine // ignore: cast_nullable_to_non_nullable
                  as int,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int,
        baseLevel: null == baseLevel
            ? _value.baseLevel
            : baseLevel // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EngineImpl implements _Engine {
  const _$EngineImpl({
    @JsonKey(name: 'ID') required this.id,
    @JsonKey(name: 'Engine') this.engine = 0,
    @JsonKey(name: 'Price') this.price = 0,
    @JsonKey(name: 'BaseLevel') this.baseLevel = 0,
  });

  factory _$EngineImpl.fromJson(Map<String, dynamic> json) =>
      _$$EngineImplFromJson(json);

  @override
  @JsonKey(name: 'ID')
  final int id;
  @override
  @JsonKey(name: 'Engine')
  final int engine;
  @override
  @JsonKey(name: 'Price')
  final int price;
  @override
  @JsonKey(name: 'BaseLevel')
  final int baseLevel;

  @override
  String toString() {
    return 'Engine(id: $id, engine: $engine, price: $price, baseLevel: $baseLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EngineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.engine, engine) || other.engine == engine) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.baseLevel, baseLevel) ||
                other.baseLevel == baseLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, engine, price, baseLevel);

  /// Create a copy of Engine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EngineImplCopyWith<_$EngineImpl> get copyWith =>
      __$$EngineImplCopyWithImpl<_$EngineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EngineImplToJson(this);
  }
}

abstract class _Engine implements Engine {
  const factory _Engine({
    @JsonKey(name: 'ID') required final int id,
    @JsonKey(name: 'Engine') final int engine,
    @JsonKey(name: 'Price') final int price,
    @JsonKey(name: 'BaseLevel') final int baseLevel,
  }) = _$EngineImpl;

  factory _Engine.fromJson(Map<String, dynamic> json) = _$EngineImpl.fromJson;

  @override
  @JsonKey(name: 'ID')
  int get id;
  @override
  @JsonKey(name: 'Engine')
  int get engine;
  @override
  @JsonKey(name: 'Price')
  int get price;
  @override
  @JsonKey(name: 'BaseLevel')
  int get baseLevel;

  /// Create a copy of Engine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EngineImplCopyWith<_$EngineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
