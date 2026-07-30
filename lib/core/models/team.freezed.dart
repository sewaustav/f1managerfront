// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Team _$TeamFromJson(Map<String, dynamic> json) {
  return _Team.fromJson(json);
}

/// @nodoc
mixin _$Team {
  @JsonKey(name: 'ID')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'ICE')
  int get ice => throw _privateConstructorUsedError;
  @JsonKey(name: 'CarLevel')
  int get carLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'BaseLevel')
  int get baseLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'Engineer')
  int get engineer => throw _privateConstructorUsedError;
  @JsonKey(name: 'SimLevel')
  int get simLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'TubeLevel')
  int get tubeLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'UpdateRating')
  int get updateRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'Tokens')
  int get tokens => throw _privateConstructorUsedError;
  @JsonKey(name: 'Budget')
  int get budget => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsManufacturer')
  int get isManufacturer => throw _privateConstructorUsedError;
  @JsonKey(name: 'CarSettings')
  int get carSettings => throw _privateConstructorUsedError;

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamCopyWith<Team> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamCopyWith<$Res> {
  factory $TeamCopyWith(Team value, $Res Function(Team) then) =
      _$TeamCopyWithImpl<$Res, Team>;
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'ICE') int ice,
    @JsonKey(name: 'CarLevel') int carLevel,
    @JsonKey(name: 'BaseLevel') int baseLevel,
    @JsonKey(name: 'Engineer') int engineer,
    @JsonKey(name: 'SimLevel') int simLevel,
    @JsonKey(name: 'TubeLevel') int tubeLevel,
    @JsonKey(name: 'UpdateRating') int updateRating,
    @JsonKey(name: 'Tokens') int tokens,
    @JsonKey(name: 'Budget') int budget,
    @JsonKey(name: 'IsManufacturer') int isManufacturer,
    @JsonKey(name: 'CarSettings') int carSettings,
  });
}

/// @nodoc
class _$TeamCopyWithImpl<$Res, $Val extends Team>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ice = null,
    Object? carLevel = null,
    Object? baseLevel = null,
    Object? engineer = null,
    Object? simLevel = null,
    Object? tubeLevel = null,
    Object? updateRating = null,
    Object? tokens = null,
    Object? budget = null,
    Object? isManufacturer = null,
    Object? carSettings = null,
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
            ice: null == ice
                ? _value.ice
                : ice // ignore: cast_nullable_to_non_nullable
                      as int,
            carLevel: null == carLevel
                ? _value.carLevel
                : carLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            baseLevel: null == baseLevel
                ? _value.baseLevel
                : baseLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            engineer: null == engineer
                ? _value.engineer
                : engineer // ignore: cast_nullable_to_non_nullable
                      as int,
            simLevel: null == simLevel
                ? _value.simLevel
                : simLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            tubeLevel: null == tubeLevel
                ? _value.tubeLevel
                : tubeLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            updateRating: null == updateRating
                ? _value.updateRating
                : updateRating // ignore: cast_nullable_to_non_nullable
                      as int,
            tokens: null == tokens
                ? _value.tokens
                : tokens // ignore: cast_nullable_to_non_nullable
                      as int,
            budget: null == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                      as int,
            isManufacturer: null == isManufacturer
                ? _value.isManufacturer
                : isManufacturer // ignore: cast_nullable_to_non_nullable
                      as int,
            carSettings: null == carSettings
                ? _value.carSettings
                : carSettings // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamImplCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$$TeamImplCopyWith(
    _$TeamImpl value,
    $Res Function(_$TeamImpl) then,
  ) = __$$TeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'ICE') int ice,
    @JsonKey(name: 'CarLevel') int carLevel,
    @JsonKey(name: 'BaseLevel') int baseLevel,
    @JsonKey(name: 'Engineer') int engineer,
    @JsonKey(name: 'SimLevel') int simLevel,
    @JsonKey(name: 'TubeLevel') int tubeLevel,
    @JsonKey(name: 'UpdateRating') int updateRating,
    @JsonKey(name: 'Tokens') int tokens,
    @JsonKey(name: 'Budget') int budget,
    @JsonKey(name: 'IsManufacturer') int isManufacturer,
    @JsonKey(name: 'CarSettings') int carSettings,
  });
}

/// @nodoc
class __$$TeamImplCopyWithImpl<$Res>
    extends _$TeamCopyWithImpl<$Res, _$TeamImpl>
    implements _$$TeamImplCopyWith<$Res> {
  __$$TeamImplCopyWithImpl(_$TeamImpl _value, $Res Function(_$TeamImpl) _then)
    : super(_value, _then);

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ice = null,
    Object? carLevel = null,
    Object? baseLevel = null,
    Object? engineer = null,
    Object? simLevel = null,
    Object? tubeLevel = null,
    Object? updateRating = null,
    Object? tokens = null,
    Object? budget = null,
    Object? isManufacturer = null,
    Object? carSettings = null,
  }) {
    return _then(
      _$TeamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        ice: null == ice
            ? _value.ice
            : ice // ignore: cast_nullable_to_non_nullable
                  as int,
        carLevel: null == carLevel
            ? _value.carLevel
            : carLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        baseLevel: null == baseLevel
            ? _value.baseLevel
            : baseLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        engineer: null == engineer
            ? _value.engineer
            : engineer // ignore: cast_nullable_to_non_nullable
                  as int,
        simLevel: null == simLevel
            ? _value.simLevel
            : simLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        tubeLevel: null == tubeLevel
            ? _value.tubeLevel
            : tubeLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        updateRating: null == updateRating
            ? _value.updateRating
            : updateRating // ignore: cast_nullable_to_non_nullable
                  as int,
        tokens: null == tokens
            ? _value.tokens
            : tokens // ignore: cast_nullable_to_non_nullable
                  as int,
        budget: null == budget
            ? _value.budget
            : budget // ignore: cast_nullable_to_non_nullable
                  as int,
        isManufacturer: null == isManufacturer
            ? _value.isManufacturer
            : isManufacturer // ignore: cast_nullable_to_non_nullable
                  as int,
        carSettings: null == carSettings
            ? _value.carSettings
            : carSettings // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamImpl implements _Team {
  const _$TeamImpl({
    @JsonKey(name: 'ID') required this.id,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'ICE') this.ice = 0,
    @JsonKey(name: 'CarLevel') this.carLevel = 0,
    @JsonKey(name: 'BaseLevel') this.baseLevel = 0,
    @JsonKey(name: 'Engineer') this.engineer = 0,
    @JsonKey(name: 'SimLevel') this.simLevel = 0,
    @JsonKey(name: 'TubeLevel') this.tubeLevel = 0,
    @JsonKey(name: 'UpdateRating') this.updateRating = 0,
    @JsonKey(name: 'Tokens') this.tokens = 0,
    @JsonKey(name: 'Budget') this.budget = 0,
    @JsonKey(name: 'IsManufacturer') this.isManufacturer = 0,
    @JsonKey(name: 'CarSettings') this.carSettings = 0,
  });

  factory _$TeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamImplFromJson(json);

  @override
  @JsonKey(name: 'ID')
  final int id;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'ICE')
  final int ice;
  @override
  @JsonKey(name: 'CarLevel')
  final int carLevel;
  @override
  @JsonKey(name: 'BaseLevel')
  final int baseLevel;
  @override
  @JsonKey(name: 'Engineer')
  final int engineer;
  @override
  @JsonKey(name: 'SimLevel')
  final int simLevel;
  @override
  @JsonKey(name: 'TubeLevel')
  final int tubeLevel;
  @override
  @JsonKey(name: 'UpdateRating')
  final int updateRating;
  @override
  @JsonKey(name: 'Tokens')
  final int tokens;
  @override
  @JsonKey(name: 'Budget')
  final int budget;
  @override
  @JsonKey(name: 'IsManufacturer')
  final int isManufacturer;
  @override
  @JsonKey(name: 'CarSettings')
  final int carSettings;

  @override
  String toString() {
    return 'Team(id: $id, name: $name, ice: $ice, carLevel: $carLevel, baseLevel: $baseLevel, engineer: $engineer, simLevel: $simLevel, tubeLevel: $tubeLevel, updateRating: $updateRating, tokens: $tokens, budget: $budget, isManufacturer: $isManufacturer, carSettings: $carSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ice, ice) || other.ice == ice) &&
            (identical(other.carLevel, carLevel) ||
                other.carLevel == carLevel) &&
            (identical(other.baseLevel, baseLevel) ||
                other.baseLevel == baseLevel) &&
            (identical(other.engineer, engineer) ||
                other.engineer == engineer) &&
            (identical(other.simLevel, simLevel) ||
                other.simLevel == simLevel) &&
            (identical(other.tubeLevel, tubeLevel) ||
                other.tubeLevel == tubeLevel) &&
            (identical(other.updateRating, updateRating) ||
                other.updateRating == updateRating) &&
            (identical(other.tokens, tokens) || other.tokens == tokens) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.isManufacturer, isManufacturer) ||
                other.isManufacturer == isManufacturer) &&
            (identical(other.carSettings, carSettings) ||
                other.carSettings == carSettings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    ice,
    carLevel,
    baseLevel,
    engineer,
    simLevel,
    tubeLevel,
    updateRating,
    tokens,
    budget,
    isManufacturer,
    carSettings,
  );

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      __$$TeamImplCopyWithImpl<_$TeamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamImplToJson(this);
  }
}

abstract class _Team implements Team {
  const factory _Team({
    @JsonKey(name: 'ID') required final int id,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'ICE') final int ice,
    @JsonKey(name: 'CarLevel') final int carLevel,
    @JsonKey(name: 'BaseLevel') final int baseLevel,
    @JsonKey(name: 'Engineer') final int engineer,
    @JsonKey(name: 'SimLevel') final int simLevel,
    @JsonKey(name: 'TubeLevel') final int tubeLevel,
    @JsonKey(name: 'UpdateRating') final int updateRating,
    @JsonKey(name: 'Tokens') final int tokens,
    @JsonKey(name: 'Budget') final int budget,
    @JsonKey(name: 'IsManufacturer') final int isManufacturer,
    @JsonKey(name: 'CarSettings') final int carSettings,
  }) = _$TeamImpl;

  factory _Team.fromJson(Map<String, dynamic> json) = _$TeamImpl.fromJson;

  @override
  @JsonKey(name: 'ID')
  int get id;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'ICE')
  int get ice;
  @override
  @JsonKey(name: 'CarLevel')
  int get carLevel;
  @override
  @JsonKey(name: 'BaseLevel')
  int get baseLevel;
  @override
  @JsonKey(name: 'Engineer')
  int get engineer;
  @override
  @JsonKey(name: 'SimLevel')
  int get simLevel;
  @override
  @JsonKey(name: 'TubeLevel')
  int get tubeLevel;
  @override
  @JsonKey(name: 'UpdateRating')
  int get updateRating;
  @override
  @JsonKey(name: 'Tokens')
  int get tokens;
  @override
  @JsonKey(name: 'Budget')
  int get budget;
  @override
  @JsonKey(name: 'IsManufacturer')
  int get isManufacturer;
  @override
  @JsonKey(name: 'CarSettings')
  int get carSettings;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
