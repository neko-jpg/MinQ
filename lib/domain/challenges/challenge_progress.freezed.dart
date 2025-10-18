// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChallengeProgress _$ChallengeProgressFromJson(Map<String, dynamic> json) {
  return _ChallengeProgress.fromJson(json);
}

/// @nodoc
mixin _$ChallengeProgress {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get challengeId => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChallengeProgressCopyWith<ChallengeProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeProgressCopyWith<$Res> {
  factory $ChallengeProgressCopyWith(
          ChallengeProgress value, $Res Function(ChallengeProgress) then) =
      _$ChallengeProgressCopyWithImpl<$Res, ChallengeProgress>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String challengeId,
      int progress,
      bool completed});
}

/// @nodoc
class _$ChallengeProgressCopyWithImpl<$Res, $Val extends ChallengeProgress>
    implements $ChallengeProgressCopyWith<$Res> {
  _$ChallengeProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? challengeId = null,
    Object? progress = null,
    Object? completed = null,
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
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeProgressImplCopyWith<$Res>
    implements $ChallengeProgressCopyWith<$Res> {
  factory _$$ChallengeProgressImplCopyWith(_$ChallengeProgressImpl value,
          $Res Function(_$ChallengeProgressImpl) then) =
      __$$ChallengeProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String challengeId,
      int progress,
      bool completed});
}

/// @nodoc
class __$$ChallengeProgressImplCopyWithImpl<$Res>
    extends _$ChallengeProgressCopyWithImpl<$Res, _$ChallengeProgressImpl>
    implements _$$ChallengeProgressImplCopyWith<$Res> {
  __$$ChallengeProgressImplCopyWithImpl(_$ChallengeProgressImpl _value,
      $Res Function(_$ChallengeProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? challengeId = null,
    Object? progress = null,
    Object? completed = null,
  }) {
    return _then(_$ChallengeProgressImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeProgressImpl implements _ChallengeProgress {
  const _$ChallengeProgressImpl(
      {required this.id,
      required this.userId,
      required this.challengeId,
      required this.progress,
      required this.completed});

  factory _$ChallengeProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeProgressImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String challengeId;
  @override
  final int progress;
  @override
  final bool completed;

  @override
  String toString() {
    return 'ChallengeProgress(id: $id, userId: $userId, challengeId: $challengeId, progress: $progress, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, challengeId, progress, completed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeProgressImplCopyWith<_$ChallengeProgressImpl> get copyWith =>
      __$$ChallengeProgressImplCopyWithImpl<_$ChallengeProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeProgressImplToJson(
      this,
    );
  }
}

abstract class _ChallengeProgress implements ChallengeProgress {
  const factory _ChallengeProgress(
      {required final String id,
      required final String userId,
      required final String challengeId,
      required final int progress,
      required final bool completed}) = _$ChallengeProgressImpl;

  factory _ChallengeProgress.fromJson(Map<String, dynamic> json) =
      _$ChallengeProgressImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get challengeId;
  @override
  int get progress;
  @override
  bool get completed;
  @override
  @JsonKey(ignore: true)
  _$$ChallengeProgressImplCopyWith<_$ChallengeProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
