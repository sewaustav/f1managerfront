// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RaceResult _$RaceResultFromJson(Map<String, dynamic> json) {
  return _RaceResult.fromJson(json);
}

/// @nodoc
mixin _$RaceResult {
  @JsonKey(name: 'pilot_id')
  int get pilotId => throw _privateConstructorUsedError;
  @JsonKey(name: 'garage_id')
  int get garageId => throw _privateConstructorUsedError;
  @JsonKey(name: 'pilot_name')
  String get pilotName => throw _privateConstructorUsedError;
  @JsonKey(name: 'team_name')
  String get teamName => throw _privateConstructorUsedError;
  @JsonKey(name: 'quali_position')
  int get qualiPosition => throw _privateConstructorUsedError;
  @JsonKey(name: 'race_position')
  int get racePosition => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_dnf')
  bool get isDnf => throw _privateConstructorUsedError;
  @JsonKey(name: 'dnf_reason')
  String get dnfReason => throw _privateConstructorUsedError;

  /// Serializes this RaceResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RaceResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaceResultCopyWith<RaceResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceResultCopyWith<$Res> {
  factory $RaceResultCopyWith(
    RaceResult value,
    $Res Function(RaceResult) then,
  ) = _$RaceResultCopyWithImpl<$Res, RaceResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'pilot_id') int pilotId,
    @JsonKey(name: 'garage_id') int garageId,
    @JsonKey(name: 'pilot_name') String pilotName,
    @JsonKey(name: 'team_name') String teamName,
    @JsonKey(name: 'quali_position') int qualiPosition,
    @JsonKey(name: 'race_position') int racePosition,
    int points,
    @JsonKey(name: 'is_dnf') bool isDnf,
    @JsonKey(name: 'dnf_reason') String dnfReason,
  });
}

/// @nodoc
class _$RaceResultCopyWithImpl<$Res, $Val extends RaceResult>
    implements $RaceResultCopyWith<$Res> {
  _$RaceResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RaceResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pilotId = null,
    Object? garageId = null,
    Object? pilotName = null,
    Object? teamName = null,
    Object? qualiPosition = null,
    Object? racePosition = null,
    Object? points = null,
    Object? isDnf = null,
    Object? dnfReason = null,
  }) {
    return _then(
      _value.copyWith(
            pilotId: null == pilotId
                ? _value.pilotId
                : pilotId // ignore: cast_nullable_to_non_nullable
                      as int,
            garageId: null == garageId
                ? _value.garageId
                : garageId // ignore: cast_nullable_to_non_nullable
                      as int,
            pilotName: null == pilotName
                ? _value.pilotName
                : pilotName // ignore: cast_nullable_to_non_nullable
                      as String,
            teamName: null == teamName
                ? _value.teamName
                : teamName // ignore: cast_nullable_to_non_nullable
                      as String,
            qualiPosition: null == qualiPosition
                ? _value.qualiPosition
                : qualiPosition // ignore: cast_nullable_to_non_nullable
                      as int,
            racePosition: null == racePosition
                ? _value.racePosition
                : racePosition // ignore: cast_nullable_to_non_nullable
                      as int,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            isDnf: null == isDnf
                ? _value.isDnf
                : isDnf // ignore: cast_nullable_to_non_nullable
                      as bool,
            dnfReason: null == dnfReason
                ? _value.dnfReason
                : dnfReason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RaceResultImplCopyWith<$Res>
    implements $RaceResultCopyWith<$Res> {
  factory _$$RaceResultImplCopyWith(
    _$RaceResultImpl value,
    $Res Function(_$RaceResultImpl) then,
  ) = __$$RaceResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pilot_id') int pilotId,
    @JsonKey(name: 'garage_id') int garageId,
    @JsonKey(name: 'pilot_name') String pilotName,
    @JsonKey(name: 'team_name') String teamName,
    @JsonKey(name: 'quali_position') int qualiPosition,
    @JsonKey(name: 'race_position') int racePosition,
    int points,
    @JsonKey(name: 'is_dnf') bool isDnf,
    @JsonKey(name: 'dnf_reason') String dnfReason,
  });
}

/// @nodoc
class __$$RaceResultImplCopyWithImpl<$Res>
    extends _$RaceResultCopyWithImpl<$Res, _$RaceResultImpl>
    implements _$$RaceResultImplCopyWith<$Res> {
  __$$RaceResultImplCopyWithImpl(
    _$RaceResultImpl _value,
    $Res Function(_$RaceResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RaceResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pilotId = null,
    Object? garageId = null,
    Object? pilotName = null,
    Object? teamName = null,
    Object? qualiPosition = null,
    Object? racePosition = null,
    Object? points = null,
    Object? isDnf = null,
    Object? dnfReason = null,
  }) {
    return _then(
      _$RaceResultImpl(
        pilotId: null == pilotId
            ? _value.pilotId
            : pilotId // ignore: cast_nullable_to_non_nullable
                  as int,
        garageId: null == garageId
            ? _value.garageId
            : garageId // ignore: cast_nullable_to_non_nullable
                  as int,
        pilotName: null == pilotName
            ? _value.pilotName
            : pilotName // ignore: cast_nullable_to_non_nullable
                  as String,
        teamName: null == teamName
            ? _value.teamName
            : teamName // ignore: cast_nullable_to_non_nullable
                  as String,
        qualiPosition: null == qualiPosition
            ? _value.qualiPosition
            : qualiPosition // ignore: cast_nullable_to_non_nullable
                  as int,
        racePosition: null == racePosition
            ? _value.racePosition
            : racePosition // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        isDnf: null == isDnf
            ? _value.isDnf
            : isDnf // ignore: cast_nullable_to_non_nullable
                  as bool,
        dnfReason: null == dnfReason
            ? _value.dnfReason
            : dnfReason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceResultImpl implements _RaceResult {
  const _$RaceResultImpl({
    @JsonKey(name: 'pilot_id') this.pilotId = 0,
    @JsonKey(name: 'garage_id') this.garageId = 0,
    @JsonKey(name: 'pilot_name') this.pilotName = '',
    @JsonKey(name: 'team_name') this.teamName = '',
    @JsonKey(name: 'quali_position') this.qualiPosition = 0,
    @JsonKey(name: 'race_position') this.racePosition = 0,
    this.points = 0,
    @JsonKey(name: 'is_dnf') this.isDnf = false,
    @JsonKey(name: 'dnf_reason') this.dnfReason = '',
  });

  factory _$RaceResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaceResultImplFromJson(json);

  @override
  @JsonKey(name: 'pilot_id')
  final int pilotId;
  @override
  @JsonKey(name: 'garage_id')
  final int garageId;
  @override
  @JsonKey(name: 'pilot_name')
  final String pilotName;
  @override
  @JsonKey(name: 'team_name')
  final String teamName;
  @override
  @JsonKey(name: 'quali_position')
  final int qualiPosition;
  @override
  @JsonKey(name: 'race_position')
  final int racePosition;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey(name: 'is_dnf')
  final bool isDnf;
  @override
  @JsonKey(name: 'dnf_reason')
  final String dnfReason;

  @override
  String toString() {
    return 'RaceResult(pilotId: $pilotId, garageId: $garageId, pilotName: $pilotName, teamName: $teamName, qualiPosition: $qualiPosition, racePosition: $racePosition, points: $points, isDnf: $isDnf, dnfReason: $dnfReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceResultImpl &&
            (identical(other.pilotId, pilotId) || other.pilotId == pilotId) &&
            (identical(other.garageId, garageId) ||
                other.garageId == garageId) &&
            (identical(other.pilotName, pilotName) ||
                other.pilotName == pilotName) &&
            (identical(other.teamName, teamName) ||
                other.teamName == teamName) &&
            (identical(other.qualiPosition, qualiPosition) ||
                other.qualiPosition == qualiPosition) &&
            (identical(other.racePosition, racePosition) ||
                other.racePosition == racePosition) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.isDnf, isDnf) || other.isDnf == isDnf) &&
            (identical(other.dnfReason, dnfReason) ||
                other.dnfReason == dnfReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pilotId,
    garageId,
    pilotName,
    teamName,
    qualiPosition,
    racePosition,
    points,
    isDnf,
    dnfReason,
  );

  /// Create a copy of RaceResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceResultImplCopyWith<_$RaceResultImpl> get copyWith =>
      __$$RaceResultImplCopyWithImpl<_$RaceResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceResultImplToJson(this);
  }
}

abstract class _RaceResult implements RaceResult {
  const factory _RaceResult({
    @JsonKey(name: 'pilot_id') final int pilotId,
    @JsonKey(name: 'garage_id') final int garageId,
    @JsonKey(name: 'pilot_name') final String pilotName,
    @JsonKey(name: 'team_name') final String teamName,
    @JsonKey(name: 'quali_position') final int qualiPosition,
    @JsonKey(name: 'race_position') final int racePosition,
    final int points,
    @JsonKey(name: 'is_dnf') final bool isDnf,
    @JsonKey(name: 'dnf_reason') final String dnfReason,
  }) = _$RaceResultImpl;

  factory _RaceResult.fromJson(Map<String, dynamic> json) =
      _$RaceResultImpl.fromJson;

  @override
  @JsonKey(name: 'pilot_id')
  int get pilotId;
  @override
  @JsonKey(name: 'garage_id')
  int get garageId;
  @override
  @JsonKey(name: 'pilot_name')
  String get pilotName;
  @override
  @JsonKey(name: 'team_name')
  String get teamName;
  @override
  @JsonKey(name: 'quali_position')
  int get qualiPosition;
  @override
  @JsonKey(name: 'race_position')
  int get racePosition;
  @override
  int get points;
  @override
  @JsonKey(name: 'is_dnf')
  bool get isDnf;
  @override
  @JsonKey(name: 'dnf_reason')
  String get dnfReason;

  /// Create a copy of RaceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaceResultImplCopyWith<_$RaceResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RaceResultResponse _$RaceResultResponseFromJson(Map<String, dynamic> json) {
  return _RaceResultResponse.fromJson(json);
}

/// @nodoc
mixin _$RaceResultResponse {
  int get stage => throw _privateConstructorUsedError;
  List<RaceResult> get results => throw _privateConstructorUsedError;

  /// Serializes this RaceResultResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RaceResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaceResultResponseCopyWith<RaceResultResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceResultResponseCopyWith<$Res> {
  factory $RaceResultResponseCopyWith(
    RaceResultResponse value,
    $Res Function(RaceResultResponse) then,
  ) = _$RaceResultResponseCopyWithImpl<$Res, RaceResultResponse>;
  @useResult
  $Res call({int stage, List<RaceResult> results});
}

/// @nodoc
class _$RaceResultResponseCopyWithImpl<$Res, $Val extends RaceResultResponse>
    implements $RaceResultResponseCopyWith<$Res> {
  _$RaceResultResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RaceResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stage = null, Object? results = null}) {
    return _then(
      _value.copyWith(
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as int,
            results: null == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<RaceResult>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RaceResultResponseImplCopyWith<$Res>
    implements $RaceResultResponseCopyWith<$Res> {
  factory _$$RaceResultResponseImplCopyWith(
    _$RaceResultResponseImpl value,
    $Res Function(_$RaceResultResponseImpl) then,
  ) = __$$RaceResultResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int stage, List<RaceResult> results});
}

/// @nodoc
class __$$RaceResultResponseImplCopyWithImpl<$Res>
    extends _$RaceResultResponseCopyWithImpl<$Res, _$RaceResultResponseImpl>
    implements _$$RaceResultResponseImplCopyWith<$Res> {
  __$$RaceResultResponseImplCopyWithImpl(
    _$RaceResultResponseImpl _value,
    $Res Function(_$RaceResultResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RaceResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stage = null, Object? results = null}) {
    return _then(
      _$RaceResultResponseImpl(
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as int,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<RaceResult>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceResultResponseImpl implements _RaceResultResponse {
  const _$RaceResultResponseImpl({
    this.stage = 0,
    final List<RaceResult> results = const <RaceResult>[],
  }) : _results = results;

  factory _$RaceResultResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaceResultResponseImplFromJson(json);

  @override
  @JsonKey()
  final int stage;
  final List<RaceResult> _results;
  @override
  @JsonKey()
  List<RaceResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'RaceResultResponse(stage: $stage, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceResultResponseImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stage,
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of RaceResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceResultResponseImplCopyWith<_$RaceResultResponseImpl> get copyWith =>
      __$$RaceResultResponseImplCopyWithImpl<_$RaceResultResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceResultResponseImplToJson(this);
  }
}

abstract class _RaceResultResponse implements RaceResultResponse {
  const factory _RaceResultResponse({
    final int stage,
    final List<RaceResult> results,
  }) = _$RaceResultResponseImpl;

  factory _RaceResultResponse.fromJson(Map<String, dynamic> json) =
      _$RaceResultResponseImpl.fromJson;

  @override
  int get stage;
  @override
  List<RaceResult> get results;

  /// Create a copy of RaceResultResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaceResultResponseImplCopyWith<_$RaceResultResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
