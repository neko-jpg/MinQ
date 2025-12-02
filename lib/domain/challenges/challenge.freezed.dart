// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Challenge _$ChallengeFromJson(Map<String, dynamic> json) {
  return _Challenge.fromJson(json);
}

/// @nodoc
mixin _$Challenge {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // e.g., 'daily', 'weekly', 'event'
  int get goal =>
      throw _privateConstructorUsedError; // e.g., number of days for a streak
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChallengeCopyWith<Challenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCopyWith<$Res> {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) then) =
      _$ChallengeCopyWithImpl<$Res, Challenge>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String type,
      int goal,
      DateTime startDate,
      DateTime endDate});
}

/// @nodoc
class _$ChallengeCopyWithImpl<$Res, $Val extends Challenge>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? goal = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeImplCopyWith<$Res>
    implements $ChallengeCopyWith<$Res> {
  factory _$$ChallengeImplCopyWith(
          _$ChallengeImpl value, $Res Function(_$ChallengeImpl) then) =
      __$$ChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String type,
      int goal,
      DateTime startDate,
      DateTime endDate});
}

/// @nodoc
class __$$ChallengeImplCopyWithImpl<$Res>
    extends _$ChallengeCopyWithImpl<$Res, _$ChallengeImpl>
    implements _$$ChallengeImplCopyWith<$Res> {
  __$$ChallengeImplCopyWithImpl(
      _$ChallengeImpl _value, $Res Function(_$ChallengeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? goal = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_$ChallengeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeImpl extends _Challenge {
  const _$ChallengeImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.type,
      required this.goal,
      required this.startDate,
      required this.endDate})
      : super._();

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String type;
// e.g., 'daily', 'weekly', 'event'
  @override
  final int goal;
// e.g., number of days for a streak
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'Challenge(id: $id, name: $name, description: $description, type: $type, goal: $goal, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, description, type, goal, startDate, endDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      __$$ChallengeImplCopyWithImpl<_$ChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeImplToJson(
      this,
    );
  }
}

abstract class _Challenge extends Challenge {
  const factory _Challenge(
      {required final String id,
      required final String name,
      required final String description,
      required final String type,
      required final int goal,
      required final DateTime startDate,
      required final DateTime endDate}) = _$ChallengeImpl;
  const _Challenge._() : super._();

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get type;
  @override // e.g., 'daily', 'weekly', 'event'
  int get goal;
  @override // e.g., number of days for a streak
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  @JsonKey(ignore: true)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
