// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return _Player.fromJson(json);
}

/// @nodoc
mixin _$Player {
  @JsonKey(name: 'ID')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'TeamPrincipal')
  int? get teamPrincipal => throw _privateConstructorUsedError;
  @JsonKey(name: 'Team')
  int get team => throw _privateConstructorUsedError;
  @JsonKey(name: 'Budget')
  int get budget => throw _privateConstructorUsedError;
  @JsonKey(name: 'Tokens')
  int get tokens => throw _privateConstructorUsedError;

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerCopyWith<Player> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerCopyWith<$Res> {
  factory $PlayerCopyWith(Player value, $Res Function(Player) then) =
      _$PlayerCopyWithImpl<$Res, Player>;
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'TeamPrincipal') int? teamPrincipal,
    @JsonKey(name: 'Team') int team,
    @JsonKey(name: 'Budget') int budget,
    @JsonKey(name: 'Tokens') int tokens,
  });
}

/// @nodoc
class _$PlayerCopyWithImpl<$Res, $Val extends Player>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? teamPrincipal = freezed,
    Object? team = null,
    Object? budget = null,
    Object? tokens = null,
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
            teamPrincipal: freezed == teamPrincipal
                ? _value.teamPrincipal
                : teamPrincipal // ignore: cast_nullable_to_non_nullable
                      as int?,
            team: null == team
                ? _value.team
                : team // ignore: cast_nullable_to_non_nullable
                      as int,
            budget: null == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                      as int,
            tokens: null == tokens
                ? _value.tokens
                : tokens // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerImplCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$$PlayerImplCopyWith(
    _$PlayerImpl value,
    $Res Function(_$PlayerImpl) then,
  ) = __$$PlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ID') int id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'TeamPrincipal') int? teamPrincipal,
    @JsonKey(name: 'Team') int team,
    @JsonKey(name: 'Budget') int budget,
    @JsonKey(name: 'Tokens') int tokens,
  });
}

/// @nodoc
class __$$PlayerImplCopyWithImpl<$Res>
    extends _$PlayerCopyWithImpl<$Res, _$PlayerImpl>
    implements _$$PlayerImplCopyWith<$Res> {
  __$$PlayerImplCopyWithImpl(
    _$PlayerImpl _value,
    $Res Function(_$PlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? teamPrincipal = freezed,
    Object? team = null,
    Object? budget = null,
    Object? tokens = null,
  }) {
    return _then(
      _$PlayerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        teamPrincipal: freezed == teamPrincipal
            ? _value.teamPrincipal
            : teamPrincipal // ignore: cast_nullable_to_non_nullable
                  as int?,
        team: null == team
            ? _value.team
            : team // ignore: cast_nullable_to_non_nullable
                  as int,
        budget: null == budget
            ? _value.budget
            : budget // ignore: cast_nullable_to_non_nullable
                  as int,
        tokens: null == tokens
            ? _value.tokens
            : tokens // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerImpl implements _Player {
  const _$PlayerImpl({
    @JsonKey(name: 'ID') required this.id,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'TeamPrincipal') this.teamPrincipal,
    @JsonKey(name: 'Team') this.team = 0,
    @JsonKey(name: 'Budget') this.budget = 0,
    @JsonKey(name: 'Tokens') this.tokens = 0,
  });

  factory _$PlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerImplFromJson(json);

  @override
  @JsonKey(name: 'ID')
  final int id;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'TeamPrincipal')
  final int? teamPrincipal;
  @override
  @JsonKey(name: 'Team')
  final int team;
  @override
  @JsonKey(name: 'Budget')
  final int budget;
  @override
  @JsonKey(name: 'Tokens')
  final int tokens;

  @override
  String toString() {
    return 'Player(id: $id, name: $name, teamPrincipal: $teamPrincipal, team: $team, budget: $budget, tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.teamPrincipal, teamPrincipal) ||
                other.teamPrincipal == teamPrincipal) &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.tokens, tokens) || other.tokens == tokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, teamPrincipal, team, budget, tokens);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      __$$PlayerImplCopyWithImpl<_$PlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerImplToJson(this);
  }
}

abstract class _Player implements Player {
  const factory _Player({
    @JsonKey(name: 'ID') required final int id,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'TeamPrincipal') final int? teamPrincipal,
    @JsonKey(name: 'Team') final int team,
    @JsonKey(name: 'Budget') final int budget,
    @JsonKey(name: 'Tokens') final int tokens,
  }) = _$PlayerImpl;

  factory _Player.fromJson(Map<String, dynamic> json) = _$PlayerImpl.fromJson;

  @override
  @JsonKey(name: 'ID')
  int get id;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'TeamPrincipal')
  int? get teamPrincipal;
  @override
  @JsonKey(name: 'Team')
  int get team;
  @override
  @JsonKey(name: 'Budget')
  int get budget;
  @override
  @JsonKey(name: 'Tokens')
  int get tokens;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
