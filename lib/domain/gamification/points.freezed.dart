// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'points.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Points _$PointsFromJson(Map<String, dynamic> json) {
  return _Points.fromJson(json);
}

/// @nodoc
mixin _$Points {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PointsCopyWith<Points> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointsCopyWith<$Res> {
  factory $PointsCopyWith(Points value, $Res Function(Points) then) =
      _$PointsCopyWithImpl<$Res, Points>;
  @useResult
  $Res call(
      {String id, String userId, int value, String reason, DateTime createdAt});
}

/// @nodoc
class _$PointsCopyWithImpl<$Res, $Val extends Points>
    implements $PointsCopyWith<$Res> {
  _$PointsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? value = null,
    Object? reason = null,
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
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PointsImplCopyWith<$Res> implements $PointsCopyWith<$Res> {
  factory _$$PointsImplCopyWith(
          _$PointsImpl value, $Res Function(_$PointsImpl) then) =
      __$$PointsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String userId, int value, String reason, DateTime createdAt});
}

/// @nodoc
class __$$PointsImplCopyWithImpl<$Res>
    extends _$PointsCopyWithImpl<$Res, _$PointsImpl>
    implements _$$PointsImplCopyWith<$Res> {
  __$$PointsImplCopyWithImpl(
      _$PointsImpl _value, $Res Function(_$PointsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? value = null,
    Object? reason = null,
    Object? createdAt = null,
  }) {
    return _then(_$PointsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PointsImpl implements _Points {
  const _$PointsImpl(
      {required this.id,
      required this.userId,
      required this.value,
      required this.reason,
      required this.createdAt});

  factory _$PointsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointsImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final int value;
  @override
  final String reason;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Points(id: $id, userId: $userId, value: $value, reason: $reason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, value, reason, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PointsImplCopyWith<_$PointsImpl> get copyWith =>
      __$$PointsImplCopyWithImpl<_$PointsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointsImplToJson(
      this,
    );
  }
}

abstract class _Points implements Points {
  const factory _Points(
      {required final String id,
      required final String userId,
      required final int value,
      required final String reason,
      required final DateTime createdAt}) = _$PointsImpl;

  factory _Points.fromJson(Map<String, dynamic> json) = _$PointsImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get value;
  @override
  String get reason;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$PointsImplCopyWith<_$PointsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
