// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_capsule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeCapsule _$TimeCapsuleFromJson(Map<String, dynamic> json) {
  return _TimeCapsule.fromJson(json);
}

/// @nodoc
mixin _$TimeCapsule {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get prediction => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get deliveryDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeCapsuleCopyWith<TimeCapsule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeCapsuleCopyWith<$Res> {
  factory $TimeCapsuleCopyWith(
          TimeCapsule value, $Res Function(TimeCapsule) then) =
      _$TimeCapsuleCopyWithImpl<$Res, TimeCapsule>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String message,
      String prediction,
      DateTime createdAt,
      DateTime deliveryDate});
}

/// @nodoc
class _$TimeCapsuleCopyWithImpl<$Res, $Val extends TimeCapsule>
    implements $TimeCapsuleCopyWith<$Res> {
  _$TimeCapsuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? message = null,
    Object? prediction = null,
    Object? createdAt = null,
    Object? deliveryDate = null,
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
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveryDate: null == deliveryDate
          ? _value.deliveryDate
          : deliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeCapsuleImplCopyWith<$Res>
    implements $TimeCapsuleCopyWith<$Res> {
  factory _$$TimeCapsuleImplCopyWith(
          _$TimeCapsuleImpl value, $Res Function(_$TimeCapsuleImpl) then) =
      __$$TimeCapsuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String message,
      String prediction,
      DateTime createdAt,
      DateTime deliveryDate});
}

/// @nodoc
class __$$TimeCapsuleImplCopyWithImpl<$Res>
    extends _$TimeCapsuleCopyWithImpl<$Res, _$TimeCapsuleImpl>
    implements _$$TimeCapsuleImplCopyWith<$Res> {
  __$$TimeCapsuleImplCopyWithImpl(
      _$TimeCapsuleImpl _value, $Res Function(_$TimeCapsuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? message = null,
    Object? prediction = null,
    Object? createdAt = null,
    Object? deliveryDate = null,
  }) {
    return _then(_$TimeCapsuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveryDate: null == deliveryDate
          ? _value.deliveryDate
          : deliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeCapsuleImpl implements _TimeCapsule {
  const _$TimeCapsuleImpl(
      {required this.id,
      required this.userId,
      required this.message,
      required this.prediction,
      required this.createdAt,
      required this.deliveryDate});

  factory _$TimeCapsuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeCapsuleImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String message;
  @override
  final String prediction;
  @override
  final DateTime createdAt;
  @override
  final DateTime deliveryDate;

  @override
  String toString() {
    return 'TimeCapsule(id: $id, userId: $userId, message: $message, prediction: $prediction, createdAt: $createdAt, deliveryDate: $deliveryDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeCapsuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.prediction, prediction) ||
                other.prediction == prediction) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deliveryDate, deliveryDate) ||
                other.deliveryDate == deliveryDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, message, prediction, createdAt, deliveryDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeCapsuleImplCopyWith<_$TimeCapsuleImpl> get copyWith =>
      __$$TimeCapsuleImplCopyWithImpl<_$TimeCapsuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeCapsuleImplToJson(
      this,
    );
  }
}

abstract class _TimeCapsule implements TimeCapsule {
  const factory _TimeCapsule(
      {required final String id,
      required final String userId,
      required final String message,
      required final String prediction,
      required final DateTime createdAt,
      required final DateTime deliveryDate}) = _$TimeCapsuleImpl;

  factory _TimeCapsule.fromJson(Map<String, dynamic> json) =
      _$TimeCapsuleImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get message;
  @override
  String get prediction;
  @override
  DateTime get createdAt;
  @override
  DateTime get deliveryDate;
  @override
  @JsonKey(ignore: true)
  _$$TimeCapsuleImplCopyWith<_$TimeCapsuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
