// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SeasonState _$SeasonStateFromJson(Map<String, dynamic> json) {
  return _SeasonState.fromJson(json);
}

/// @nodoc
mixin _$SeasonState {
  @JsonKey(unknownEnumValue: SeasonPhase.unknown)
  SeasonPhase get phase => throw _privateConstructorUsedError;
  int get stage => throw _privateConstructorUsedError;
  @JsonKey(name: 'submitted_setups')
  List<int> get submittedSetups => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_players')
  int get totalPlayers => throw _privateConstructorUsedError;

  /// Serializes this SeasonState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonStateCopyWith<SeasonState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonStateCopyWith<$Res> {
  factory $SeasonStateCopyWith(
    SeasonState value,
    $Res Function(SeasonState) then,
  ) = _$SeasonStateCopyWithImpl<$Res, SeasonState>;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: SeasonPhase.unknown) SeasonPhase phase,
    int stage,
    @JsonKey(name: 'submitted_setups') List<int> submittedSetups,
    @JsonKey(name: 'total_players') int totalPlayers,
  });
}

/// @nodoc
class _$SeasonStateCopyWithImpl<$Res, $Val extends SeasonState>
    implements $SeasonStateCopyWith<$Res> {
  _$SeasonStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? stage = null,
    Object? submittedSetups = null,
    Object? totalPlayers = null,
  }) {
    return _then(
      _value.copyWith(
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as SeasonPhase,
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as int,
            submittedSetups: null == submittedSetups
                ? _value.submittedSetups
                : submittedSetups // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            totalPlayers: null == totalPlayers
                ? _value.totalPlayers
                : totalPlayers // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SeasonStateImplCopyWith<$Res>
    implements $SeasonStateCopyWith<$Res> {
  factory _$$SeasonStateImplCopyWith(
    _$SeasonStateImpl value,
    $Res Function(_$SeasonStateImpl) then,
  ) = __$$SeasonStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: SeasonPhase.unknown) SeasonPhase phase,
    int stage,
    @JsonKey(name: 'submitted_setups') List<int> submittedSetups,
    @JsonKey(name: 'total_players') int totalPlayers,
  });
}

/// @nodoc
class __$$SeasonStateImplCopyWithImpl<$Res>
    extends _$SeasonStateCopyWithImpl<$Res, _$SeasonStateImpl>
    implements _$$SeasonStateImplCopyWith<$Res> {
  __$$SeasonStateImplCopyWithImpl(
    _$SeasonStateImpl _value,
    $Res Function(_$SeasonStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SeasonState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? stage = null,
    Object? submittedSetups = null,
    Object? totalPlayers = null,
  }) {
    return _then(
      _$SeasonStateImpl(
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as SeasonPhase,
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as int,
        submittedSetups: null == submittedSetups
            ? _value._submittedSetups
            : submittedSetups // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        totalPlayers: null == totalPlayers
            ? _value.totalPlayers
            : totalPlayers // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonStateImpl implements _SeasonState {
  const _$SeasonStateImpl({
    @JsonKey(unknownEnumValue: SeasonPhase.unknown) required this.phase,
    this.stage = 0,
    @JsonKey(name: 'submitted_setups')
    final List<int> submittedSetups = const <int>[],
    @JsonKey(name: 'total_players') this.totalPlayers = 0,
  }) : _submittedSetups = submittedSetups;

  factory _$SeasonStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonStateImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: SeasonPhase.unknown)
  final SeasonPhase phase;
  @override
  @JsonKey()
  final int stage;
  final List<int> _submittedSetups;
  @override
  @JsonKey(name: 'submitted_setups')
  List<int> get submittedSetups {
    if (_submittedSetups is EqualUnmodifiableListView) return _submittedSetups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_submittedSetups);
  }

  @override
  @JsonKey(name: 'total_players')
  final int totalPlayers;

  @override
  String toString() {
    return 'SeasonState(phase: $phase, stage: $stage, submittedSetups: $submittedSetups, totalPlayers: $totalPlayers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonStateImpl &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            const DeepCollectionEquality().equals(
              other._submittedSetups,
              _submittedSetups,
            ) &&
            (identical(other.totalPlayers, totalPlayers) ||
                other.totalPlayers == totalPlayers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    phase,
    stage,
    const DeepCollectionEquality().hash(_submittedSetups),
    totalPlayers,
  );

  /// Create a copy of SeasonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonStateImplCopyWith<_$SeasonStateImpl> get copyWith =>
      __$$SeasonStateImplCopyWithImpl<_$SeasonStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonStateImplToJson(this);
  }
}

abstract class _SeasonState implements SeasonState {
  const factory _SeasonState({
    @JsonKey(unknownEnumValue: SeasonPhase.unknown)
    required final SeasonPhase phase,
    final int stage,
    @JsonKey(name: 'submitted_setups') final List<int> submittedSetups,
    @JsonKey(name: 'total_players') final int totalPlayers,
  }) = _$SeasonStateImpl;

  factory _SeasonState.fromJson(Map<String, dynamic> json) =
      _$SeasonStateImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: SeasonPhase.unknown)
  SeasonPhase get phase;
  @override
  int get stage;
  @override
  @JsonKey(name: 'submitted_setups')
  List<int> get submittedSetups;
  @override
  @JsonKey(name: 'total_players')
  int get totalPlayers;

  /// Create a copy of SeasonState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonStateImplCopyWith<_$SeasonStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
