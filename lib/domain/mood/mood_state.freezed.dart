// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MoodState _$MoodStateFromJson(Map<String, dynamic> json) {
  return _MoodState.fromJson(json);
}

/// @nodoc
mixin _$MoodState {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get mood =>
      throw _privateConstructorUsedError; // e.g., 'happy', 'sad', 'neutral'
  int get rating => throw _privateConstructorUsedError; // 1-5
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MoodStateCopyWith<MoodState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoodStateCopyWith<$Res> {
  factory $MoodStateCopyWith(MoodState value, $Res Function(MoodState) then) =
      _$MoodStateCopyWithImpl<$Res, MoodState>;
  @useResult
  $Res call(
      {String id, String userId, String mood, int rating, DateTime createdAt});
}

/// @nodoc
class _$MoodStateCopyWithImpl<$Res, $Val extends MoodState>
    implements $MoodStateCopyWith<$Res> {
  _$MoodStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? mood = null,
    Object? rating = null,
    Object? createdAt = null,
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
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MoodStateImplCopyWith<$Res>
    implements $MoodStateCopyWith<$Res> {
  factory _$$MoodStateImplCopyWith(
          _$MoodStateImpl value, $Res Function(_$MoodStateImpl) then) =
      __$$MoodStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String userId, String mood, int rating, DateTime createdAt});
}

/// @nodoc
class __$$MoodStateImplCopyWithImpl<$Res>
    extends _$MoodStateCopyWithImpl<$Res, _$MoodStateImpl>
    implements _$$MoodStateImplCopyWith<$Res> {
  __$$MoodStateImplCopyWithImpl(
      _$MoodStateImpl _value, $Res Function(_$MoodStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? mood = null,
    Object? rating = null,
    Object? createdAt = null,
  }) {
    return _then(_$MoodStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MoodStateImpl implements _MoodState {
  const _$MoodStateImpl(
      {required this.id,
      required this.userId,
      required this.mood,
      required this.rating,
      required this.createdAt});

  factory _$MoodStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoodStateImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String mood;
// e.g., 'happy', 'sad', 'neutral'
  @override
  final int rating;
// 1-5
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MoodState(id: $id, userId: $userId, mood: $mood, rating: $rating, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoodStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, mood, rating, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MoodStateImplCopyWith<_$MoodStateImpl> get copyWith =>
      __$$MoodStateImplCopyWithImpl<_$MoodStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoodStateImplToJson(
      this,
    );
  }
}

abstract class _MoodState implements MoodState {
  const factory _MoodState(
      {required final String id,
      required final String userId,
      required final String mood,
      required final int rating,
      required final DateTime createdAt}) = _$MoodStateImpl;

  factory _MoodState.fromJson(Map<String, dynamic> json) =
      _$MoodStateImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get mood;
  @override // e.g., 'happy', 'sad', 'neutral'
  int get rating;
  @override // 1-5
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$MoodStateImplCopyWith<_$MoodStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
