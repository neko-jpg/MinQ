// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure_prediction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FailurePredictionModel _$FailurePredictionModelFromJson(
    Map<String, dynamic> json) {
  return _FailurePredictionModel.fromJson(json);
}

/// @nodoc
mixin _$FailurePredictionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get habitId => throw _privateConstructorUsedError;
  double get predictionScore =>
      throw _privateConstructorUsedError; // 0.0 to 1.0
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FailurePredictionModelCopyWith<FailurePredictionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailurePredictionModelCopyWith<$Res> {
  factory $FailurePredictionModelCopyWith(FailurePredictionModel value,
          $Res Function(FailurePredictionModel) then) =
      _$FailurePredictionModelCopyWithImpl<$Res, FailurePredictionModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String habitId,
      double predictionScore,
      DateTime createdAt});
}

/// @nodoc
class _$FailurePredictionModelCopyWithImpl<$Res,
        $Val extends FailurePredictionModel>
    implements $FailurePredictionModelCopyWith<$Res> {
  _$FailurePredictionModelCopyWithImpl(this._value, this._then);

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
    Object? predictionScore = null,
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
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      predictionScore: null == predictionScore
          ? _value.predictionScore
          : predictionScore // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FailurePredictionModelImplCopyWith<$Res>
    implements $FailurePredictionModelCopyWith<$Res> {
  factory _$$FailurePredictionModelImplCopyWith(
          _$FailurePredictionModelImpl value,
          $Res Function(_$FailurePredictionModelImpl) then) =
      __$$FailurePredictionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String habitId,
      double predictionScore,
      DateTime createdAt});
}

/// @nodoc
class __$$FailurePredictionModelImplCopyWithImpl<$Res>
    extends _$FailurePredictionModelCopyWithImpl<$Res,
        _$FailurePredictionModelImpl>
    implements _$$FailurePredictionModelImplCopyWith<$Res> {
  __$$FailurePredictionModelImplCopyWithImpl(
      _$FailurePredictionModelImpl _value,
      $Res Function(_$FailurePredictionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? habitId = null,
    Object? predictionScore = null,
    Object? createdAt = null,
  }) {
    return _then(_$FailurePredictionModelImpl(
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
      predictionScore: null == predictionScore
          ? _value.predictionScore
          : predictionScore // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FailurePredictionModelImpl implements _FailurePredictionModel {
  const _$FailurePredictionModelImpl(
      {required this.id,
      required this.userId,
      required this.habitId,
      required this.predictionScore,
      required this.createdAt});

  factory _$FailurePredictionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FailurePredictionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String habitId;
  @override
  final double predictionScore;
// 0.0 to 1.0
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FailurePredictionModel(id: $id, userId: $userId, habitId: $habitId, predictionScore: $predictionScore, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailurePredictionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.predictionScore, predictionScore) ||
                other.predictionScore == predictionScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, habitId, predictionScore, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FailurePredictionModelImplCopyWith<_$FailurePredictionModelImpl>
      get copyWith => __$$FailurePredictionModelImplCopyWithImpl<
          _$FailurePredictionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FailurePredictionModelImplToJson(
      this,
    );
  }
}

abstract class _FailurePredictionModel implements FailurePredictionModel {
  const factory _FailurePredictionModel(
      {required final String id,
      required final String userId,
      required final String habitId,
      required final double predictionScore,
      required final DateTime createdAt}) = _$FailurePredictionModelImpl;

  factory _FailurePredictionModel.fromJson(Map<String, dynamic> json) =
      _$FailurePredictionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get habitId;
  @override
  double get predictionScore;
  @override // 0.0 to 1.0
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$FailurePredictionModelImplCopyWith<_$FailurePredictionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
