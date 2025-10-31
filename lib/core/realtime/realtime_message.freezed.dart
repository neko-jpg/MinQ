// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realtime_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RealtimeMessage _$RealtimeMessageFromJson(Map<String, dynamic> json) {
  return _RealtimeMessage.fromJson(json);
}

/// @nodoc
mixin _$RealtimeMessage {
  String get id => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String? get recipientId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RealtimeMessageCopyWith<RealtimeMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RealtimeMessageCopyWith<$Res> {
  factory $RealtimeMessageCopyWith(
          RealtimeMessage value, $Res Function(RealtimeMessage) then) =
      _$RealtimeMessageCopyWithImpl<$Res, RealtimeMessage>;
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String senderId,
      String? recipientId,
      DateTime timestamp,
      Map<String, dynamic> payload,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$RealtimeMessageCopyWithImpl<$Res, $Val extends RealtimeMessage>
    implements $RealtimeMessageCopyWith<$Res> {
  _$RealtimeMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? senderId = null,
    Object? recipientId = freezed,
    Object? timestamp = null,
    Object? payload = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: freezed == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RealtimeMessageImplCopyWith<$Res>
    implements $RealtimeMessageCopyWith<$Res> {
  factory _$$RealtimeMessageImplCopyWith(_$RealtimeMessageImpl value,
          $Res Function(_$RealtimeMessageImpl) then) =
      __$$RealtimeMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      MessageType type,
      String senderId,
      String? recipientId,
      DateTime timestamp,
      Map<String, dynamic> payload,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$RealtimeMessageImplCopyWithImpl<$Res>
    extends _$RealtimeMessageCopyWithImpl<$Res, _$RealtimeMessageImpl>
    implements _$$RealtimeMessageImplCopyWith<$Res> {
  __$$RealtimeMessageImplCopyWithImpl(
      _$RealtimeMessageImpl _value, $Res Function(_$RealtimeMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? senderId = null,
    Object? recipientId = freezed,
    Object? timestamp = null,
    Object? payload = null,
    Object? metadata = null,
  }) {
    return _then(_$RealtimeMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: freezed == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      payload: null == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RealtimeMessageImpl implements _RealtimeMessage {
  const _$RealtimeMessageImpl(
      {required this.id,
      required this.type,
      required this.senderId,
      this.recipientId,
      required this.timestamp,
      required final Map<String, dynamic> payload,
      final Map<String, dynamic> metadata = const {}})
      : _payload = payload,
        _metadata = metadata;

  factory _$RealtimeMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$RealtimeMessageImplFromJson(json);

  @override
  final String id;
  @override
  final MessageType type;
  @override
  final String senderId;
  @override
  final String? recipientId;
  @override
  final DateTime timestamp;
  final Map<String, dynamic> _payload;
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'RealtimeMessage(id: $id, type: $type, senderId: $senderId, recipientId: $recipientId, timestamp: $timestamp, payload: $payload, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RealtimeMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      senderId,
      recipientId,
      timestamp,
      const DeepCollectionEquality().hash(_payload),
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RealtimeMessageImplCopyWith<_$RealtimeMessageImpl> get copyWith =>
      __$$RealtimeMessageImplCopyWithImpl<_$RealtimeMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RealtimeMessageImplToJson(
      this,
    );
  }
}

abstract class _RealtimeMessage implements RealtimeMessage {
  const factory _RealtimeMessage(
      {required final String id,
      required final MessageType type,
      required final String senderId,
      final String? recipientId,
      required final DateTime timestamp,
      required final Map<String, dynamic> payload,
      final Map<String, dynamic> metadata}) = _$RealtimeMessageImpl;

  factory _RealtimeMessage.fromJson(Map<String, dynamic> json) =
      _$RealtimeMessageImpl.fromJson;

  @override
  String get id;
  @override
  MessageType get type;
  @override
  String get senderId;
  @override
  String? get recipientId;
  @override
  DateTime get timestamp;
  @override
  Map<String, dynamic> get payload;
  @override
  Map<String, dynamic> get metadata;
  @override
  @JsonKey(ignore: true)
  _$$RealtimeMessageImplCopyWith<_$RealtimeMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
