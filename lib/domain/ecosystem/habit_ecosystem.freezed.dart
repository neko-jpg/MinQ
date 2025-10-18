// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_ecosystem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HabitEcosystem _$HabitEcosystemFromJson(Map<String, dynamic> json) {
  return _HabitEcosystem.fromJson(json);
}

/// @nodoc
mixin _$HabitEcosystem {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Map<String, List<String>> get connections =>
      throw _privateConstructorUsedError; // habitId -> list of connected habitIds
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HabitEcosystemCopyWith<HabitEcosystem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitEcosystemCopyWith<$Res> {
  factory $HabitEcosystemCopyWith(
          HabitEcosystem value, $Res Function(HabitEcosystem) then) =
      _$HabitEcosystemCopyWithImpl<$Res, HabitEcosystem>;
  @useResult
  $Res call(
      {String id,
      String userId,
      Map<String, List<String>> connections,
      DateTime lastUpdated});
}

/// @nodoc
class _$HabitEcosystemCopyWithImpl<$Res, $Val extends HabitEcosystem>
    implements $HabitEcosystemCopyWith<$Res> {
  _$HabitEcosystemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? connections = null,
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
      connections: null == connections
          ? _value.connections
          : connections // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitEcosystemImplCopyWith<$Res>
    implements $HabitEcosystemCopyWith<$Res> {
  factory _$$HabitEcosystemImplCopyWith(_$HabitEcosystemImpl value,
          $Res Function(_$HabitEcosystemImpl) then) =
      __$$HabitEcosystemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      Map<String, List<String>> connections,
      DateTime lastUpdated});
}

/// @nodoc
class __$$HabitEcosystemImplCopyWithImpl<$Res>
    extends _$HabitEcosystemCopyWithImpl<$Res, _$HabitEcosystemImpl>
    implements _$$HabitEcosystemImplCopyWith<$Res> {
  __$$HabitEcosystemImplCopyWithImpl(
      _$HabitEcosystemImpl _value, $Res Function(_$HabitEcosystemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? connections = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$HabitEcosystemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      connections: null == connections
          ? _value._connections
          : connections // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitEcosystemImpl implements _HabitEcosystem {
  const _$HabitEcosystemImpl(
      {required this.id,
      required this.userId,
      required final Map<String, List<String>> connections,
      required this.lastUpdated})
      : _connections = connections;

  factory _$HabitEcosystemImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitEcosystemImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  final Map<String, List<String>> _connections;
  @override
  Map<String, List<String>> get connections {
    if (_connections is EqualUnmodifiableMapView) return _connections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_connections);
  }

// habitId -> list of connected habitIds
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'HabitEcosystem(id: $id, userId: $userId, connections: $connections, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitEcosystemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._connections, _connections) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId,
      const DeepCollectionEquality().hash(_connections), lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitEcosystemImplCopyWith<_$HabitEcosystemImpl> get copyWith =>
      __$$HabitEcosystemImplCopyWithImpl<_$HabitEcosystemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitEcosystemImplToJson(
      this,
    );
  }
}

abstract class _HabitEcosystem implements HabitEcosystem {
  const factory _HabitEcosystem(
      {required final String id,
      required final String userId,
      required final Map<String, List<String>> connections,
      required final DateTime lastUpdated}) = _$HabitEcosystemImpl;

  factory _HabitEcosystem.fromJson(Map<String, dynamic> json) =
      _$HabitEcosystemImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  Map<String, List<String>> get connections;
  @override // habitId -> list of connected habitIds
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$HabitEcosystemImplCopyWith<_$HabitEcosystemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
