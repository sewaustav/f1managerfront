// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrackInfo _$TrackInfoFromJson(Map<String, dynamic> json) {
  return _TrackInfo.fromJson(json);
}

/// @nodoc
mixin _$TrackInfo {
  @JsonKey(name: 'ID')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'DownForceLevel')
  int get downForceLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'Type')
  int get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'Difficulty')
  int get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'QualifyingImpact')
  int get qualifyingImpact => throw _privateConstructorUsedError;
  @JsonKey(name: 'RainPossibility')
  int get rainPossibility => throw _privateConstructorUsedError;
  @JsonKey(name: 'Tyre')
  int get tyre => throw _privateConstructorUsedError;

  /// Serializes this TrackInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackInfoCopyWith<TrackInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackInfoCopyWith<$Res> {
  factory $TrackInfoCopyWith(TrackInfo value, $Res Function(TrackInfo) then) =
      _$TrackInfoCopyWithImpl<$Res, TrackInfo>;
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DownForceLevel') int downForceLevel,
    @JsonKey(name: 'Type') int type,
    @JsonKey(name: 'Difficulty') int difficulty,
    @JsonKey(name: 'QualifyingImpact') int qualifyingImpact,
    @JsonKey(name: 'RainPossibility') int rainPossibility,
    @JsonKey(name: 'Tyre') int tyre,
  });
}

/// @nodoc
class _$TrackInfoCopyWithImpl<$Res, $Val extends TrackInfo>
    implements $TrackInfoCopyWith<$Res> {
  _$TrackInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? downForceLevel = null,
    Object? type = null,
    Object? difficulty = null,
    Object? qualifyingImpact = null,
    Object? rainPossibility = null,
    Object? tyre = null,
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
            downForceLevel: null == downForceLevel
                ? _value.downForceLevel
                : downForceLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as int,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as int,
            qualifyingImpact: null == qualifyingImpact
                ? _value.qualifyingImpact
                : qualifyingImpact // ignore: cast_nullable_to_non_nullable
                      as int,
            rainPossibility: null == rainPossibility
                ? _value.rainPossibility
                : rainPossibility // ignore: cast_nullable_to_non_nullable
                      as int,
            tyre: null == tyre
                ? _value.tyre
                : tyre // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrackInfoImplCopyWith<$Res>
    implements $TrackInfoCopyWith<$Res> {
  factory _$$TrackInfoImplCopyWith(
    _$TrackInfoImpl value,
    $Res Function(_$TrackInfoImpl) then,
  ) = __$$TrackInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DownForceLevel') int downForceLevel,
    @JsonKey(name: 'Type') int type,
    @JsonKey(name: 'Difficulty') int difficulty,
    @JsonKey(name: 'QualifyingImpact') int qualifyingImpact,
    @JsonKey(name: 'RainPossibility') int rainPossibility,
    @JsonKey(name: 'Tyre') int tyre,
  });
}

/// @nodoc
class __$$TrackInfoImplCopyWithImpl<$Res>
    extends _$TrackInfoCopyWithImpl<$Res, _$TrackInfoImpl>
    implements _$$TrackInfoImplCopyWith<$Res> {
  __$$TrackInfoImplCopyWithImpl(
    _$TrackInfoImpl _value,
    $Res Function(_$TrackInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrackInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? downForceLevel = null,
    Object? type = null,
    Object? difficulty = null,
    Object? qualifyingImpact = null,
    Object? rainPossibility = null,
    Object? tyre = null,
  }) {
    return _then(
      _$TrackInfoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        downForceLevel: null == downForceLevel
            ? _value.downForceLevel
            : downForceLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as int,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as int,
        qualifyingImpact: null == qualifyingImpact
            ? _value.qualifyingImpact
            : qualifyingImpact // ignore: cast_nullable_to_non_nullable
                  as int,
        rainPossibility: null == rainPossibility
            ? _value.rainPossibility
            : rainPossibility // ignore: cast_nullable_to_non_nullable
                  as int,
        tyre: null == tyre
            ? _value.tyre
            : tyre // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackInfoImpl implements _TrackInfo {
  const _$TrackInfoImpl({
    @JsonKey(name: 'ID') required this.id,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'DownForceLevel') this.downForceLevel = 0,
    @JsonKey(name: 'Type') this.type = 0,
    @JsonKey(name: 'Difficulty') this.difficulty = 0,
    @JsonKey(name: 'QualifyingImpact') this.qualifyingImpact = 0,
    @JsonKey(name: 'RainPossibility') this.rainPossibility = 0,
    @JsonKey(name: 'Tyre') this.tyre = 0,
  });

  factory _$TrackInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackInfoImplFromJson(json);

  @override
  @JsonKey(name: 'ID')
  final int id;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'DownForceLevel')
  final int downForceLevel;
  @override
  @JsonKey(name: 'Type')
  final int type;
  @override
  @JsonKey(name: 'Difficulty')
  final int difficulty;
  @override
  @JsonKey(name: 'QualifyingImpact')
  final int qualifyingImpact;
  @override
  @JsonKey(name: 'RainPossibility')
  final int rainPossibility;
  @override
  @JsonKey(name: 'Tyre')
  final int tyre;

  @override
  String toString() {
    return 'TrackInfo(id: $id, name: $name, downForceLevel: $downForceLevel, type: $type, difficulty: $difficulty, qualifyingImpact: $qualifyingImpact, rainPossibility: $rainPossibility, tyre: $tyre)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.downForceLevel, downForceLevel) ||
                other.downForceLevel == downForceLevel) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.qualifyingImpact, qualifyingImpact) ||
                other.qualifyingImpact == qualifyingImpact) &&
            (identical(other.rainPossibility, rainPossibility) ||
                other.rainPossibility == rainPossibility) &&
            (identical(other.tyre, tyre) || other.tyre == tyre));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    downForceLevel,
    type,
    difficulty,
    qualifyingImpact,
    rainPossibility,
    tyre,
  );

  /// Create a copy of TrackInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackInfoImplCopyWith<_$TrackInfoImpl> get copyWith =>
      __$$TrackInfoImplCopyWithImpl<_$TrackInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackInfoImplToJson(this);
  }
}

abstract class _TrackInfo implements TrackInfo {
  const factory _TrackInfo({
    @JsonKey(name: 'ID') required final int id,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'DownForceLevel') final int downForceLevel,
    @JsonKey(name: 'Type') final int type,
    @JsonKey(name: 'Difficulty') final int difficulty,
    @JsonKey(name: 'QualifyingImpact') final int qualifyingImpact,
    @JsonKey(name: 'RainPossibility') final int rainPossibility,
    @JsonKey(name: 'Tyre') final int tyre,
  }) = _$TrackInfoImpl;

  factory _TrackInfo.fromJson(Map<String, dynamic> json) =
      _$TrackInfoImpl.fromJson;

  @override
  @JsonKey(name: 'ID')
  int get id;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'DownForceLevel')
  int get downForceLevel;
  @override
  @JsonKey(name: 'Type')
  int get type;
  @override
  @JsonKey(name: 'Difficulty')
  int get difficulty;
  @override
  @JsonKey(name: 'QualifyingImpact')
  int get qualifyingImpact;
  @override
  @JsonKey(name: 'RainPossibility')
  int get rainPossibility;
  @override
  @JsonKey(name: 'Tyre')
  int get tyre;

  /// Create a copy of TrackInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackInfoImplCopyWith<_$TrackInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
