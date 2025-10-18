// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_coach_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AICoachState _$AICoachStateFromJson(Map<String, dynamic> json) {
  return _AICoachState.fromJson(json);
}

/// @nodoc
mixin _$AICoachState {
  String get userId => throw _privateConstructorUsedError;
  List<ChatMessage> get conversationHistory =>
      throw _privateConstructorUsedError;
  bool get isTyping => throw _privateConstructorUsedError;
  DateTime get lastInteraction => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AICoachStateCopyWith<AICoachState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AICoachStateCopyWith<$Res> {
  factory $AICoachStateCopyWith(
          AICoachState value, $Res Function(AICoachState) then) =
      _$AICoachStateCopyWithImpl<$Res, AICoachState>;
  @useResult
  $Res call(
      {String userId,
      List<ChatMessage> conversationHistory,
      bool isTyping,
      DateTime lastInteraction});
}

/// @nodoc
class _$AICoachStateCopyWithImpl<$Res, $Val extends AICoachState>
    implements $AICoachStateCopyWith<$Res> {
  _$AICoachStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? conversationHistory = null,
    Object? isTyping = null,
    Object? lastInteraction = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationHistory: null == conversationHistory
          ? _value.conversationHistory
          : conversationHistory // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      isTyping: null == isTyping
          ? _value.isTyping
          : isTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      lastInteraction: null == lastInteraction
          ? _value.lastInteraction
          : lastInteraction // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AICoachStateImplCopyWith<$Res>
    implements $AICoachStateCopyWith<$Res> {
  factory _$$AICoachStateImplCopyWith(
          _$AICoachStateImpl value, $Res Function(_$AICoachStateImpl) then) =
      __$$AICoachStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      List<ChatMessage> conversationHistory,
      bool isTyping,
      DateTime lastInteraction});
}

/// @nodoc
class __$$AICoachStateImplCopyWithImpl<$Res>
    extends _$AICoachStateCopyWithImpl<$Res, _$AICoachStateImpl>
    implements _$$AICoachStateImplCopyWith<$Res> {
  __$$AICoachStateImplCopyWithImpl(
      _$AICoachStateImpl _value, $Res Function(_$AICoachStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? conversationHistory = null,
    Object? isTyping = null,
    Object? lastInteraction = null,
  }) {
    return _then(_$AICoachStateImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationHistory: null == conversationHistory
          ? _value._conversationHistory
          : conversationHistory // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      isTyping: null == isTyping
          ? _value.isTyping
          : isTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      lastInteraction: null == lastInteraction
          ? _value.lastInteraction
          : lastInteraction // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AICoachStateImpl implements _AICoachState {
  const _$AICoachStateImpl(
      {required this.userId,
      required final List<ChatMessage> conversationHistory,
      required this.isTyping,
      required this.lastInteraction})
      : _conversationHistory = conversationHistory;

  factory _$AICoachStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AICoachStateImplFromJson(json);

  @override
  final String userId;
  final List<ChatMessage> _conversationHistory;
  @override
  List<ChatMessage> get conversationHistory {
    if (_conversationHistory is EqualUnmodifiableListView)
      return _conversationHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversationHistory);
  }

  @override
  final bool isTyping;
  @override
  final DateTime lastInteraction;

  @override
  String toString() {
    return 'AICoachState(userId: $userId, conversationHistory: $conversationHistory, isTyping: $isTyping, lastInteraction: $lastInteraction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AICoachStateImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._conversationHistory, _conversationHistory) &&
            (identical(other.isTyping, isTyping) ||
                other.isTyping == isTyping) &&
            (identical(other.lastInteraction, lastInteraction) ||
                other.lastInteraction == lastInteraction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      const DeepCollectionEquality().hash(_conversationHistory),
      isTyping,
      lastInteraction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AICoachStateImplCopyWith<_$AICoachStateImpl> get copyWith =>
      __$$AICoachStateImplCopyWithImpl<_$AICoachStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AICoachStateImplToJson(
      this,
    );
  }
}

abstract class _AICoachState implements AICoachState {
  const factory _AICoachState(
      {required final String userId,
      required final List<ChatMessage> conversationHistory,
      required final bool isTyping,
      required final DateTime lastInteraction}) = _$AICoachStateImpl;

  factory _AICoachState.fromJson(Map<String, dynamic> json) =
      _$AICoachStateImpl.fromJson;

  @override
  String get userId;
  @override
  List<ChatMessage> get conversationHistory;
  @override
  bool get isTyping;
  @override
  DateTime get lastInteraction;
  @override
  @JsonKey(ignore: true)
  _$$AICoachStateImplCopyWith<_$AICoachStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
