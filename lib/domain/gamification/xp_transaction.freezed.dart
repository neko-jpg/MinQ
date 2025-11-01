// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xp_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

XPTransaction _$XPTransactionFromJson(Map<String, dynamic> json) {
  return _XPTransaction.fromJson(json);
}

/// @nodoc
mixin _$XPTransaction {
  int get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get xpAmount => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  XPSource get source => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  double? get multiplier => throw _privateConstructorUsedError;
  int? get streakBonus => throw _privateConstructorUsedError;
  int? get difficultyBonus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $XPTransactionCopyWith<XPTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XPTransactionCopyWith<$Res> {
  factory $XPTransactionCopyWith(
          XPTransaction value, $Res Function(XPTransaction) then) =
      _$XPTransactionCopyWithImpl<$Res, XPTransaction>;
  @useResult
  $Res call(
      {int id,
      String userId,
      int xpAmount,
      String reason,
      XPSource source,
      DateTime createdAt,
      Map<String, dynamic>? metadata,
      double? multiplier,
      int? streakBonus,
      int? difficultyBonus});
}

/// @nodoc
class _$XPTransactionCopyWithImpl<$Res, $Val extends XPTransaction>
    implements $XPTransactionCopyWith<$Res> {
  _$XPTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? xpAmount = null,
    Object? reason = null,
    Object? source = null,
    Object? createdAt = null,
    Object? metadata = freezed,
    Object? multiplier = freezed,
    Object? streakBonus = freezed,
    Object? difficultyBonus = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      xpAmount: null == xpAmount
          ? _value.xpAmount
          : xpAmount // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as XPSource,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      multiplier: freezed == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      streakBonus: freezed == streakBonus
          ? _value.streakBonus
          : streakBonus // ignore: cast_nullable_to_non_nullable
              as int?,
      difficultyBonus: freezed == difficultyBonus
          ? _value.difficultyBonus
          : difficultyBonus // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$XPTransactionImplCopyWith<$Res>
    implements $XPTransactionCopyWith<$Res> {
  factory _$$XPTransactionImplCopyWith(
          _$XPTransactionImpl value, $Res Function(_$XPTransactionImpl) then) =
      __$$XPTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String userId,
      int xpAmount,
      String reason,
      XPSource source,
      DateTime createdAt,
      Map<String, dynamic>? metadata,
      double? multiplier,
      int? streakBonus,
      int? difficultyBonus});
}

/// @nodoc
class __$$XPTransactionImplCopyWithImpl<$Res>
    extends _$XPTransactionCopyWithImpl<$Res, _$XPTransactionImpl>
    implements _$$XPTransactionImplCopyWith<$Res> {
  __$$XPTransactionImplCopyWithImpl(
      _$XPTransactionImpl _value, $Res Function(_$XPTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? xpAmount = null,
    Object? reason = null,
    Object? source = null,
    Object? createdAt = null,
    Object? metadata = freezed,
    Object? multiplier = freezed,
    Object? streakBonus = freezed,
    Object? difficultyBonus = freezed,
  }) {
    return _then(_$XPTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      xpAmount: null == xpAmount
          ? _value.xpAmount
          : xpAmount // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as XPSource,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      multiplier: freezed == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      streakBonus: freezed == streakBonus
          ? _value.streakBonus
          : streakBonus // ignore: cast_nullable_to_non_nullable
              as int?,
      difficultyBonus: freezed == difficultyBonus
          ? _value.difficultyBonus
          : difficultyBonus // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$XPTransactionImpl implements _XPTransaction {
  const _$XPTransactionImpl(
      {this.id = 0,
      required this.userId,
      required this.xpAmount,
      required this.reason,
      required this.source,
      required this.createdAt,
      final Map<String, dynamic>? metadata,
      this.multiplier,
      this.streakBonus,
      this.difficultyBonus})
      : _metadata = metadata;

  factory _$XPTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$XPTransactionImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String userId;
  @override
  final int xpAmount;
  @override
  final String reason;
  @override
  final XPSource source;
  @override
  final DateTime createdAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final double? multiplier;
  @override
  final int? streakBonus;
  @override
  final int? difficultyBonus;

  @override
  String toString() {
    return 'XPTransaction(id: $id, userId: $userId, xpAmount: $xpAmount, reason: $reason, source: $source, createdAt: $createdAt, metadata: $metadata, multiplier: $multiplier, streakBonus: $streakBonus, difficultyBonus: $difficultyBonus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$XPTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.xpAmount, xpAmount) ||
                other.xpAmount == xpAmount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier) &&
            (identical(other.streakBonus, streakBonus) ||
                other.streakBonus == streakBonus) &&
            (identical(other.difficultyBonus, difficultyBonus) ||
                other.difficultyBonus == difficultyBonus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      xpAmount,
      reason,
      source,
      createdAt,
      const DeepCollectionEquality().hash(_metadata),
      multiplier,
      streakBonus,
      difficultyBonus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$XPTransactionImplCopyWith<_$XPTransactionImpl> get copyWith =>
      __$$XPTransactionImplCopyWithImpl<_$XPTransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$XPTransactionImplToJson(
      this,
    );
  }
}

abstract class _XPTransaction implements XPTransaction {
  const factory _XPTransaction(
      {final int id,
      required final String userId,
      required final int xpAmount,
      required final String reason,
      required final XPSource source,
      required final DateTime createdAt,
      final Map<String, dynamic>? metadata,
      final double? multiplier,
      final int? streakBonus,
      final int? difficultyBonus}) = _$XPTransactionImpl;

  factory _XPTransaction.fromJson(Map<String, dynamic> json) =
      _$XPTransactionImpl.fromJson;

  @override
  int get id;
  @override
  String get userId;
  @override
  int get xpAmount;
  @override
  String get reason;
  @override
  XPSource get source;
  @override
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get metadata;
  @override
  double? get multiplier;
  @override
  int? get streakBonus;
  @override
  int? get difficultyBonus;
  @override
  @JsonKey(ignore: true)
  _$$XPTransactionImplCopyWith<_$XPTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

XPGainResult _$XPGainResultFromJson(Map<String, dynamic> json) {
  return _XPGainResult.fromJson(json);
}

/// @nodoc
mixin _$XPGainResult {
  int get xpGained => throw _privateConstructorUsedError;
  int get newTotalXP => throw _privateConstructorUsedError;
  int get previousLevel => throw _privateConstructorUsedError;
  int get newLevel => throw _privateConstructorUsedError;
  bool get leveledUp => throw _privateConstructorUsedError;
  List<String> get newRewards => throw _privateConstructorUsedError;
  XPTransaction get transaction => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $XPGainResultCopyWith<XPGainResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XPGainResultCopyWith<$Res> {
  factory $XPGainResultCopyWith(
          XPGainResult value, $Res Function(XPGainResult) then) =
      _$XPGainResultCopyWithImpl<$Res, XPGainResult>;
  @useResult
  $Res call(
      {int xpGained,
      int newTotalXP,
      int previousLevel,
      int newLevel,
      bool leveledUp,
      List<String> newRewards,
      XPTransaction transaction});

  $XPTransactionCopyWith<$Res> get transaction;
}

/// @nodoc
class _$XPGainResultCopyWithImpl<$Res, $Val extends XPGainResult>
    implements $XPGainResultCopyWith<$Res> {
  _$XPGainResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xpGained = null,
    Object? newTotalXP = null,
    Object? previousLevel = null,
    Object? newLevel = null,
    Object? leveledUp = null,
    Object? newRewards = null,
    Object? transaction = null,
  }) {
    return _then(_value.copyWith(
      xpGained: null == xpGained
          ? _value.xpGained
          : xpGained // ignore: cast_nullable_to_non_nullable
              as int,
      newTotalXP: null == newTotalXP
          ? _value.newTotalXP
          : newTotalXP // ignore: cast_nullable_to_non_nullable
              as int,
      previousLevel: null == previousLevel
          ? _value.previousLevel
          : previousLevel // ignore: cast_nullable_to_non_nullable
              as int,
      newLevel: null == newLevel
          ? _value.newLevel
          : newLevel // ignore: cast_nullable_to_non_nullable
              as int,
      leveledUp: null == leveledUp
          ? _value.leveledUp
          : leveledUp // ignore: cast_nullable_to_non_nullable
              as bool,
      newRewards: null == newRewards
          ? _value.newRewards
          : newRewards // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transaction: null == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as XPTransaction,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $XPTransactionCopyWith<$Res> get transaction {
    return $XPTransactionCopyWith<$Res>(_value.transaction, (value) {
      return _then(_value.copyWith(transaction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$XPGainResultImplCopyWith<$Res>
    implements $XPGainResultCopyWith<$Res> {
  factory _$$XPGainResultImplCopyWith(
          _$XPGainResultImpl value, $Res Function(_$XPGainResultImpl) then) =
      __$$XPGainResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int xpGained,
      int newTotalXP,
      int previousLevel,
      int newLevel,
      bool leveledUp,
      List<String> newRewards,
      XPTransaction transaction});

  @override
  $XPTransactionCopyWith<$Res> get transaction;
}

/// @nodoc
class __$$XPGainResultImplCopyWithImpl<$Res>
    extends _$XPGainResultCopyWithImpl<$Res, _$XPGainResultImpl>
    implements _$$XPGainResultImplCopyWith<$Res> {
  __$$XPGainResultImplCopyWithImpl(
      _$XPGainResultImpl _value, $Res Function(_$XPGainResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xpGained = null,
    Object? newTotalXP = null,
    Object? previousLevel = null,
    Object? newLevel = null,
    Object? leveledUp = null,
    Object? newRewards = null,
    Object? transaction = null,
  }) {
    return _then(_$XPGainResultImpl(
      xpGained: null == xpGained
          ? _value.xpGained
          : xpGained // ignore: cast_nullable_to_non_nullable
              as int,
      newTotalXP: null == newTotalXP
          ? _value.newTotalXP
          : newTotalXP // ignore: cast_nullable_to_non_nullable
              as int,
      previousLevel: null == previousLevel
          ? _value.previousLevel
          : previousLevel // ignore: cast_nullable_to_non_nullable
              as int,
      newLevel: null == newLevel
          ? _value.newLevel
          : newLevel // ignore: cast_nullable_to_non_nullable
              as int,
      leveledUp: null == leveledUp
          ? _value.leveledUp
          : leveledUp // ignore: cast_nullable_to_non_nullable
              as bool,
      newRewards: null == newRewards
          ? _value._newRewards
          : newRewards // ignore: cast_nullable_to_non_nullable
              as List<String>,
      transaction: null == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as XPTransaction,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$XPGainResultImpl implements _XPGainResult {
  const _$XPGainResultImpl(
      {required this.xpGained,
      required this.newTotalXP,
      required this.previousLevel,
      required this.newLevel,
      required this.leveledUp,
      required final List<String> newRewards,
      required this.transaction})
      : _newRewards = newRewards;

  factory _$XPGainResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$XPGainResultImplFromJson(json);

  @override
  final int xpGained;
  @override
  final int newTotalXP;
  @override
  final int previousLevel;
  @override
  final int newLevel;
  @override
  final bool leveledUp;
  final List<String> _newRewards;
  @override
  List<String> get newRewards {
    if (_newRewards is EqualUnmodifiableListView) return _newRewards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_newRewards);
  }

  @override
  final XPTransaction transaction;

  @override
  String toString() {
    return 'XPGainResult(xpGained: $xpGained, newTotalXP: $newTotalXP, previousLevel: $previousLevel, newLevel: $newLevel, leveledUp: $leveledUp, newRewards: $newRewards, transaction: $transaction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$XPGainResultImpl &&
            (identical(other.xpGained, xpGained) ||
                other.xpGained == xpGained) &&
            (identical(other.newTotalXP, newTotalXP) ||
                other.newTotalXP == newTotalXP) &&
            (identical(other.previousLevel, previousLevel) ||
                other.previousLevel == previousLevel) &&
            (identical(other.newLevel, newLevel) ||
                other.newLevel == newLevel) &&
            (identical(other.leveledUp, leveledUp) ||
                other.leveledUp == leveledUp) &&
            const DeepCollectionEquality()
                .equals(other._newRewards, _newRewards) &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      xpGained,
      newTotalXP,
      previousLevel,
      newLevel,
      leveledUp,
      const DeepCollectionEquality().hash(_newRewards),
      transaction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$XPGainResultImplCopyWith<_$XPGainResultImpl> get copyWith =>
      __$$XPGainResultImplCopyWithImpl<_$XPGainResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$XPGainResultImplToJson(
      this,
    );
  }
}

abstract class _XPGainResult implements XPGainResult {
  const factory _XPGainResult(
      {required final int xpGained,
      required final int newTotalXP,
      required final int previousLevel,
      required final int newLevel,
      required final bool leveledUp,
      required final List<String> newRewards,
      required final XPTransaction transaction}) = _$XPGainResultImpl;

  factory _XPGainResult.fromJson(Map<String, dynamic> json) =
      _$XPGainResultImpl.fromJson;

  @override
  int get xpGained;
  @override
  int get newTotalXP;
  @override
  int get previousLevel;
  @override
  int get newLevel;
  @override
  bool get leveledUp;
  @override
  List<String> get newRewards;
  @override
  XPTransaction get transaction;
  @override
  @JsonKey(ignore: true)
  _$$XPGainResultImplCopyWith<_$XPGainResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LevelInfo _$LevelInfoFromJson(Map<String, dynamic> json) {
  return _LevelInfo.fromJson(json);
}

/// @nodoc
mixin _$LevelInfo {
  int get level => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get minXP => throw _privateConstructorUsedError;
  int get maxXP => throw _privateConstructorUsedError;
  List<String> get rewards => throw _privateConstructorUsedError;
  List<String> get unlockedFeatures => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LevelInfoCopyWith<LevelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelInfoCopyWith<$Res> {
  factory $LevelInfoCopyWith(LevelInfo value, $Res Function(LevelInfo) then) =
      _$LevelInfoCopyWithImpl<$Res, LevelInfo>;
  @useResult
  $Res call(
      {int level,
      String name,
      String description,
      int minXP,
      int maxXP,
      List<String> rewards,
      List<String> unlockedFeatures});
}

/// @nodoc
class _$LevelInfoCopyWithImpl<$Res, $Val extends LevelInfo>
    implements $LevelInfoCopyWith<$Res> {
  _$LevelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? name = null,
    Object? description = null,
    Object? minXP = null,
    Object? maxXP = null,
    Object? rewards = null,
    Object? unlockedFeatures = null,
  }) {
    return _then(_value.copyWith(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      minXP: null == minXP
          ? _value.minXP
          : minXP // ignore: cast_nullable_to_non_nullable
              as int,
      maxXP: null == maxXP
          ? _value.maxXP
          : maxXP // ignore: cast_nullable_to_non_nullable
              as int,
      rewards: null == rewards
          ? _value.rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unlockedFeatures: null == unlockedFeatures
          ? _value.unlockedFeatures
          : unlockedFeatures // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelInfoImplCopyWith<$Res>
    implements $LevelInfoCopyWith<$Res> {
  factory _$$LevelInfoImplCopyWith(
          _$LevelInfoImpl value, $Res Function(_$LevelInfoImpl) then) =
      __$$LevelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int level,
      String name,
      String description,
      int minXP,
      int maxXP,
      List<String> rewards,
      List<String> unlockedFeatures});
}

/// @nodoc
class __$$LevelInfoImplCopyWithImpl<$Res>
    extends _$LevelInfoCopyWithImpl<$Res, _$LevelInfoImpl>
    implements _$$LevelInfoImplCopyWith<$Res> {
  __$$LevelInfoImplCopyWithImpl(
      _$LevelInfoImpl _value, $Res Function(_$LevelInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? name = null,
    Object? description = null,
    Object? minXP = null,
    Object? maxXP = null,
    Object? rewards = null,
    Object? unlockedFeatures = null,
  }) {
    return _then(_$LevelInfoImpl(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      minXP: null == minXP
          ? _value.minXP
          : minXP // ignore: cast_nullable_to_non_nullable
              as int,
      maxXP: null == maxXP
          ? _value.maxXP
          : maxXP // ignore: cast_nullable_to_non_nullable
              as int,
      rewards: null == rewards
          ? _value._rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unlockedFeatures: null == unlockedFeatures
          ? _value._unlockedFeatures
          : unlockedFeatures // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelInfoImpl implements _LevelInfo {
  const _$LevelInfoImpl(
      {required this.level,
      required this.name,
      required this.description,
      required this.minXP,
      required this.maxXP,
      required final List<String> rewards,
      required final List<String> unlockedFeatures})
      : _rewards = rewards,
        _unlockedFeatures = unlockedFeatures;

  factory _$LevelInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelInfoImplFromJson(json);

  @override
  final int level;
  @override
  final String name;
  @override
  final String description;
  @override
  final int minXP;
  @override
  final int maxXP;
  final List<String> _rewards;
  @override
  List<String> get rewards {
    if (_rewards is EqualUnmodifiableListView) return _rewards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rewards);
  }

  final List<String> _unlockedFeatures;
  @override
  List<String> get unlockedFeatures {
    if (_unlockedFeatures is EqualUnmodifiableListView)
      return _unlockedFeatures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unlockedFeatures);
  }

  @override
  String toString() {
    return 'LevelInfo(level: $level, name: $name, description: $description, minXP: $minXP, maxXP: $maxXP, rewards: $rewards, unlockedFeatures: $unlockedFeatures)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelInfoImpl &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.minXP, minXP) || other.minXP == minXP) &&
            (identical(other.maxXP, maxXP) || other.maxXP == maxXP) &&
            const DeepCollectionEquality().equals(other._rewards, _rewards) &&
            const DeepCollectionEquality()
                .equals(other._unlockedFeatures, _unlockedFeatures));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      level,
      name,
      description,
      minXP,
      maxXP,
      const DeepCollectionEquality().hash(_rewards),
      const DeepCollectionEquality().hash(_unlockedFeatures));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelInfoImplCopyWith<_$LevelInfoImpl> get copyWith =>
      __$$LevelInfoImplCopyWithImpl<_$LevelInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelInfoImplToJson(
      this,
    );
  }
}

abstract class _LevelInfo implements LevelInfo {
  const factory _LevelInfo(
      {required final int level,
      required final String name,
      required final String description,
      required final int minXP,
      required final int maxXP,
      required final List<String> rewards,
      required final List<String> unlockedFeatures}) = _$LevelInfoImpl;

  factory _LevelInfo.fromJson(Map<String, dynamic> json) =
      _$LevelInfoImpl.fromJson;

  @override
  int get level;
  @override
  String get name;
  @override
  String get description;
  @override
  int get minXP;
  @override
  int get maxXP;
  @override
  List<String> get rewards;
  @override
  List<String> get unlockedFeatures;
  @override
  @JsonKey(ignore: true)
  _$$LevelInfoImplCopyWith<_$LevelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserLevelProgress _$UserLevelProgressFromJson(Map<String, dynamic> json) {
  return _UserLevelProgress.fromJson(json);
}

/// @nodoc
mixin _$UserLevelProgress {
  int get currentLevel => throw _privateConstructorUsedError;
  String get currentLevelName => throw _privateConstructorUsedError;
  int get currentXP => throw _privateConstructorUsedError;
  int get xpToNextLevel => throw _privateConstructorUsedError;
  double get progressToNextLevel => throw _privateConstructorUsedError;
  bool get isMaxLevel => throw _privateConstructorUsedError;
  LevelInfo get currentLevelInfo => throw _privateConstructorUsedError;
  LevelInfo? get nextLevelInfo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserLevelProgressCopyWith<UserLevelProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLevelProgressCopyWith<$Res> {
  factory $UserLevelProgressCopyWith(
          UserLevelProgress value, $Res Function(UserLevelProgress) then) =
      _$UserLevelProgressCopyWithImpl<$Res, UserLevelProgress>;
  @useResult
  $Res call(
      {int currentLevel,
      String currentLevelName,
      int currentXP,
      int xpToNextLevel,
      double progressToNextLevel,
      bool isMaxLevel,
      LevelInfo currentLevelInfo,
      LevelInfo? nextLevelInfo});

  $LevelInfoCopyWith<$Res> get currentLevelInfo;
  $LevelInfoCopyWith<$Res>? get nextLevelInfo;
}

/// @nodoc
class _$UserLevelProgressCopyWithImpl<$Res, $Val extends UserLevelProgress>
    implements $UserLevelProgressCopyWith<$Res> {
  _$UserLevelProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? currentLevelName = null,
    Object? currentXP = null,
    Object? xpToNextLevel = null,
    Object? progressToNextLevel = null,
    Object? isMaxLevel = null,
    Object? currentLevelInfo = null,
    Object? nextLevelInfo = freezed,
  }) {
    return _then(_value.copyWith(
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      currentLevelName: null == currentLevelName
          ? _value.currentLevelName
          : currentLevelName // ignore: cast_nullable_to_non_nullable
              as String,
      currentXP: null == currentXP
          ? _value.currentXP
          : currentXP // ignore: cast_nullable_to_non_nullable
              as int,
      xpToNextLevel: null == xpToNextLevel
          ? _value.xpToNextLevel
          : xpToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      progressToNextLevel: null == progressToNextLevel
          ? _value.progressToNextLevel
          : progressToNextLevel // ignore: cast_nullable_to_non_nullable
              as double,
      isMaxLevel: null == isMaxLevel
          ? _value.isMaxLevel
          : isMaxLevel // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevelInfo: null == currentLevelInfo
          ? _value.currentLevelInfo
          : currentLevelInfo // ignore: cast_nullable_to_non_nullable
              as LevelInfo,
      nextLevelInfo: freezed == nextLevelInfo
          ? _value.nextLevelInfo
          : nextLevelInfo // ignore: cast_nullable_to_non_nullable
              as LevelInfo?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LevelInfoCopyWith<$Res> get currentLevelInfo {
    return $LevelInfoCopyWith<$Res>(_value.currentLevelInfo, (value) {
      return _then(_value.copyWith(currentLevelInfo: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LevelInfoCopyWith<$Res>? get nextLevelInfo {
    if (_value.nextLevelInfo == null) {
      return null;
    }

    return $LevelInfoCopyWith<$Res>(_value.nextLevelInfo!, (value) {
      return _then(_value.copyWith(nextLevelInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserLevelProgressImplCopyWith<$Res>
    implements $UserLevelProgressCopyWith<$Res> {
  factory _$$UserLevelProgressImplCopyWith(_$UserLevelProgressImpl value,
          $Res Function(_$UserLevelProgressImpl) then) =
      __$$UserLevelProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentLevel,
      String currentLevelName,
      int currentXP,
      int xpToNextLevel,
      double progressToNextLevel,
      bool isMaxLevel,
      LevelInfo currentLevelInfo,
      LevelInfo? nextLevelInfo});

  @override
  $LevelInfoCopyWith<$Res> get currentLevelInfo;
  @override
  $LevelInfoCopyWith<$Res>? get nextLevelInfo;
}

/// @nodoc
class __$$UserLevelProgressImplCopyWithImpl<$Res>
    extends _$UserLevelProgressCopyWithImpl<$Res, _$UserLevelProgressImpl>
    implements _$$UserLevelProgressImplCopyWith<$Res> {
  __$$UserLevelProgressImplCopyWithImpl(_$UserLevelProgressImpl _value,
      $Res Function(_$UserLevelProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? currentLevelName = null,
    Object? currentXP = null,
    Object? xpToNextLevel = null,
    Object? progressToNextLevel = null,
    Object? isMaxLevel = null,
    Object? currentLevelInfo = null,
    Object? nextLevelInfo = freezed,
  }) {
    return _then(_$UserLevelProgressImpl(
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      currentLevelName: null == currentLevelName
          ? _value.currentLevelName
          : currentLevelName // ignore: cast_nullable_to_non_nullable
              as String,
      currentXP: null == currentXP
          ? _value.currentXP
          : currentXP // ignore: cast_nullable_to_non_nullable
              as int,
      xpToNextLevel: null == xpToNextLevel
          ? _value.xpToNextLevel
          : xpToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      progressToNextLevel: null == progressToNextLevel
          ? _value.progressToNextLevel
          : progressToNextLevel // ignore: cast_nullable_to_non_nullable
              as double,
      isMaxLevel: null == isMaxLevel
          ? _value.isMaxLevel
          : isMaxLevel // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevelInfo: null == currentLevelInfo
          ? _value.currentLevelInfo
          : currentLevelInfo // ignore: cast_nullable_to_non_nullable
              as LevelInfo,
      nextLevelInfo: freezed == nextLevelInfo
          ? _value.nextLevelInfo
          : nextLevelInfo // ignore: cast_nullable_to_non_nullable
              as LevelInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLevelProgressImpl implements _UserLevelProgress {
  const _$UserLevelProgressImpl(
      {required this.currentLevel,
      required this.currentLevelName,
      required this.currentXP,
      required this.xpToNextLevel,
      required this.progressToNextLevel,
      required this.isMaxLevel,
      required this.currentLevelInfo,
      this.nextLevelInfo});

  factory _$UserLevelProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLevelProgressImplFromJson(json);

  @override
  final int currentLevel;
  @override
  final String currentLevelName;
  @override
  final int currentXP;
  @override
  final int xpToNextLevel;
  @override
  final double progressToNextLevel;
  @override
  final bool isMaxLevel;
  @override
  final LevelInfo currentLevelInfo;
  @override
  final LevelInfo? nextLevelInfo;

  @override
  String toString() {
    return 'UserLevelProgress(currentLevel: $currentLevel, currentLevelName: $currentLevelName, currentXP: $currentXP, xpToNextLevel: $xpToNextLevel, progressToNextLevel: $progressToNextLevel, isMaxLevel: $isMaxLevel, currentLevelInfo: $currentLevelInfo, nextLevelInfo: $nextLevelInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLevelProgressImpl &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.currentLevelName, currentLevelName) ||
                other.currentLevelName == currentLevelName) &&
            (identical(other.currentXP, currentXP) ||
                other.currentXP == currentXP) &&
            (identical(other.xpToNextLevel, xpToNextLevel) ||
                other.xpToNextLevel == xpToNextLevel) &&
            (identical(other.progressToNextLevel, progressToNextLevel) ||
                other.progressToNextLevel == progressToNextLevel) &&
            (identical(other.isMaxLevel, isMaxLevel) ||
                other.isMaxLevel == isMaxLevel) &&
            (identical(other.currentLevelInfo, currentLevelInfo) ||
                other.currentLevelInfo == currentLevelInfo) &&
            (identical(other.nextLevelInfo, nextLevelInfo) ||
                other.nextLevelInfo == nextLevelInfo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentLevel,
      currentLevelName,
      currentXP,
      xpToNextLevel,
      progressToNextLevel,
      isMaxLevel,
      currentLevelInfo,
      nextLevelInfo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLevelProgressImplCopyWith<_$UserLevelProgressImpl> get copyWith =>
      __$$UserLevelProgressImplCopyWithImpl<_$UserLevelProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLevelProgressImplToJson(
      this,
    );
  }
}

abstract class _UserLevelProgress implements UserLevelProgress {
  const factory _UserLevelProgress(
      {required final int currentLevel,
      required final String currentLevelName,
      required final int currentXP,
      required final int xpToNextLevel,
      required final double progressToNextLevel,
      required final bool isMaxLevel,
      required final LevelInfo currentLevelInfo,
      final LevelInfo? nextLevelInfo}) = _$UserLevelProgressImpl;

  factory _UserLevelProgress.fromJson(Map<String, dynamic> json) =
      _$UserLevelProgressImpl.fromJson;

  @override
  int get currentLevel;
  @override
  String get currentLevelName;
  @override
  int get currentXP;
  @override
  int get xpToNextLevel;
  @override
  double get progressToNextLevel;
  @override
  bool get isMaxLevel;
  @override
  LevelInfo get currentLevelInfo;
  @override
  LevelInfo? get nextLevelInfo;
  @override
  @JsonKey(ignore: true)
  _$$UserLevelProgressImplCopyWith<_$UserLevelProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

XPAnalytics _$XPAnalyticsFromJson(Map<String, dynamic> json) {
  return _XPAnalytics.fromJson(json);
}

/// @nodoc
mixin _$XPAnalytics {
  int get totalXP => throw _privateConstructorUsedError;
  int get totalTransactions => throw _privateConstructorUsedError;
  int get todayXP => throw _privateConstructorUsedError;
  int get weeklyXP => throw _privateConstructorUsedError;
  int get monthlyXP => throw _privateConstructorUsedError;
  double get averageXPPerDay => throw _privateConstructorUsedError;
  double get averageXPPerTransaction => throw _privateConstructorUsedError;
  Map<int, int> get hourlyDistribution => throw _privateConstructorUsedError;
  Map<int, int> get weekdayDistribution => throw _privateConstructorUsedError;
  Map<XPSource, SourceAnalytics> get sourceAnalysis =>
      throw _privateConstructorUsedError;
  int get totalStreakBonus => throw _privateConstructorUsedError;
  int get streakBonusTransactions => throw _privateConstructorUsedError;
  GrowthTrend get growthTrend => throw _privateConstructorUsedError;
  int get mostActiveHour => throw _privateConstructorUsedError;
  int get mostActiveWeekday => throw _privateConstructorUsedError;
  XPSource? get topSource => throw _privateConstructorUsedError;
  DateTime get firstActivity => throw _privateConstructorUsedError;
  DateTime get lastActivity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $XPAnalyticsCopyWith<XPAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XPAnalyticsCopyWith<$Res> {
  factory $XPAnalyticsCopyWith(
          XPAnalytics value, $Res Function(XPAnalytics) then) =
      _$XPAnalyticsCopyWithImpl<$Res, XPAnalytics>;
  @useResult
  $Res call(
      {int totalXP,
      int totalTransactions,
      int todayXP,
      int weeklyXP,
      int monthlyXP,
      double averageXPPerDay,
      double averageXPPerTransaction,
      Map<int, int> hourlyDistribution,
      Map<int, int> weekdayDistribution,
      Map<XPSource, SourceAnalytics> sourceAnalysis,
      int totalStreakBonus,
      int streakBonusTransactions,
      GrowthTrend growthTrend,
      int mostActiveHour,
      int mostActiveWeekday,
      XPSource? topSource,
      DateTime firstActivity,
      DateTime lastActivity});
}

/// @nodoc
class _$XPAnalyticsCopyWithImpl<$Res, $Val extends XPAnalytics>
    implements $XPAnalyticsCopyWith<$Res> {
  _$XPAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalXP = null,
    Object? totalTransactions = null,
    Object? todayXP = null,
    Object? weeklyXP = null,
    Object? monthlyXP = null,
    Object? averageXPPerDay = null,
    Object? averageXPPerTransaction = null,
    Object? hourlyDistribution = null,
    Object? weekdayDistribution = null,
    Object? sourceAnalysis = null,
    Object? totalStreakBonus = null,
    Object? streakBonusTransactions = null,
    Object? growthTrend = null,
    Object? mostActiveHour = null,
    Object? mostActiveWeekday = null,
    Object? topSource = freezed,
    Object? firstActivity = null,
    Object? lastActivity = null,
  }) {
    return _then(_value.copyWith(
      totalXP: null == totalXP
          ? _value.totalXP
          : totalXP // ignore: cast_nullable_to_non_nullable
              as int,
      totalTransactions: null == totalTransactions
          ? _value.totalTransactions
          : totalTransactions // ignore: cast_nullable_to_non_nullable
              as int,
      todayXP: null == todayXP
          ? _value.todayXP
          : todayXP // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyXP: null == weeklyXP
          ? _value.weeklyXP
          : weeklyXP // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyXP: null == monthlyXP
          ? _value.monthlyXP
          : monthlyXP // ignore: cast_nullable_to_non_nullable
              as int,
      averageXPPerDay: null == averageXPPerDay
          ? _value.averageXPPerDay
          : averageXPPerDay // ignore: cast_nullable_to_non_nullable
              as double,
      averageXPPerTransaction: null == averageXPPerTransaction
          ? _value.averageXPPerTransaction
          : averageXPPerTransaction // ignore: cast_nullable_to_non_nullable
              as double,
      hourlyDistribution: null == hourlyDistribution
          ? _value.hourlyDistribution
          : hourlyDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      weekdayDistribution: null == weekdayDistribution
          ? _value.weekdayDistribution
          : weekdayDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      sourceAnalysis: null == sourceAnalysis
          ? _value.sourceAnalysis
          : sourceAnalysis // ignore: cast_nullable_to_non_nullable
              as Map<XPSource, SourceAnalytics>,
      totalStreakBonus: null == totalStreakBonus
          ? _value.totalStreakBonus
          : totalStreakBonus // ignore: cast_nullable_to_non_nullable
              as int,
      streakBonusTransactions: null == streakBonusTransactions
          ? _value.streakBonusTransactions
          : streakBonusTransactions // ignore: cast_nullable_to_non_nullable
              as int,
      growthTrend: null == growthTrend
          ? _value.growthTrend
          : growthTrend // ignore: cast_nullable_to_non_nullable
              as GrowthTrend,
      mostActiveHour: null == mostActiveHour
          ? _value.mostActiveHour
          : mostActiveHour // ignore: cast_nullable_to_non_nullable
              as int,
      mostActiveWeekday: null == mostActiveWeekday
          ? _value.mostActiveWeekday
          : mostActiveWeekday // ignore: cast_nullable_to_non_nullable
              as int,
      topSource: freezed == topSource
          ? _value.topSource
          : topSource // ignore: cast_nullable_to_non_nullable
              as XPSource?,
      firstActivity: null == firstActivity
          ? _value.firstActivity
          : firstActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$XPAnalyticsImplCopyWith<$Res>
    implements $XPAnalyticsCopyWith<$Res> {
  factory _$$XPAnalyticsImplCopyWith(
          _$XPAnalyticsImpl value, $Res Function(_$XPAnalyticsImpl) then) =
      __$$XPAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalXP,
      int totalTransactions,
      int todayXP,
      int weeklyXP,
      int monthlyXP,
      double averageXPPerDay,
      double averageXPPerTransaction,
      Map<int, int> hourlyDistribution,
      Map<int, int> weekdayDistribution,
      Map<XPSource, SourceAnalytics> sourceAnalysis,
      int totalStreakBonus,
      int streakBonusTransactions,
      GrowthTrend growthTrend,
      int mostActiveHour,
      int mostActiveWeekday,
      XPSource? topSource,
      DateTime firstActivity,
      DateTime lastActivity});
}

/// @nodoc
class __$$XPAnalyticsImplCopyWithImpl<$Res>
    extends _$XPAnalyticsCopyWithImpl<$Res, _$XPAnalyticsImpl>
    implements _$$XPAnalyticsImplCopyWith<$Res> {
  __$$XPAnalyticsImplCopyWithImpl(
      _$XPAnalyticsImpl _value, $Res Function(_$XPAnalyticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalXP = null,
    Object? totalTransactions = null,
    Object? todayXP = null,
    Object? weeklyXP = null,
    Object? monthlyXP = null,
    Object? averageXPPerDay = null,
    Object? averageXPPerTransaction = null,
    Object? hourlyDistribution = null,
    Object? weekdayDistribution = null,
    Object? sourceAnalysis = null,
    Object? totalStreakBonus = null,
    Object? streakBonusTransactions = null,
    Object? growthTrend = null,
    Object? mostActiveHour = null,
    Object? mostActiveWeekday = null,
    Object? topSource = freezed,
    Object? firstActivity = null,
    Object? lastActivity = null,
  }) {
    return _then(_$XPAnalyticsImpl(
      totalXP: null == totalXP
          ? _value.totalXP
          : totalXP // ignore: cast_nullable_to_non_nullable
              as int,
      totalTransactions: null == totalTransactions
          ? _value.totalTransactions
          : totalTransactions // ignore: cast_nullable_to_non_nullable
              as int,
      todayXP: null == todayXP
          ? _value.todayXP
          : todayXP // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyXP: null == weeklyXP
          ? _value.weeklyXP
          : weeklyXP // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyXP: null == monthlyXP
          ? _value.monthlyXP
          : monthlyXP // ignore: cast_nullable_to_non_nullable
              as int,
      averageXPPerDay: null == averageXPPerDay
          ? _value.averageXPPerDay
          : averageXPPerDay // ignore: cast_nullable_to_non_nullable
              as double,
      averageXPPerTransaction: null == averageXPPerTransaction
          ? _value.averageXPPerTransaction
          : averageXPPerTransaction // ignore: cast_nullable_to_non_nullable
              as double,
      hourlyDistribution: null == hourlyDistribution
          ? _value._hourlyDistribution
          : hourlyDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      weekdayDistribution: null == weekdayDistribution
          ? _value._weekdayDistribution
          : weekdayDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      sourceAnalysis: null == sourceAnalysis
          ? _value._sourceAnalysis
          : sourceAnalysis // ignore: cast_nullable_to_non_nullable
              as Map<XPSource, SourceAnalytics>,
      totalStreakBonus: null == totalStreakBonus
          ? _value.totalStreakBonus
          : totalStreakBonus // ignore: cast_nullable_to_non_nullable
              as int,
      streakBonusTransactions: null == streakBonusTransactions
          ? _value.streakBonusTransactions
          : streakBonusTransactions // ignore: cast_nullable_to_non_nullable
              as int,
      growthTrend: null == growthTrend
          ? _value.growthTrend
          : growthTrend // ignore: cast_nullable_to_non_nullable
              as GrowthTrend,
      mostActiveHour: null == mostActiveHour
          ? _value.mostActiveHour
          : mostActiveHour // ignore: cast_nullable_to_non_nullable
              as int,
      mostActiveWeekday: null == mostActiveWeekday
          ? _value.mostActiveWeekday
          : mostActiveWeekday // ignore: cast_nullable_to_non_nullable
              as int,
      topSource: freezed == topSource
          ? _value.topSource
          : topSource // ignore: cast_nullable_to_non_nullable
              as XPSource?,
      firstActivity: null == firstActivity
          ? _value.firstActivity
          : firstActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$XPAnalyticsImpl implements _XPAnalytics {
  const _$XPAnalyticsImpl(
      {required this.totalXP,
      required this.totalTransactions,
      required this.todayXP,
      required this.weeklyXP,
      required this.monthlyXP,
      required this.averageXPPerDay,
      required this.averageXPPerTransaction,
      required final Map<int, int> hourlyDistribution,
      required final Map<int, int> weekdayDistribution,
      required final Map<XPSource, SourceAnalytics> sourceAnalysis,
      required this.totalStreakBonus,
      required this.streakBonusTransactions,
      required this.growthTrend,
      required this.mostActiveHour,
      required this.mostActiveWeekday,
      this.topSource,
      required this.firstActivity,
      required this.lastActivity})
      : _hourlyDistribution = hourlyDistribution,
        _weekdayDistribution = weekdayDistribution,
        _sourceAnalysis = sourceAnalysis;

  factory _$XPAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$XPAnalyticsImplFromJson(json);

  @override
  final int totalXP;
  @override
  final int totalTransactions;
  @override
  final int todayXP;
  @override
  final int weeklyXP;
  @override
  final int monthlyXP;
  @override
  final double averageXPPerDay;
  @override
  final double averageXPPerTransaction;
  final Map<int, int> _hourlyDistribution;
  @override
  Map<int, int> get hourlyDistribution {
    if (_hourlyDistribution is EqualUnmodifiableMapView)
      return _hourlyDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hourlyDistribution);
  }

  final Map<int, int> _weekdayDistribution;
  @override
  Map<int, int> get weekdayDistribution {
    if (_weekdayDistribution is EqualUnmodifiableMapView)
      return _weekdayDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_weekdayDistribution);
  }

  final Map<XPSource, SourceAnalytics> _sourceAnalysis;
  @override
  Map<XPSource, SourceAnalytics> get sourceAnalysis {
    if (_sourceAnalysis is EqualUnmodifiableMapView) return _sourceAnalysis;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sourceAnalysis);
  }

  @override
  final int totalStreakBonus;
  @override
  final int streakBonusTransactions;
  @override
  final GrowthTrend growthTrend;
  @override
  final int mostActiveHour;
  @override
  final int mostActiveWeekday;
  @override
  final XPSource? topSource;
  @override
  final DateTime firstActivity;
  @override
  final DateTime lastActivity;

  @override
  String toString() {
    return 'XPAnalytics(totalXP: $totalXP, totalTransactions: $totalTransactions, todayXP: $todayXP, weeklyXP: $weeklyXP, monthlyXP: $monthlyXP, averageXPPerDay: $averageXPPerDay, averageXPPerTransaction: $averageXPPerTransaction, hourlyDistribution: $hourlyDistribution, weekdayDistribution: $weekdayDistribution, sourceAnalysis: $sourceAnalysis, totalStreakBonus: $totalStreakBonus, streakBonusTransactions: $streakBonusTransactions, growthTrend: $growthTrend, mostActiveHour: $mostActiveHour, mostActiveWeekday: $mostActiveWeekday, topSource: $topSource, firstActivity: $firstActivity, lastActivity: $lastActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$XPAnalyticsImpl &&
            (identical(other.totalXP, totalXP) || other.totalXP == totalXP) &&
            (identical(other.totalTransactions, totalTransactions) ||
                other.totalTransactions == totalTransactions) &&
            (identical(other.todayXP, todayXP) || other.todayXP == todayXP) &&
            (identical(other.weeklyXP, weeklyXP) ||
                other.weeklyXP == weeklyXP) &&
            (identical(other.monthlyXP, monthlyXP) ||
                other.monthlyXP == monthlyXP) &&
            (identical(other.averageXPPerDay, averageXPPerDay) ||
                other.averageXPPerDay == averageXPPerDay) &&
            (identical(
                    other.averageXPPerTransaction, averageXPPerTransaction) ||
                other.averageXPPerTransaction == averageXPPerTransaction) &&
            const DeepCollectionEquality()
                .equals(other._hourlyDistribution, _hourlyDistribution) &&
            const DeepCollectionEquality()
                .equals(other._weekdayDistribution, _weekdayDistribution) &&
            const DeepCollectionEquality()
                .equals(other._sourceAnalysis, _sourceAnalysis) &&
            (identical(other.totalStreakBonus, totalStreakBonus) ||
                other.totalStreakBonus == totalStreakBonus) &&
            (identical(
                    other.streakBonusTransactions, streakBonusTransactions) ||
                other.streakBonusTransactions == streakBonusTransactions) &&
            (identical(other.growthTrend, growthTrend) ||
                other.growthTrend == growthTrend) &&
            (identical(other.mostActiveHour, mostActiveHour) ||
                other.mostActiveHour == mostActiveHour) &&
            (identical(other.mostActiveWeekday, mostActiveWeekday) ||
                other.mostActiveWeekday == mostActiveWeekday) &&
            (identical(other.topSource, topSource) ||
                other.topSource == topSource) &&
            (identical(other.firstActivity, firstActivity) ||
                other.firstActivity == firstActivity) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalXP,
      totalTransactions,
      todayXP,
      weeklyXP,
      monthlyXP,
      averageXPPerDay,
      averageXPPerTransaction,
      const DeepCollectionEquality().hash(_hourlyDistribution),
      const DeepCollectionEquality().hash(_weekdayDistribution),
      const DeepCollectionEquality().hash(_sourceAnalysis),
      totalStreakBonus,
      streakBonusTransactions,
      growthTrend,
      mostActiveHour,
      mostActiveWeekday,
      topSource,
      firstActivity,
      lastActivity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$XPAnalyticsImplCopyWith<_$XPAnalyticsImpl> get copyWith =>
      __$$XPAnalyticsImplCopyWithImpl<_$XPAnalyticsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$XPAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _XPAnalytics implements XPAnalytics {
  const factory _XPAnalytics(
      {required final int totalXP,
      required final int totalTransactions,
      required final int todayXP,
      required final int weeklyXP,
      required final int monthlyXP,
      required final double averageXPPerDay,
      required final double averageXPPerTransaction,
      required final Map<int, int> hourlyDistribution,
      required final Map<int, int> weekdayDistribution,
      required final Map<XPSource, SourceAnalytics> sourceAnalysis,
      required final int totalStreakBonus,
      required final int streakBonusTransactions,
      required final GrowthTrend growthTrend,
      required final int mostActiveHour,
      required final int mostActiveWeekday,
      final XPSource? topSource,
      required final DateTime firstActivity,
      required final DateTime lastActivity}) = _$XPAnalyticsImpl;

  factory _XPAnalytics.fromJson(Map<String, dynamic> json) =
      _$XPAnalyticsImpl.fromJson;

  @override
  int get totalXP;
  @override
  int get totalTransactions;
  @override
  int get todayXP;
  @override
  int get weeklyXP;
  @override
  int get monthlyXP;
  @override
  double get averageXPPerDay;
  @override
  double get averageXPPerTransaction;
  @override
  Map<int, int> get hourlyDistribution;
  @override
  Map<int, int> get weekdayDistribution;
  @override
  Map<XPSource, SourceAnalytics> get sourceAnalysis;
  @override
  int get totalStreakBonus;
  @override
  int get streakBonusTransactions;
  @override
  GrowthTrend get growthTrend;
  @override
  int get mostActiveHour;
  @override
  int get mostActiveWeekday;
  @override
  XPSource? get topSource;
  @override
  DateTime get firstActivity;
  @override
  DateTime get lastActivity;
  @override
  @JsonKey(ignore: true)
  _$$XPAnalyticsImplCopyWith<_$XPAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SourceAnalytics _$SourceAnalyticsFromJson(Map<String, dynamic> json) {
  return _SourceAnalytics.fromJson(json);
}

/// @nodoc
mixin _$SourceAnalytics {
  int get totalXP => throw _privateConstructorUsedError;
  int get transactionCount => throw _privateConstructorUsedError;
  double get averageXP => throw _privateConstructorUsedError;
  DateTime get lastActivity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SourceAnalyticsCopyWith<SourceAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceAnalyticsCopyWith<$Res> {
  factory $SourceAnalyticsCopyWith(
          SourceAnalytics value, $Res Function(SourceAnalytics) then) =
      _$SourceAnalyticsCopyWithImpl<$Res, SourceAnalytics>;
  @useResult
  $Res call(
      {int totalXP,
      int transactionCount,
      double averageXP,
      DateTime lastActivity});
}

/// @nodoc
class _$SourceAnalyticsCopyWithImpl<$Res, $Val extends SourceAnalytics>
    implements $SourceAnalyticsCopyWith<$Res> {
  _$SourceAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalXP = null,
    Object? transactionCount = null,
    Object? averageXP = null,
    Object? lastActivity = null,
  }) {
    return _then(_value.copyWith(
      totalXP: null == totalXP
          ? _value.totalXP
          : totalXP // ignore: cast_nullable_to_non_nullable
              as int,
      transactionCount: null == transactionCount
          ? _value.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageXP: null == averageXP
          ? _value.averageXP
          : averageXP // ignore: cast_nullable_to_non_nullable
              as double,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SourceAnalyticsImplCopyWith<$Res>
    implements $SourceAnalyticsCopyWith<$Res> {
  factory _$$SourceAnalyticsImplCopyWith(_$SourceAnalyticsImpl value,
          $Res Function(_$SourceAnalyticsImpl) then) =
      __$$SourceAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalXP,
      int transactionCount,
      double averageXP,
      DateTime lastActivity});
}

/// @nodoc
class __$$SourceAnalyticsImplCopyWithImpl<$Res>
    extends _$SourceAnalyticsCopyWithImpl<$Res, _$SourceAnalyticsImpl>
    implements _$$SourceAnalyticsImplCopyWith<$Res> {
  __$$SourceAnalyticsImplCopyWithImpl(
      _$SourceAnalyticsImpl _value, $Res Function(_$SourceAnalyticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalXP = null,
    Object? transactionCount = null,
    Object? averageXP = null,
    Object? lastActivity = null,
  }) {
    return _then(_$SourceAnalyticsImpl(
      totalXP: null == totalXP
          ? _value.totalXP
          : totalXP // ignore: cast_nullable_to_non_nullable
              as int,
      transactionCount: null == transactionCount
          ? _value.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageXP: null == averageXP
          ? _value.averageXP
          : averageXP // ignore: cast_nullable_to_non_nullable
              as double,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceAnalyticsImpl implements _SourceAnalytics {
  const _$SourceAnalyticsImpl(
      {required this.totalXP,
      required this.transactionCount,
      required this.averageXP,
      required this.lastActivity});

  factory _$SourceAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceAnalyticsImplFromJson(json);

  @override
  final int totalXP;
  @override
  final int transactionCount;
  @override
  final double averageXP;
  @override
  final DateTime lastActivity;

  @override
  String toString() {
    return 'SourceAnalytics(totalXP: $totalXP, transactionCount: $transactionCount, averageXP: $averageXP, lastActivity: $lastActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceAnalyticsImpl &&
            (identical(other.totalXP, totalXP) || other.totalXP == totalXP) &&
            (identical(other.transactionCount, transactionCount) ||
                other.transactionCount == transactionCount) &&
            (identical(other.averageXP, averageXP) ||
                other.averageXP == averageXP) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, totalXP, transactionCount, averageXP, lastActivity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceAnalyticsImplCopyWith<_$SourceAnalyticsImpl> get copyWith =>
      __$$SourceAnalyticsImplCopyWithImpl<_$SourceAnalyticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _SourceAnalytics implements SourceAnalytics {
  const factory _SourceAnalytics(
      {required final int totalXP,
      required final int transactionCount,
      required final double averageXP,
      required final DateTime lastActivity}) = _$SourceAnalyticsImpl;

  factory _SourceAnalytics.fromJson(Map<String, dynamic> json) =
      _$SourceAnalyticsImpl.fromJson;

  @override
  int get totalXP;
  @override
  int get transactionCount;
  @override
  double get averageXP;
  @override
  DateTime get lastActivity;
  @override
  @JsonKey(ignore: true)
  _$$SourceAnalyticsImplCopyWith<_$SourceAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
