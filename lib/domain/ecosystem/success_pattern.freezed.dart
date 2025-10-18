// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'success_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SuccessPattern _$SuccessPatternFromJson(Map<String, dynamic> json) {
  return _SuccessPattern.fromJson(json);
}

/// @nodoc
mixin _$SuccessPattern {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // e.g., "Completing 'Morning Run' increases 'Healthy Breakfast' success by 40%"
  List<String> get relatedHabitIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SuccessPatternCopyWith<SuccessPattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuccessPatternCopyWith<$Res> {
  factory $SuccessPatternCopyWith(
          SuccessPattern value, $Res Function(SuccessPattern) then) =
      _$SuccessPatternCopyWithImpl<$Res, SuccessPattern>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String description,
      List<String> relatedHabitIds});
}

/// @nodoc
class _$SuccessPatternCopyWithImpl<$Res, $Val extends SuccessPattern>
    implements $SuccessPatternCopyWith<$Res> {
  _$SuccessPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? description = null,
    Object? relatedHabitIds = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      relatedHabitIds: null == relatedHabitIds
          ? _value.relatedHabitIds
          : relatedHabitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SuccessPatternImplCopyWith<$Res>
    implements $SuccessPatternCopyWith<$Res> {
  factory _$$SuccessPatternImplCopyWith(_$SuccessPatternImpl value,
          $Res Function(_$SuccessPatternImpl) then) =
      __$$SuccessPatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String description,
      List<String> relatedHabitIds});
}

/// @nodoc
class __$$SuccessPatternImplCopyWithImpl<$Res>
    extends _$SuccessPatternCopyWithImpl<$Res, _$SuccessPatternImpl>
    implements _$$SuccessPatternImplCopyWith<$Res> {
  __$$SuccessPatternImplCopyWithImpl(
      _$SuccessPatternImpl _value, $Res Function(_$SuccessPatternImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? description = null,
    Object? relatedHabitIds = null,
  }) {
    return _then(_$SuccessPatternImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      relatedHabitIds: null == relatedHabitIds
          ? _value._relatedHabitIds
          : relatedHabitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SuccessPatternImpl implements _SuccessPattern {
  const _$SuccessPatternImpl(
      {required this.id,
      required this.userId,
      required this.description,
      required final List<String> relatedHabitIds})
      : _relatedHabitIds = relatedHabitIds;

  factory _$SuccessPatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$SuccessPatternImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String description;
// e.g., "Completing 'Morning Run' increases 'Healthy Breakfast' success by 40%"
  final List<String> _relatedHabitIds;
// e.g., "Completing 'Morning Run' increases 'Healthy Breakfast' success by 40%"
  @override
  List<String> get relatedHabitIds {
    if (_relatedHabitIds is EqualUnmodifiableListView) return _relatedHabitIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedHabitIds);
  }

  @override
  String toString() {
    return 'SuccessPattern(id: $id, userId: $userId, description: $description, relatedHabitIds: $relatedHabitIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessPatternImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._relatedHabitIds, _relatedHabitIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, description,
      const DeepCollectionEquality().hash(_relatedHabitIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessPatternImplCopyWith<_$SuccessPatternImpl> get copyWith =>
      __$$SuccessPatternImplCopyWithImpl<_$SuccessPatternImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SuccessPatternImplToJson(
      this,
    );
  }
}

abstract class _SuccessPattern implements SuccessPattern {
  const factory _SuccessPattern(
      {required final String id,
      required final String userId,
      required final String description,
      required final List<String> relatedHabitIds}) = _$SuccessPatternImpl;

  factory _SuccessPattern.fromJson(Map<String, dynamic> json) =
      _$SuccessPatternImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get description;
  @override // e.g., "Completing 'Morning Run' increases 'Healthy Breakfast' success by 40%"
  List<String> get relatedHabitIds;
  @override
  @JsonKey(ignore: true)
  _$$SuccessPatternImplCopyWith<_$SuccessPatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
