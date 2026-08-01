// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'standing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Standing _$StandingFromJson(Map<String, dynamic> json) {
  return _Standing.fromJson(json);
}

/// @nodoc
mixin _$Standing {
  Map<String, int> get drivers => throw _privateConstructorUsedError;
  Map<String, int> get teams => throw _privateConstructorUsedError;

  /// Serializes this Standing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StandingCopyWith<Standing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StandingCopyWith<$Res> {
  factory $StandingCopyWith(Standing value, $Res Function(Standing) then) =
      _$StandingCopyWithImpl<$Res, Standing>;
  @useResult
  $Res call({Map<String, int> drivers, Map<String, int> teams});
}

/// @nodoc
class _$StandingCopyWithImpl<$Res, $Val extends Standing>
    implements $StandingCopyWith<$Res> {
  _$StandingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? drivers = null, Object? teams = null}) {
    return _then(
      _value.copyWith(
            drivers: null == drivers
                ? _value.drivers
                : drivers // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            teams: null == teams
                ? _value.teams
                : teams // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StandingImplCopyWith<$Res>
    implements $StandingCopyWith<$Res> {
  factory _$$StandingImplCopyWith(
    _$StandingImpl value,
    $Res Function(_$StandingImpl) then,
  ) = __$$StandingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, int> drivers, Map<String, int> teams});
}

/// @nodoc
class __$$StandingImplCopyWithImpl<$Res>
    extends _$StandingCopyWithImpl<$Res, _$StandingImpl>
    implements _$$StandingImplCopyWith<$Res> {
  __$$StandingImplCopyWithImpl(
    _$StandingImpl _value,
    $Res Function(_$StandingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? drivers = null, Object? teams = null}) {
    return _then(
      _$StandingImpl(
        drivers: null == drivers
            ? _value._drivers
            : drivers // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        teams: null == teams
            ? _value._teams
            : teams // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StandingImpl implements _Standing {
  const _$StandingImpl({
    final Map<String, int> drivers = const <String, int>{},
    final Map<String, int> teams = const <String, int>{},
  }) : _drivers = drivers,
       _teams = teams;

  factory _$StandingImpl.fromJson(Map<String, dynamic> json) =>
      _$$StandingImplFromJson(json);

  final Map<String, int> _drivers;
  @override
  @JsonKey()
  Map<String, int> get drivers {
    if (_drivers is EqualUnmodifiableMapView) return _drivers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_drivers);
  }

  final Map<String, int> _teams;
  @override
  @JsonKey()
  Map<String, int> get teams {
    if (_teams is EqualUnmodifiableMapView) return _teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_teams);
  }

  @override
  String toString() {
    return 'Standing(drivers: $drivers, teams: $teams)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StandingImpl &&
            const DeepCollectionEquality().equals(other._drivers, _drivers) &&
            const DeepCollectionEquality().equals(other._teams, _teams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_drivers),
    const DeepCollectionEquality().hash(_teams),
  );

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StandingImplCopyWith<_$StandingImpl> get copyWith =>
      __$$StandingImplCopyWithImpl<_$StandingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StandingImplToJson(this);
  }
}

abstract class _Standing implements Standing {
  const factory _Standing({
    final Map<String, int> drivers,
    final Map<String, int> teams,
  }) = _$StandingImpl;

  factory _Standing.fromJson(Map<String, dynamic> json) =
      _$StandingImpl.fromJson;

  @override
  Map<String, int> get drivers;
  @override
  Map<String, int> get teams;

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StandingImplCopyWith<_$StandingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
