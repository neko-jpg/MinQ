// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_habit_correlation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MoodHabitCorrelation _$MoodHabitCorrelationFromJson(Map<String, dynamic> json) {
  return _MoodHabitCorrelation.fromJson(json);
}

/// @nodoc
mixin _$MoodHabitCorrelation {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get habitId => throw _privateConstructorUsedError;
  String get mood => throw _privateConstructorUsedError;
  double get correlationScore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MoodHabitCorrelationCopyWith<MoodHabitCorrelation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoodHabitCorrelationCopyWith<$Res> {
  factory $MoodHabitCorrelationCopyWith(MoodHabitCorrelation value,
          $Res Function(MoodHabitCorrelation) then) =
      _$MoodHabitCorrelationCopyWithImpl<$Res, MoodHabitCorrelation>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String habitId,
      String mood,
      double correlationScore});
}

/// @nodoc
class _$MoodHabitCorrelationCopyWithImpl<$Res,
        $Val extends MoodHabitCorrelation>
    implements $MoodHabitCorrelationCopyWith<$Res> {
  _$MoodHabitCorrelationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? habitId = null,
    Object? mood = null,
    Object? correlationScore = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String,
      correlationScore: null == correlationScore
          ? _value.correlationScore
          : correlationScore // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MoodHabitCorrelationImplCopyWith<$Res>
    implements $MoodHabitCorrelationCopyWith<$Res> {
  factory _$$MoodHabitCorrelationImplCopyWith(_$MoodHabitCorrelationImpl value,
          $Res Function(_$MoodHabitCorrelationImpl) then) =
      __$$MoodHabitCorrelationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String habitId,
      String mood,
      double correlationScore});
}

/// @nodoc
class __$$MoodHabitCorrelationImplCopyWithImpl<$Res>
    extends _$MoodHabitCorrelationCopyWithImpl<$Res, _$MoodHabitCorrelationImpl>
    implements _$$MoodHabitCorrelationImplCopyWith<$Res> {
  __$$MoodHabitCorrelationImplCopyWithImpl(_$MoodHabitCorrelationImpl _value,
      $Res Function(_$MoodHabitCorrelationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? habitId = null,
    Object? mood = null,
    Object? correlationScore = null,
  }) {
    return _then(_$MoodHabitCorrelationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String,
      correlationScore: null == correlationScore
          ? _value.correlationScore
          : correlationScore // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MoodHabitCorrelationImpl implements _MoodHabitCorrelation {
  const _$MoodHabitCorrelationImpl(
      {required this.id,
      required this.userId,
      required this.habitId,
      required this.mood,
      required this.correlationScore});

  factory _$MoodHabitCorrelationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoodHabitCorrelationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String habitId;
  @override
  final String mood;
  @override
  final double correlationScore;

  @override
  String toString() {
    return 'MoodHabitCorrelation(id: $id, userId: $userId, habitId: $habitId, mood: $mood, correlationScore: $correlationScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoodHabitCorrelationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.correlationScore, correlationScore) ||
                other.correlationScore == correlationScore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, habitId, mood, correlationScore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MoodHabitCorrelationImplCopyWith<_$MoodHabitCorrelationImpl>
      get copyWith =>
          __$$MoodHabitCorrelationImplCopyWithImpl<_$MoodHabitCorrelationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoodHabitCorrelationImplToJson(
      this,
    );
  }
}

abstract class _MoodHabitCorrelation implements MoodHabitCorrelation {
  const factory _MoodHabitCorrelation(
      {required final String id,
      required final String userId,
      required final String habitId,
      required final String mood,
      required final double correlationScore}) = _$MoodHabitCorrelationImpl;

  factory _MoodHabitCorrelation.fromJson(Map<String, dynamic> json) =
      _$MoodHabitCorrelationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get habitId;
  @override
  String get mood;
  @override
  double get correlationScore;
  @override
  @JsonKey(ignore: true)
  _$$MoodHabitCorrelationImplCopyWith<_$MoodHabitCorrelationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
