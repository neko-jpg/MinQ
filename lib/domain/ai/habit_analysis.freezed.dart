// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HabitAnalysis _$HabitAnalysisFromJson(Map<String, dynamic> json) {
  return _HabitAnalysis.fromJson(json);
}

/// @nodoc
mixin _$HabitAnalysis {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get habitId => throw _privateConstructorUsedError;
  double get successRate => throw _privateConstructorUsedError;
  Map<String, double> get successByDay =>
      throw _privateConstructorUsedError; // e.g., {'Monday': 0.8, ...}
  Map<String, double> get successByTime =>
      throw _privateConstructorUsedError; // e.g., {'Morning': 0.9, ...}
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HabitAnalysisCopyWith<HabitAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitAnalysisCopyWith<$Res> {
  factory $HabitAnalysisCopyWith(
          HabitAnalysis value, $Res Function(HabitAnalysis) then) =
      _$HabitAnalysisCopyWithImpl<$Res, HabitAnalysis>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String habitId,
      double successRate,
      Map<String, double> successByDay,
      Map<String, double> successByTime,
      DateTime lastUpdated});
}

/// @nodoc
class _$HabitAnalysisCopyWithImpl<$Res, $Val extends HabitAnalysis>
    implements $HabitAnalysisCopyWith<$Res> {
  _$HabitAnalysisCopyWithImpl(this._value, this._then);

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
    Object? successRate = null,
    Object? successByDay = null,
    Object? successByTime = null,
    Object? lastUpdated = null,
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
      successRate: null == successRate
          ? _value.successRate
          : successRate // ignore: cast_nullable_to_non_nullable
              as double,
      successByDay: null == successByDay
          ? _value.successByDay
          : successByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      successByTime: null == successByTime
          ? _value.successByTime
          : successByTime // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitAnalysisImplCopyWith<$Res>
    implements $HabitAnalysisCopyWith<$Res> {
  factory _$$HabitAnalysisImplCopyWith(
          _$HabitAnalysisImpl value, $Res Function(_$HabitAnalysisImpl) then) =
      __$$HabitAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String habitId,
      double successRate,
      Map<String, double> successByDay,
      Map<String, double> successByTime,
      DateTime lastUpdated});
}

/// @nodoc
class __$$HabitAnalysisImplCopyWithImpl<$Res>
    extends _$HabitAnalysisCopyWithImpl<$Res, _$HabitAnalysisImpl>
    implements _$$HabitAnalysisImplCopyWith<$Res> {
  __$$HabitAnalysisImplCopyWithImpl(
      _$HabitAnalysisImpl _value, $Res Function(_$HabitAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? habitId = null,
    Object? successRate = null,
    Object? successByDay = null,
    Object? successByTime = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$HabitAnalysisImpl(
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
      successRate: null == successRate
          ? _value.successRate
          : successRate // ignore: cast_nullable_to_non_nullable
              as double,
      successByDay: null == successByDay
          ? _value._successByDay
          : successByDay // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      successByTime: null == successByTime
          ? _value._successByTime
          : successByTime // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitAnalysisImpl implements _HabitAnalysis {
  const _$HabitAnalysisImpl(
      {required this.id,
      required this.userId,
      required this.habitId,
      required this.successRate,
      required final Map<String, double> successByDay,
      required final Map<String, double> successByTime,
      required this.lastUpdated})
      : _successByDay = successByDay,
        _successByTime = successByTime;

  factory _$HabitAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitAnalysisImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String habitId;
  @override
  final double successRate;
  final Map<String, double> _successByDay;
  @override
  Map<String, double> get successByDay {
    if (_successByDay is EqualUnmodifiableMapView) return _successByDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_successByDay);
  }

// e.g., {'Monday': 0.8, ...}
  final Map<String, double> _successByTime;
// e.g., {'Monday': 0.8, ...}
  @override
  Map<String, double> get successByTime {
    if (_successByTime is EqualUnmodifiableMapView) return _successByTime;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_successByTime);
  }

// e.g., {'Morning': 0.9, ...}
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'HabitAnalysis(id: $id, userId: $userId, habitId: $habitId, successRate: $successRate, successByDay: $successByDay, successByTime: $successByTime, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitAnalysisImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.successRate, successRate) ||
                other.successRate == successRate) &&
            const DeepCollectionEquality()
                .equals(other._successByDay, _successByDay) &&
            const DeepCollectionEquality()
                .equals(other._successByTime, _successByTime) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      habitId,
      successRate,
      const DeepCollectionEquality().hash(_successByDay),
      const DeepCollectionEquality().hash(_successByTime),
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitAnalysisImplCopyWith<_$HabitAnalysisImpl> get copyWith =>
      __$$HabitAnalysisImplCopyWithImpl<_$HabitAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitAnalysisImplToJson(
      this,
    );
  }
}

abstract class _HabitAnalysis implements HabitAnalysis {
  const factory _HabitAnalysis(
      {required final String id,
      required final String userId,
      required final String habitId,
      required final double successRate,
      required final Map<String, double> successByDay,
      required final Map<String, double> successByTime,
      required final DateTime lastUpdated}) = _$HabitAnalysisImpl;

  factory _HabitAnalysis.fromJson(Map<String, dynamic> json) =
      _$HabitAnalysisImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get habitId;
  @override
  double get successRate;
  @override
  Map<String, double> get successByDay;
  @override // e.g., {'Monday': 0.8, ...}
  Map<String, double> get successByTime;
  @override // e.g., {'Morning': 0.9, ...}
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$HabitAnalysisImplCopyWith<_$HabitAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
