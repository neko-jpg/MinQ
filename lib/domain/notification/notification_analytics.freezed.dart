// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationEvent _$NotificationEventFromJson(Map<String, dynamic> json) {
  return _NotificationEvent.fromJson(json);
}

/// @nodoc
mixin _$NotificationEvent {
  String get id => throw _privateConstructorUsedError;
  String get notificationId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  NotificationEventType get eventType => throw _privateConstructorUsedError;
  NotificationCategory get category => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get actionTaken => throw _privateConstructorUsedError; // 実行されたアクション
  Duration? get timeToAction => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationEventCopyWith<NotificationEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationEventCopyWith<$Res> {
  factory $NotificationEventCopyWith(
          NotificationEvent value, $Res Function(NotificationEvent) then) =
      _$NotificationEventCopyWithImpl<$Res, NotificationEvent>;
  @useResult
  $Res call(
      {String id,
      String notificationId,
      String userId,
      NotificationEventType eventType,
      NotificationCategory category,
      DateTime timestamp,
      Map<String, dynamic>? metadata,
      String? actionTaken,
      Duration? timeToAction});
}

/// @nodoc
class _$NotificationEventCopyWithImpl<$Res, $Val extends NotificationEvent>
    implements $NotificationEventCopyWith<$Res> {
  _$NotificationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notificationId = null,
    Object? userId = null,
    Object? eventType = null,
    Object? category = null,
    Object? timestamp = null,
    Object? metadata = freezed,
    Object? actionTaken = freezed,
    Object? timeToAction = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      notificationId: null == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as NotificationEventType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      actionTaken: freezed == actionTaken
          ? _value.actionTaken
          : actionTaken // ignore: cast_nullable_to_non_nullable
              as String?,
      timeToAction: freezed == timeToAction
          ? _value.timeToAction
          : timeToAction // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationEventImplCopyWith<$Res>
    implements $NotificationEventCopyWith<$Res> {
  factory _$$NotificationEventImplCopyWith(_$NotificationEventImpl value,
          $Res Function(_$NotificationEventImpl) then) =
      __$$NotificationEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String notificationId,
      String userId,
      NotificationEventType eventType,
      NotificationCategory category,
      DateTime timestamp,
      Map<String, dynamic>? metadata,
      String? actionTaken,
      Duration? timeToAction});
}

/// @nodoc
class __$$NotificationEventImplCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res, _$NotificationEventImpl>
    implements _$$NotificationEventImplCopyWith<$Res> {
  __$$NotificationEventImplCopyWithImpl(_$NotificationEventImpl _value,
      $Res Function(_$NotificationEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notificationId = null,
    Object? userId = null,
    Object? eventType = null,
    Object? category = null,
    Object? timestamp = null,
    Object? metadata = freezed,
    Object? actionTaken = freezed,
    Object? timeToAction = freezed,
  }) {
    return _then(_$NotificationEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      notificationId: null == notificationId
          ? _value.notificationId
          : notificationId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as NotificationEventType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      actionTaken: freezed == actionTaken
          ? _value.actionTaken
          : actionTaken // ignore: cast_nullable_to_non_nullable
              as String?,
      timeToAction: freezed == timeToAction
          ? _value.timeToAction
          : timeToAction // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationEventImpl implements _NotificationEvent {
  const _$NotificationEventImpl(
      {required this.id,
      required this.notificationId,
      required this.userId,
      required this.eventType,
      required this.category,
      required this.timestamp,
      final Map<String, dynamic>? metadata,
      this.actionTaken,
      this.timeToAction})
      : _metadata = metadata;

  factory _$NotificationEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationEventImplFromJson(json);

  @override
  final String id;
  @override
  final String notificationId;
  @override
  final String userId;
  @override
  final NotificationEventType eventType;
  @override
  final NotificationCategory category;
  @override
  final DateTime timestamp;
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
  final String? actionTaken;
// 実行されたアクション
  @override
  final Duration? timeToAction;

  @override
  String toString() {
    return 'NotificationEvent(id: $id, notificationId: $notificationId, userId: $userId, eventType: $eventType, category: $category, timestamp: $timestamp, metadata: $metadata, actionTaken: $actionTaken, timeToAction: $timeToAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.actionTaken, actionTaken) ||
                other.actionTaken == actionTaken) &&
            (identical(other.timeToAction, timeToAction) ||
                other.timeToAction == timeToAction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      notificationId,
      userId,
      eventType,
      category,
      timestamp,
      const DeepCollectionEquality().hash(_metadata),
      actionTaken,
      timeToAction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationEventImplCopyWith<_$NotificationEventImpl> get copyWith =>
      __$$NotificationEventImplCopyWithImpl<_$NotificationEventImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationEventImplToJson(
      this,
    );
  }
}

abstract class _NotificationEvent implements NotificationEvent {
  const factory _NotificationEvent(
      {required final String id,
      required final String notificationId,
      required final String userId,
      required final NotificationEventType eventType,
      required final NotificationCategory category,
      required final DateTime timestamp,
      final Map<String, dynamic>? metadata,
      final String? actionTaken,
      final Duration? timeToAction}) = _$NotificationEventImpl;

  factory _NotificationEvent.fromJson(Map<String, dynamic> json) =
      _$NotificationEventImpl.fromJson;

  @override
  String get id;
  @override
  String get notificationId;
  @override
  String get userId;
  @override
  NotificationEventType get eventType;
  @override
  NotificationCategory get category;
  @override
  DateTime get timestamp;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get actionTaken;
  @override // 実行されたアクション
  Duration? get timeToAction;
  @override
  @JsonKey(ignore: true)
  _$$NotificationEventImplCopyWith<_$NotificationEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationMetrics _$NotificationMetricsFromJson(Map<String, dynamic> json) {
  return _NotificationMetrics.fromJson(json);
}

/// @nodoc
mixin _$NotificationMetrics {
  String get userId => throw _privateConstructorUsedError;
  NotificationCategory get category => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  int get totalSent => throw _privateConstructorUsedError;
  int get totalDelivered => throw _privateConstructorUsedError;
  int get totalOpened => throw _privateConstructorUsedError;
  int get totalClicked => throw _privateConstructorUsedError;
  int get totalDismissed => throw _privateConstructorUsedError;
  int get totalConverted => throw _privateConstructorUsedError;
  double get deliveryRate => throw _privateConstructorUsedError;
  double get openRate => throw _privateConstructorUsedError;
  double get clickRate => throw _privateConstructorUsedError;
  double get conversionRate => throw _privateConstructorUsedError;
  Duration get averageTimeToAction => throw _privateConstructorUsedError;
  Map<String, int>? get hourlyDistribution =>
      throw _privateConstructorUsedError; // 時間別分布
  Map<String, double>? get dayOfWeekPerformance =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationMetricsCopyWith<NotificationMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationMetricsCopyWith<$Res> {
  factory $NotificationMetricsCopyWith(
          NotificationMetrics value, $Res Function(NotificationMetrics) then) =
      _$NotificationMetricsCopyWithImpl<$Res, NotificationMetrics>;
  @useResult
  $Res call(
      {String userId,
      NotificationCategory category,
      DateTime periodStart,
      DateTime periodEnd,
      int totalSent,
      int totalDelivered,
      int totalOpened,
      int totalClicked,
      int totalDismissed,
      int totalConverted,
      double deliveryRate,
      double openRate,
      double clickRate,
      double conversionRate,
      Duration averageTimeToAction,
      Map<String, int>? hourlyDistribution,
      Map<String, double>? dayOfWeekPerformance});
}

/// @nodoc
class _$NotificationMetricsCopyWithImpl<$Res, $Val extends NotificationMetrics>
    implements $NotificationMetricsCopyWith<$Res> {
  _$NotificationMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? category = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? totalSent = null,
    Object? totalDelivered = null,
    Object? totalOpened = null,
    Object? totalClicked = null,
    Object? totalDismissed = null,
    Object? totalConverted = null,
    Object? deliveryRate = null,
    Object? openRate = null,
    Object? clickRate = null,
    Object? conversionRate = null,
    Object? averageTimeToAction = null,
    Object? hourlyDistribution = freezed,
    Object? dayOfWeekPerformance = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalSent: null == totalSent
          ? _value.totalSent
          : totalSent // ignore: cast_nullable_to_non_nullable
              as int,
      totalDelivered: null == totalDelivered
          ? _value.totalDelivered
          : totalDelivered // ignore: cast_nullable_to_non_nullable
              as int,
      totalOpened: null == totalOpened
          ? _value.totalOpened
          : totalOpened // ignore: cast_nullable_to_non_nullable
              as int,
      totalClicked: null == totalClicked
          ? _value.totalClicked
          : totalClicked // ignore: cast_nullable_to_non_nullable
              as int,
      totalDismissed: null == totalDismissed
          ? _value.totalDismissed
          : totalDismissed // ignore: cast_nullable_to_non_nullable
              as int,
      totalConverted: null == totalConverted
          ? _value.totalConverted
          : totalConverted // ignore: cast_nullable_to_non_nullable
              as int,
      deliveryRate: null == deliveryRate
          ? _value.deliveryRate
          : deliveryRate // ignore: cast_nullable_to_non_nullable
              as double,
      openRate: null == openRate
          ? _value.openRate
          : openRate // ignore: cast_nullable_to_non_nullable
              as double,
      clickRate: null == clickRate
          ? _value.clickRate
          : clickRate // ignore: cast_nullable_to_non_nullable
              as double,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageTimeToAction: null == averageTimeToAction
          ? _value.averageTimeToAction
          : averageTimeToAction // ignore: cast_nullable_to_non_nullable
              as Duration,
      hourlyDistribution: freezed == hourlyDistribution
          ? _value.hourlyDistribution
          : hourlyDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      dayOfWeekPerformance: freezed == dayOfWeekPerformance
          ? _value.dayOfWeekPerformance
          : dayOfWeekPerformance // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationMetricsImplCopyWith<$Res>
    implements $NotificationMetricsCopyWith<$Res> {
  factory _$$NotificationMetricsImplCopyWith(_$NotificationMetricsImpl value,
          $Res Function(_$NotificationMetricsImpl) then) =
      __$$NotificationMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      NotificationCategory category,
      DateTime periodStart,
      DateTime periodEnd,
      int totalSent,
      int totalDelivered,
      int totalOpened,
      int totalClicked,
      int totalDismissed,
      int totalConverted,
      double deliveryRate,
      double openRate,
      double clickRate,
      double conversionRate,
      Duration averageTimeToAction,
      Map<String, int>? hourlyDistribution,
      Map<String, double>? dayOfWeekPerformance});
}

/// @nodoc
class __$$NotificationMetricsImplCopyWithImpl<$Res>
    extends _$NotificationMetricsCopyWithImpl<$Res, _$NotificationMetricsImpl>
    implements _$$NotificationMetricsImplCopyWith<$Res> {
  __$$NotificationMetricsImplCopyWithImpl(_$NotificationMetricsImpl _value,
      $Res Function(_$NotificationMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? category = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? totalSent = null,
    Object? totalDelivered = null,
    Object? totalOpened = null,
    Object? totalClicked = null,
    Object? totalDismissed = null,
    Object? totalConverted = null,
    Object? deliveryRate = null,
    Object? openRate = null,
    Object? clickRate = null,
    Object? conversionRate = null,
    Object? averageTimeToAction = null,
    Object? hourlyDistribution = freezed,
    Object? dayOfWeekPerformance = freezed,
  }) {
    return _then(_$NotificationMetricsImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalSent: null == totalSent
          ? _value.totalSent
          : totalSent // ignore: cast_nullable_to_non_nullable
              as int,
      totalDelivered: null == totalDelivered
          ? _value.totalDelivered
          : totalDelivered // ignore: cast_nullable_to_non_nullable
              as int,
      totalOpened: null == totalOpened
          ? _value.totalOpened
          : totalOpened // ignore: cast_nullable_to_non_nullable
              as int,
      totalClicked: null == totalClicked
          ? _value.totalClicked
          : totalClicked // ignore: cast_nullable_to_non_nullable
              as int,
      totalDismissed: null == totalDismissed
          ? _value.totalDismissed
          : totalDismissed // ignore: cast_nullable_to_non_nullable
              as int,
      totalConverted: null == totalConverted
          ? _value.totalConverted
          : totalConverted // ignore: cast_nullable_to_non_nullable
              as int,
      deliveryRate: null == deliveryRate
          ? _value.deliveryRate
          : deliveryRate // ignore: cast_nullable_to_non_nullable
              as double,
      openRate: null == openRate
          ? _value.openRate
          : openRate // ignore: cast_nullable_to_non_nullable
              as double,
      clickRate: null == clickRate
          ? _value.clickRate
          : clickRate // ignore: cast_nullable_to_non_nullable
              as double,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageTimeToAction: null == averageTimeToAction
          ? _value.averageTimeToAction
          : averageTimeToAction // ignore: cast_nullable_to_non_nullable
              as Duration,
      hourlyDistribution: freezed == hourlyDistribution
          ? _value._hourlyDistribution
          : hourlyDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      dayOfWeekPerformance: freezed == dayOfWeekPerformance
          ? _value._dayOfWeekPerformance
          : dayOfWeekPerformance // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationMetricsImpl implements _NotificationMetrics {
  const _$NotificationMetricsImpl(
      {required this.userId,
      required this.category,
      required this.periodStart,
      required this.periodEnd,
      this.totalSent = 0,
      this.totalDelivered = 0,
      this.totalOpened = 0,
      this.totalClicked = 0,
      this.totalDismissed = 0,
      this.totalConverted = 0,
      this.deliveryRate = 0.0,
      this.openRate = 0.0,
      this.clickRate = 0.0,
      this.conversionRate = 0.0,
      this.averageTimeToAction = Duration.zero,
      final Map<String, int>? hourlyDistribution,
      final Map<String, double>? dayOfWeekPerformance})
      : _hourlyDistribution = hourlyDistribution,
        _dayOfWeekPerformance = dayOfWeekPerformance;

  factory _$NotificationMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationMetricsImplFromJson(json);

  @override
  final String userId;
  @override
  final NotificationCategory category;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  @override
  @JsonKey()
  final int totalSent;
  @override
  @JsonKey()
  final int totalDelivered;
  @override
  @JsonKey()
  final int totalOpened;
  @override
  @JsonKey()
  final int totalClicked;
  @override
  @JsonKey()
  final int totalDismissed;
  @override
  @JsonKey()
  final int totalConverted;
  @override
  @JsonKey()
  final double deliveryRate;
  @override
  @JsonKey()
  final double openRate;
  @override
  @JsonKey()
  final double clickRate;
  @override
  @JsonKey()
  final double conversionRate;
  @override
  @JsonKey()
  final Duration averageTimeToAction;
  final Map<String, int>? _hourlyDistribution;
  @override
  Map<String, int>? get hourlyDistribution {
    final value = _hourlyDistribution;
    if (value == null) return null;
    if (_hourlyDistribution is EqualUnmodifiableMapView)
      return _hourlyDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// 時間別分布
  final Map<String, double>? _dayOfWeekPerformance;
// 時間別分布
  @override
  Map<String, double>? get dayOfWeekPerformance {
    final value = _dayOfWeekPerformance;
    if (value == null) return null;
    if (_dayOfWeekPerformance is EqualUnmodifiableMapView)
      return _dayOfWeekPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationMetrics(userId: $userId, category: $category, periodStart: $periodStart, periodEnd: $periodEnd, totalSent: $totalSent, totalDelivered: $totalDelivered, totalOpened: $totalOpened, totalClicked: $totalClicked, totalDismissed: $totalDismissed, totalConverted: $totalConverted, deliveryRate: $deliveryRate, openRate: $openRate, clickRate: $clickRate, conversionRate: $conversionRate, averageTimeToAction: $averageTimeToAction, hourlyDistribution: $hourlyDistribution, dayOfWeekPerformance: $dayOfWeekPerformance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationMetricsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.totalSent, totalSent) ||
                other.totalSent == totalSent) &&
            (identical(other.totalDelivered, totalDelivered) ||
                other.totalDelivered == totalDelivered) &&
            (identical(other.totalOpened, totalOpened) ||
                other.totalOpened == totalOpened) &&
            (identical(other.totalClicked, totalClicked) ||
                other.totalClicked == totalClicked) &&
            (identical(other.totalDismissed, totalDismissed) ||
                other.totalDismissed == totalDismissed) &&
            (identical(other.totalConverted, totalConverted) ||
                other.totalConverted == totalConverted) &&
            (identical(other.deliveryRate, deliveryRate) ||
                other.deliveryRate == deliveryRate) &&
            (identical(other.openRate, openRate) ||
                other.openRate == openRate) &&
            (identical(other.clickRate, clickRate) ||
                other.clickRate == clickRate) &&
            (identical(other.conversionRate, conversionRate) ||
                other.conversionRate == conversionRate) &&
            (identical(other.averageTimeToAction, averageTimeToAction) ||
                other.averageTimeToAction == averageTimeToAction) &&
            const DeepCollectionEquality()
                .equals(other._hourlyDistribution, _hourlyDistribution) &&
            const DeepCollectionEquality()
                .equals(other._dayOfWeekPerformance, _dayOfWeekPerformance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      category,
      periodStart,
      periodEnd,
      totalSent,
      totalDelivered,
      totalOpened,
      totalClicked,
      totalDismissed,
      totalConverted,
      deliveryRate,
      openRate,
      clickRate,
      conversionRate,
      averageTimeToAction,
      const DeepCollectionEquality().hash(_hourlyDistribution),
      const DeepCollectionEquality().hash(_dayOfWeekPerformance));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationMetricsImplCopyWith<_$NotificationMetricsImpl> get copyWith =>
      __$$NotificationMetricsImplCopyWithImpl<_$NotificationMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationMetricsImplToJson(
      this,
    );
  }
}

abstract class _NotificationMetrics implements NotificationMetrics {
  const factory _NotificationMetrics(
          {required final String userId,
          required final NotificationCategory category,
          required final DateTime periodStart,
          required final DateTime periodEnd,
          final int totalSent,
          final int totalDelivered,
          final int totalOpened,
          final int totalClicked,
          final int totalDismissed,
          final int totalConverted,
          final double deliveryRate,
          final double openRate,
          final double clickRate,
          final double conversionRate,
          final Duration averageTimeToAction,
          final Map<String, int>? hourlyDistribution,
          final Map<String, double>? dayOfWeekPerformance}) =
      _$NotificationMetricsImpl;

  factory _NotificationMetrics.fromJson(Map<String, dynamic> json) =
      _$NotificationMetricsImpl.fromJson;

  @override
  String get userId;
  @override
  NotificationCategory get category;
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  int get totalSent;
  @override
  int get totalDelivered;
  @override
  int get totalOpened;
  @override
  int get totalClicked;
  @override
  int get totalDismissed;
  @override
  int get totalConverted;
  @override
  double get deliveryRate;
  @override
  double get openRate;
  @override
  double get clickRate;
  @override
  double get conversionRate;
  @override
  Duration get averageTimeToAction;
  @override
  Map<String, int>? get hourlyDistribution;
  @override // 時間別分布
  Map<String, double>? get dayOfWeekPerformance;
  @override
  @JsonKey(ignore: true)
  _$$NotificationMetricsImplCopyWith<_$NotificationMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OptimalTimingAnalysis _$OptimalTimingAnalysisFromJson(
    Map<String, dynamic> json) {
  return _OptimalTimingAnalysis.fromJson(json);
}

/// @nodoc
mixin _$OptimalTimingAnalysis {
  String get userId => throw _privateConstructorUsedError;
  NotificationCategory get category => throw _privateConstructorUsedError;
  DateTime get analyzedAt => throw _privateConstructorUsedError;
  List<int> get optimalHours =>
      throw _privateConstructorUsedError; // 最適な時間帯（0-23）
  List<int> get optimalDaysOfWeek =>
      throw _privateConstructorUsedError; // 最適な曜日（1-7）
  double get confidence => throw _privateConstructorUsedError; // 分析の信頼度
  int get sampleSize => throw _privateConstructorUsedError; // サンプル数
  Map<String, double>? get hourlyEngagementRates =>
      throw _privateConstructorUsedError; // 時間別エンゲージメント率
  Map<String, double>? get dailyEngagementRates =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OptimalTimingAnalysisCopyWith<OptimalTimingAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptimalTimingAnalysisCopyWith<$Res> {
  factory $OptimalTimingAnalysisCopyWith(OptimalTimingAnalysis value,
          $Res Function(OptimalTimingAnalysis) then) =
      _$OptimalTimingAnalysisCopyWithImpl<$Res, OptimalTimingAnalysis>;
  @useResult
  $Res call(
      {String userId,
      NotificationCategory category,
      DateTime analyzedAt,
      List<int> optimalHours,
      List<int> optimalDaysOfWeek,
      double confidence,
      int sampleSize,
      Map<String, double>? hourlyEngagementRates,
      Map<String, double>? dailyEngagementRates});
}

/// @nodoc
class _$OptimalTimingAnalysisCopyWithImpl<$Res,
        $Val extends OptimalTimingAnalysis>
    implements $OptimalTimingAnalysisCopyWith<$Res> {
  _$OptimalTimingAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? category = null,
    Object? analyzedAt = null,
    Object? optimalHours = null,
    Object? optimalDaysOfWeek = null,
    Object? confidence = null,
    Object? sampleSize = null,
    Object? hourlyEngagementRates = freezed,
    Object? dailyEngagementRates = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optimalHours: null == optimalHours
          ? _value.optimalHours
          : optimalHours // ignore: cast_nullable_to_non_nullable
              as List<int>,
      optimalDaysOfWeek: null == optimalDaysOfWeek
          ? _value.optimalDaysOfWeek
          : optimalDaysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      sampleSize: null == sampleSize
          ? _value.sampleSize
          : sampleSize // ignore: cast_nullable_to_non_nullable
              as int,
      hourlyEngagementRates: freezed == hourlyEngagementRates
          ? _value.hourlyEngagementRates
          : hourlyEngagementRates // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
      dailyEngagementRates: freezed == dailyEngagementRates
          ? _value.dailyEngagementRates
          : dailyEngagementRates // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OptimalTimingAnalysisImplCopyWith<$Res>
    implements $OptimalTimingAnalysisCopyWith<$Res> {
  factory _$$OptimalTimingAnalysisImplCopyWith(
          _$OptimalTimingAnalysisImpl value,
          $Res Function(_$OptimalTimingAnalysisImpl) then) =
      __$$OptimalTimingAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      NotificationCategory category,
      DateTime analyzedAt,
      List<int> optimalHours,
      List<int> optimalDaysOfWeek,
      double confidence,
      int sampleSize,
      Map<String, double>? hourlyEngagementRates,
      Map<String, double>? dailyEngagementRates});
}

/// @nodoc
class __$$OptimalTimingAnalysisImplCopyWithImpl<$Res>
    extends _$OptimalTimingAnalysisCopyWithImpl<$Res,
        _$OptimalTimingAnalysisImpl>
    implements _$$OptimalTimingAnalysisImplCopyWith<$Res> {
  __$$OptimalTimingAnalysisImplCopyWithImpl(_$OptimalTimingAnalysisImpl _value,
      $Res Function(_$OptimalTimingAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? category = null,
    Object? analyzedAt = null,
    Object? optimalHours = null,
    Object? optimalDaysOfWeek = null,
    Object? confidence = null,
    Object? sampleSize = null,
    Object? hourlyEngagementRates = freezed,
    Object? dailyEngagementRates = freezed,
  }) {
    return _then(_$OptimalTimingAnalysisImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optimalHours: null == optimalHours
          ? _value._optimalHours
          : optimalHours // ignore: cast_nullable_to_non_nullable
              as List<int>,
      optimalDaysOfWeek: null == optimalDaysOfWeek
          ? _value._optimalDaysOfWeek
          : optimalDaysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      sampleSize: null == sampleSize
          ? _value.sampleSize
          : sampleSize // ignore: cast_nullable_to_non_nullable
              as int,
      hourlyEngagementRates: freezed == hourlyEngagementRates
          ? _value._hourlyEngagementRates
          : hourlyEngagementRates // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
      dailyEngagementRates: freezed == dailyEngagementRates
          ? _value._dailyEngagementRates
          : dailyEngagementRates // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OptimalTimingAnalysisImpl implements _OptimalTimingAnalysis {
  const _$OptimalTimingAnalysisImpl(
      {required this.userId,
      required this.category,
      required this.analyzedAt,
      final List<int> optimalHours = const [],
      final List<int> optimalDaysOfWeek = const [],
      this.confidence = 0.0,
      this.sampleSize = 0,
      final Map<String, double>? hourlyEngagementRates,
      final Map<String, double>? dailyEngagementRates})
      : _optimalHours = optimalHours,
        _optimalDaysOfWeek = optimalDaysOfWeek,
        _hourlyEngagementRates = hourlyEngagementRates,
        _dailyEngagementRates = dailyEngagementRates;

  factory _$OptimalTimingAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptimalTimingAnalysisImplFromJson(json);

  @override
  final String userId;
  @override
  final NotificationCategory category;
  @override
  final DateTime analyzedAt;
  final List<int> _optimalHours;
  @override
  @JsonKey()
  List<int> get optimalHours {
    if (_optimalHours is EqualUnmodifiableListView) return _optimalHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optimalHours);
  }

// 最適な時間帯（0-23）
  final List<int> _optimalDaysOfWeek;
// 最適な時間帯（0-23）
  @override
  @JsonKey()
  List<int> get optimalDaysOfWeek {
    if (_optimalDaysOfWeek is EqualUnmodifiableListView)
      return _optimalDaysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optimalDaysOfWeek);
  }

// 最適な曜日（1-7）
  @override
  @JsonKey()
  final double confidence;
// 分析の信頼度
  @override
  @JsonKey()
  final int sampleSize;
// サンプル数
  final Map<String, double>? _hourlyEngagementRates;
// サンプル数
  @override
  Map<String, double>? get hourlyEngagementRates {
    final value = _hourlyEngagementRates;
    if (value == null) return null;
    if (_hourlyEngagementRates is EqualUnmodifiableMapView)
      return _hourlyEngagementRates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// 時間別エンゲージメント率
  final Map<String, double>? _dailyEngagementRates;
// 時間別エンゲージメント率
  @override
  Map<String, double>? get dailyEngagementRates {
    final value = _dailyEngagementRates;
    if (value == null) return null;
    if (_dailyEngagementRates is EqualUnmodifiableMapView)
      return _dailyEngagementRates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'OptimalTimingAnalysis(userId: $userId, category: $category, analyzedAt: $analyzedAt, optimalHours: $optimalHours, optimalDaysOfWeek: $optimalDaysOfWeek, confidence: $confidence, sampleSize: $sampleSize, hourlyEngagementRates: $hourlyEngagementRates, dailyEngagementRates: $dailyEngagementRates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptimalTimingAnalysisImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt) &&
            const DeepCollectionEquality()
                .equals(other._optimalHours, _optimalHours) &&
            const DeepCollectionEquality()
                .equals(other._optimalDaysOfWeek, _optimalDaysOfWeek) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.sampleSize, sampleSize) ||
                other.sampleSize == sampleSize) &&
            const DeepCollectionEquality()
                .equals(other._hourlyEngagementRates, _hourlyEngagementRates) &&
            const DeepCollectionEquality()
                .equals(other._dailyEngagementRates, _dailyEngagementRates));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      category,
      analyzedAt,
      const DeepCollectionEquality().hash(_optimalHours),
      const DeepCollectionEquality().hash(_optimalDaysOfWeek),
      confidence,
      sampleSize,
      const DeepCollectionEquality().hash(_hourlyEngagementRates),
      const DeepCollectionEquality().hash(_dailyEngagementRates));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OptimalTimingAnalysisImplCopyWith<_$OptimalTimingAnalysisImpl>
      get copyWith => __$$OptimalTimingAnalysisImplCopyWithImpl<
          _$OptimalTimingAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OptimalTimingAnalysisImplToJson(
      this,
    );
  }
}

abstract class _OptimalTimingAnalysis implements OptimalTimingAnalysis {
  const factory _OptimalTimingAnalysis(
          {required final String userId,
          required final NotificationCategory category,
          required final DateTime analyzedAt,
          final List<int> optimalHours,
          final List<int> optimalDaysOfWeek,
          final double confidence,
          final int sampleSize,
          final Map<String, double>? hourlyEngagementRates,
          final Map<String, double>? dailyEngagementRates}) =
      _$OptimalTimingAnalysisImpl;

  factory _OptimalTimingAnalysis.fromJson(Map<String, dynamic> json) =
      _$OptimalTimingAnalysisImpl.fromJson;

  @override
  String get userId;
  @override
  NotificationCategory get category;
  @override
  DateTime get analyzedAt;
  @override
  List<int> get optimalHours;
  @override // 最適な時間帯（0-23）
  List<int> get optimalDaysOfWeek;
  @override // 最適な曜日（1-7）
  double get confidence;
  @override // 分析の信頼度
  int get sampleSize;
  @override // サンプル数
  Map<String, double>? get hourlyEngagementRates;
  @override // 時間別エンゲージメント率
  Map<String, double>? get dailyEngagementRates;
  @override
  @JsonKey(ignore: true)
  _$$OptimalTimingAnalysisImplCopyWith<_$OptimalTimingAnalysisImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BehaviorPatternAnalysis _$BehaviorPatternAnalysisFromJson(
    Map<String, dynamic> json) {
  return _BehaviorPatternAnalysis.fromJson(json);
}

/// @nodoc
mixin _$BehaviorPatternAnalysis {
  String get userId => throw _privateConstructorUsedError;
  DateTime get analyzedAt => throw _privateConstructorUsedError;
  List<String> get activeHours =>
      throw _privateConstructorUsedError; // アクティブな時間帯
  List<String> get preferredCategories =>
      throw _privateConstructorUsedError; // 好みのカテゴリ
  double get engagementTrend =>
      throw _privateConstructorUsedError; // エンゲージメント傾向
  double get responsiveness => throw _privateConstructorUsedError; // 応答性スコア
  Duration get averageResponseTime =>
      throw _privateConstructorUsedError; // 平均応答時間
  Map<String, double>? get categoryPreferences =>
      throw _privateConstructorUsedError; // カテゴリ別好み度
  Map<String, double>? get timingPreferences =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BehaviorPatternAnalysisCopyWith<BehaviorPatternAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BehaviorPatternAnalysisCopyWith<$Res> {
  factory $BehaviorPatternAnalysisCopyWith(BehaviorPatternAnalysis value,
          $Res Function(BehaviorPatternAnalysis) then) =
      _$BehaviorPatternAnalysisCopyWithImpl<$Res, BehaviorPatternAnalysis>;
  @useResult
  $Res call(
      {String userId,
      DateTime analyzedAt,
      List<String> activeHours,
      List<String> preferredCategories,
      double engagementTrend,
      double responsiveness,
      Duration averageResponseTime,
      Map<String, double>? categoryPreferences,
      Map<String, double>? timingPreferences});
}

/// @nodoc
class _$BehaviorPatternAnalysisCopyWithImpl<$Res,
        $Val extends BehaviorPatternAnalysis>
    implements $BehaviorPatternAnalysisCopyWith<$Res> {
  _$BehaviorPatternAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? analyzedAt = null,
    Object? activeHours = null,
    Object? preferredCategories = null,
    Object? engagementTrend = null,
    Object? responsiveness = null,
    Object? averageResponseTime = null,
    Object? categoryPreferences = freezed,
    Object? timingPreferences = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      activeHours: null == activeHours
          ? _value.activeHours
          : activeHours // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredCategories: null == preferredCategories
          ? _value.preferredCategories
          : preferredCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      engagementTrend: null == engagementTrend
          ? _value.engagementTrend
          : engagementTrend // ignore: cast_nullable_to_non_nullable
              as double,
      responsiveness: null == responsiveness
          ? _value.responsiveness
          : responsiveness // ignore: cast_nullable_to_non_nullable
              as double,
      averageResponseTime: null == averageResponseTime
          ? _value.averageResponseTime
          : averageResponseTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      categoryPreferences: freezed == categoryPreferences
          ? _value.categoryPreferences
          : categoryPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
      timingPreferences: freezed == timingPreferences
          ? _value.timingPreferences
          : timingPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BehaviorPatternAnalysisImplCopyWith<$Res>
    implements $BehaviorPatternAnalysisCopyWith<$Res> {
  factory _$$BehaviorPatternAnalysisImplCopyWith(
          _$BehaviorPatternAnalysisImpl value,
          $Res Function(_$BehaviorPatternAnalysisImpl) then) =
      __$$BehaviorPatternAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime analyzedAt,
      List<String> activeHours,
      List<String> preferredCategories,
      double engagementTrend,
      double responsiveness,
      Duration averageResponseTime,
      Map<String, double>? categoryPreferences,
      Map<String, double>? timingPreferences});
}

/// @nodoc
class __$$BehaviorPatternAnalysisImplCopyWithImpl<$Res>
    extends _$BehaviorPatternAnalysisCopyWithImpl<$Res,
        _$BehaviorPatternAnalysisImpl>
    implements _$$BehaviorPatternAnalysisImplCopyWith<$Res> {
  __$$BehaviorPatternAnalysisImplCopyWithImpl(
      _$BehaviorPatternAnalysisImpl _value,
      $Res Function(_$BehaviorPatternAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? analyzedAt = null,
    Object? activeHours = null,
    Object? preferredCategories = null,
    Object? engagementTrend = null,
    Object? responsiveness = null,
    Object? averageResponseTime = null,
    Object? categoryPreferences = freezed,
    Object? timingPreferences = freezed,
  }) {
    return _then(_$BehaviorPatternAnalysisImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      analyzedAt: null == analyzedAt
          ? _value.analyzedAt
          : analyzedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      activeHours: null == activeHours
          ? _value._activeHours
          : activeHours // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredCategories: null == preferredCategories
          ? _value._preferredCategories
          : preferredCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      engagementTrend: null == engagementTrend
          ? _value.engagementTrend
          : engagementTrend // ignore: cast_nullable_to_non_nullable
              as double,
      responsiveness: null == responsiveness
          ? _value.responsiveness
          : responsiveness // ignore: cast_nullable_to_non_nullable
              as double,
      averageResponseTime: null == averageResponseTime
          ? _value.averageResponseTime
          : averageResponseTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      categoryPreferences: freezed == categoryPreferences
          ? _value._categoryPreferences
          : categoryPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
      timingPreferences: freezed == timingPreferences
          ? _value._timingPreferences
          : timingPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, double>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BehaviorPatternAnalysisImpl implements _BehaviorPatternAnalysis {
  const _$BehaviorPatternAnalysisImpl(
      {required this.userId,
      required this.analyzedAt,
      final List<String> activeHours = const [],
      final List<String> preferredCategories = const [],
      this.engagementTrend = 0.0,
      this.responsiveness = 0.0,
      this.averageResponseTime = Duration.zero,
      final Map<String, double>? categoryPreferences,
      final Map<String, double>? timingPreferences})
      : _activeHours = activeHours,
        _preferredCategories = preferredCategories,
        _categoryPreferences = categoryPreferences,
        _timingPreferences = timingPreferences;

  factory _$BehaviorPatternAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$BehaviorPatternAnalysisImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime analyzedAt;
  final List<String> _activeHours;
  @override
  @JsonKey()
  List<String> get activeHours {
    if (_activeHours is EqualUnmodifiableListView) return _activeHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeHours);
  }

// アクティブな時間帯
  final List<String> _preferredCategories;
// アクティブな時間帯
  @override
  @JsonKey()
  List<String> get preferredCategories {
    if (_preferredCategories is EqualUnmodifiableListView)
      return _preferredCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredCategories);
  }

// 好みのカテゴリ
  @override
  @JsonKey()
  final double engagementTrend;
// エンゲージメント傾向
  @override
  @JsonKey()
  final double responsiveness;
// 応答性スコア
  @override
  @JsonKey()
  final Duration averageResponseTime;
// 平均応答時間
  final Map<String, double>? _categoryPreferences;
// 平均応答時間
  @override
  Map<String, double>? get categoryPreferences {
    final value = _categoryPreferences;
    if (value == null) return null;
    if (_categoryPreferences is EqualUnmodifiableMapView)
      return _categoryPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// カテゴリ別好み度
  final Map<String, double>? _timingPreferences;
// カテゴリ別好み度
  @override
  Map<String, double>? get timingPreferences {
    final value = _timingPreferences;
    if (value == null) return null;
    if (_timingPreferences is EqualUnmodifiableMapView)
      return _timingPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BehaviorPatternAnalysis(userId: $userId, analyzedAt: $analyzedAt, activeHours: $activeHours, preferredCategories: $preferredCategories, engagementTrend: $engagementTrend, responsiveness: $responsiveness, averageResponseTime: $averageResponseTime, categoryPreferences: $categoryPreferences, timingPreferences: $timingPreferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BehaviorPatternAnalysisImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt) &&
            const DeepCollectionEquality()
                .equals(other._activeHours, _activeHours) &&
            const DeepCollectionEquality()
                .equals(other._preferredCategories, _preferredCategories) &&
            (identical(other.engagementTrend, engagementTrend) ||
                other.engagementTrend == engagementTrend) &&
            (identical(other.responsiveness, responsiveness) ||
                other.responsiveness == responsiveness) &&
            (identical(other.averageResponseTime, averageResponseTime) ||
                other.averageResponseTime == averageResponseTime) &&
            const DeepCollectionEquality()
                .equals(other._categoryPreferences, _categoryPreferences) &&
            const DeepCollectionEquality()
                .equals(other._timingPreferences, _timingPreferences));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      analyzedAt,
      const DeepCollectionEquality().hash(_activeHours),
      const DeepCollectionEquality().hash(_preferredCategories),
      engagementTrend,
      responsiveness,
      averageResponseTime,
      const DeepCollectionEquality().hash(_categoryPreferences),
      const DeepCollectionEquality().hash(_timingPreferences));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BehaviorPatternAnalysisImplCopyWith<_$BehaviorPatternAnalysisImpl>
      get copyWith => __$$BehaviorPatternAnalysisImplCopyWithImpl<
          _$BehaviorPatternAnalysisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BehaviorPatternAnalysisImplToJson(
      this,
    );
  }
}

abstract class _BehaviorPatternAnalysis implements BehaviorPatternAnalysis {
  const factory _BehaviorPatternAnalysis(
          {required final String userId,
          required final DateTime analyzedAt,
          final List<String> activeHours,
          final List<String> preferredCategories,
          final double engagementTrend,
          final double responsiveness,
          final Duration averageResponseTime,
          final Map<String, double>? categoryPreferences,
          final Map<String, double>? timingPreferences}) =
      _$BehaviorPatternAnalysisImpl;

  factory _BehaviorPatternAnalysis.fromJson(Map<String, dynamic> json) =
      _$BehaviorPatternAnalysisImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get analyzedAt;
  @override
  List<String> get activeHours;
  @override // アクティブな時間帯
  List<String> get preferredCategories;
  @override // 好みのカテゴリ
  double get engagementTrend;
  @override // エンゲージメント傾向
  double get responsiveness;
  @override // 応答性スコア
  Duration get averageResponseTime;
  @override // 平均応答時間
  Map<String, double>? get categoryPreferences;
  @override // カテゴリ別好み度
  Map<String, double>? get timingPreferences;
  @override
  @JsonKey(ignore: true)
  _$$BehaviorPatternAnalysisImplCopyWith<_$BehaviorPatternAnalysisImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationABTestResult _$NotificationABTestResultFromJson(
    Map<String, dynamic> json) {
  return _NotificationABTestResult.fromJson(json);
}

/// @nodoc
mixin _$NotificationABTestResult {
  String get testId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  NotificationCategory get category => throw _privateConstructorUsedError;
  String get variant => throw _privateConstructorUsedError; // A, B, C等
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get impressions => throw _privateConstructorUsedError;
  int get conversions => throw _privateConstructorUsedError;
  double get conversionRate => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  Map<String, dynamic>? get testParameters =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationABTestResultCopyWith<NotificationABTestResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationABTestResultCopyWith<$Res> {
  factory $NotificationABTestResultCopyWith(NotificationABTestResult value,
          $Res Function(NotificationABTestResult) then) =
      _$NotificationABTestResultCopyWithImpl<$Res, NotificationABTestResult>;
  @useResult
  $Res call(
      {String testId,
      String userId,
      NotificationCategory category,
      String variant,
      DateTime startDate,
      DateTime endDate,
      int impressions,
      int conversions,
      double conversionRate,
      double confidence,
      Map<String, dynamic>? testParameters});
}

/// @nodoc
class _$NotificationABTestResultCopyWithImpl<$Res,
        $Val extends NotificationABTestResult>
    implements $NotificationABTestResultCopyWith<$Res> {
  _$NotificationABTestResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? userId = null,
    Object? category = null,
    Object? variant = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? impressions = null,
    Object? conversions = null,
    Object? conversionRate = null,
    Object? confidence = null,
    Object? testParameters = freezed,
  }) {
    return _then(_value.copyWith(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      variant: null == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      impressions: null == impressions
          ? _value.impressions
          : impressions // ignore: cast_nullable_to_non_nullable
              as int,
      conversions: null == conversions
          ? _value.conversions
          : conversions // ignore: cast_nullable_to_non_nullable
              as int,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      testParameters: freezed == testParameters
          ? _value.testParameters
          : testParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationABTestResultImplCopyWith<$Res>
    implements $NotificationABTestResultCopyWith<$Res> {
  factory _$$NotificationABTestResultImplCopyWith(
          _$NotificationABTestResultImpl value,
          $Res Function(_$NotificationABTestResultImpl) then) =
      __$$NotificationABTestResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String testId,
      String userId,
      NotificationCategory category,
      String variant,
      DateTime startDate,
      DateTime endDate,
      int impressions,
      int conversions,
      double conversionRate,
      double confidence,
      Map<String, dynamic>? testParameters});
}

/// @nodoc
class __$$NotificationABTestResultImplCopyWithImpl<$Res>
    extends _$NotificationABTestResultCopyWithImpl<$Res,
        _$NotificationABTestResultImpl>
    implements _$$NotificationABTestResultImplCopyWith<$Res> {
  __$$NotificationABTestResultImplCopyWithImpl(
      _$NotificationABTestResultImpl _value,
      $Res Function(_$NotificationABTestResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? testId = null,
    Object? userId = null,
    Object? category = null,
    Object? variant = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? impressions = null,
    Object? conversions = null,
    Object? conversionRate = null,
    Object? confidence = null,
    Object? testParameters = freezed,
  }) {
    return _then(_$NotificationABTestResultImpl(
      testId: null == testId
          ? _value.testId
          : testId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      variant: null == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      impressions: null == impressions
          ? _value.impressions
          : impressions // ignore: cast_nullable_to_non_nullable
              as int,
      conversions: null == conversions
          ? _value.conversions
          : conversions // ignore: cast_nullable_to_non_nullable
              as int,
      conversionRate: null == conversionRate
          ? _value.conversionRate
          : conversionRate // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      testParameters: freezed == testParameters
          ? _value._testParameters
          : testParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationABTestResultImpl implements _NotificationABTestResult {
  const _$NotificationABTestResultImpl(
      {required this.testId,
      required this.userId,
      required this.category,
      required this.variant,
      required this.startDate,
      required this.endDate,
      this.impressions = 0,
      this.conversions = 0,
      this.conversionRate = 0.0,
      this.confidence = 0.0,
      final Map<String, dynamic>? testParameters})
      : _testParameters = testParameters;

  factory _$NotificationABTestResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationABTestResultImplFromJson(json);

  @override
  final String testId;
  @override
  final String userId;
  @override
  final NotificationCategory category;
  @override
  final String variant;
// A, B, C等
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final int impressions;
  @override
  @JsonKey()
  final int conversions;
  @override
  @JsonKey()
  final double conversionRate;
  @override
  @JsonKey()
  final double confidence;
  final Map<String, dynamic>? _testParameters;
  @override
  Map<String, dynamic>? get testParameters {
    final value = _testParameters;
    if (value == null) return null;
    if (_testParameters is EqualUnmodifiableMapView) return _testParameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationABTestResult(testId: $testId, userId: $userId, category: $category, variant: $variant, startDate: $startDate, endDate: $endDate, impressions: $impressions, conversions: $conversions, conversionRate: $conversionRate, confidence: $confidence, testParameters: $testParameters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationABTestResultImpl &&
            (identical(other.testId, testId) || other.testId == testId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.variant, variant) || other.variant == variant) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.impressions, impressions) ||
                other.impressions == impressions) &&
            (identical(other.conversions, conversions) ||
                other.conversions == conversions) &&
            (identical(other.conversionRate, conversionRate) ||
                other.conversionRate == conversionRate) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality()
                .equals(other._testParameters, _testParameters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      testId,
      userId,
      category,
      variant,
      startDate,
      endDate,
      impressions,
      conversions,
      conversionRate,
      confidence,
      const DeepCollectionEquality().hash(_testParameters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationABTestResultImplCopyWith<_$NotificationABTestResultImpl>
      get copyWith => __$$NotificationABTestResultImplCopyWithImpl<
          _$NotificationABTestResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationABTestResultImplToJson(
      this,
    );
  }
}

abstract class _NotificationABTestResult implements NotificationABTestResult {
  const factory _NotificationABTestResult(
          {required final String testId,
          required final String userId,
          required final NotificationCategory category,
          required final String variant,
          required final DateTime startDate,
          required final DateTime endDate,
          final int impressions,
          final int conversions,
          final double conversionRate,
          final double confidence,
          final Map<String, dynamic>? testParameters}) =
      _$NotificationABTestResultImpl;

  factory _NotificationABTestResult.fromJson(Map<String, dynamic> json) =
      _$NotificationABTestResultImpl.fromJson;

  @override
  String get testId;
  @override
  String get userId;
  @override
  NotificationCategory get category;
  @override
  String get variant;
  @override // A, B, C等
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get impressions;
  @override
  int get conversions;
  @override
  double get conversionRate;
  @override
  double get confidence;
  @override
  Map<String, dynamic>? get testParameters;
  @override
  @JsonKey(ignore: true)
  _$$NotificationABTestResultImplCopyWith<_$NotificationABTestResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
