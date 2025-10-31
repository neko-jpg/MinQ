// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) {
  return _TimeSlot.fromJson(json);
}

/// @nodoc
mixin _$TimeSlot {
  int get startHour => throw _privateConstructorUsedError;
  int get startMinute => throw _privateConstructorUsedError;
  int get endHour => throw _privateConstructorUsedError;
  int get endMinute => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeSlotCopyWith<TimeSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSlotCopyWith<$Res> {
  factory $TimeSlotCopyWith(TimeSlot value, $Res Function(TimeSlot) then) =
      _$TimeSlotCopyWithImpl<$Res, TimeSlot>;
  @useResult
  $Res call({int startHour, int startMinute, int endHour, int endMinute});
}

/// @nodoc
class _$TimeSlotCopyWithImpl<$Res, $Val extends TimeSlot>
    implements $TimeSlotCopyWith<$Res> {
  _$TimeSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startHour = null,
    Object? startMinute = null,
    Object? endHour = null,
    Object? endMinute = null,
  }) {
    return _then(_value.copyWith(
      startHour: null == startHour
          ? _value.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as int,
      startMinute: null == startMinute
          ? _value.startMinute
          : startMinute // ignore: cast_nullable_to_non_nullable
              as int,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as int,
      endMinute: null == endMinute
          ? _value.endMinute
          : endMinute // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeSlotImplCopyWith<$Res>
    implements $TimeSlotCopyWith<$Res> {
  factory _$$TimeSlotImplCopyWith(
          _$TimeSlotImpl value, $Res Function(_$TimeSlotImpl) then) =
      __$$TimeSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int startHour, int startMinute, int endHour, int endMinute});
}

/// @nodoc
class __$$TimeSlotImplCopyWithImpl<$Res>
    extends _$TimeSlotCopyWithImpl<$Res, _$TimeSlotImpl>
    implements _$$TimeSlotImplCopyWith<$Res> {
  __$$TimeSlotImplCopyWithImpl(
      _$TimeSlotImpl _value, $Res Function(_$TimeSlotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startHour = null,
    Object? startMinute = null,
    Object? endHour = null,
    Object? endMinute = null,
  }) {
    return _then(_$TimeSlotImpl(
      startHour: null == startHour
          ? _value.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as int,
      startMinute: null == startMinute
          ? _value.startMinute
          : startMinute // ignore: cast_nullable_to_non_nullable
              as int,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as int,
      endMinute: null == endMinute
          ? _value.endMinute
          : endMinute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeSlotImpl implements _TimeSlot {
  const _$TimeSlotImpl(
      {required this.startHour,
      required this.startMinute,
      required this.endHour,
      required this.endMinute});

  factory _$TimeSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSlotImplFromJson(json);

  @override
  final int startHour;
  @override
  final int startMinute;
  @override
  final int endHour;
  @override
  final int endMinute;

  @override
  String toString() {
    return 'TimeSlot(startHour: $startHour, startMinute: $startMinute, endHour: $endHour, endMinute: $endMinute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSlotImpl &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.startMinute, startMinute) ||
                other.startMinute == startMinute) &&
            (identical(other.endHour, endHour) || other.endHour == endHour) &&
            (identical(other.endMinute, endMinute) ||
                other.endMinute == endMinute));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, startHour, startMinute, endHour, endMinute);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      __$$TimeSlotImplCopyWithImpl<_$TimeSlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSlotImplToJson(
      this,
    );
  }
}

abstract class _TimeSlot implements TimeSlot {
  const factory _TimeSlot(
      {required final int startHour,
      required final int startMinute,
      required final int endHour,
      required final int endMinute}) = _$TimeSlotImpl;

  factory _TimeSlot.fromJson(Map<String, dynamic> json) =
      _$TimeSlotImpl.fromJson;

  @override
  int get startHour;
  @override
  int get startMinute;
  @override
  int get endHour;
  @override
  int get endMinute;
  @override
  @JsonKey(ignore: true)
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryNotificationSettings _$CategoryNotificationSettingsFromJson(
    Map<String, dynamic> json) {
  return _CategoryNotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$CategoryNotificationSettings {
  NotificationCategory get category => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  NotificationFrequency get frequency => throw _privateConstructorUsedError;
  bool get sound => throw _privateConstructorUsedError;
  bool get vibration => throw _privateConstructorUsedError;
  bool get badge => throw _privateConstructorUsedError;
  bool get lockScreen => throw _privateConstructorUsedError;
  String? get customSound => throw _privateConstructorUsedError;
  List<int>? get vibrationPattern => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoryNotificationSettingsCopyWith<CategoryNotificationSettings>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryNotificationSettingsCopyWith<$Res> {
  factory $CategoryNotificationSettingsCopyWith(
          CategoryNotificationSettings value,
          $Res Function(CategoryNotificationSettings) then) =
      _$CategoryNotificationSettingsCopyWithImpl<$Res,
          CategoryNotificationSettings>;
  @useResult
  $Res call(
      {NotificationCategory category,
      bool enabled,
      NotificationFrequency frequency,
      bool sound,
      bool vibration,
      bool badge,
      bool lockScreen,
      String? customSound,
      List<int>? vibrationPattern});
}

/// @nodoc
class _$CategoryNotificationSettingsCopyWithImpl<$Res,
        $Val extends CategoryNotificationSettings>
    implements $CategoryNotificationSettingsCopyWith<$Res> {
  _$CategoryNotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? enabled = null,
    Object? frequency = null,
    Object? sound = null,
    Object? vibration = null,
    Object? badge = null,
    Object? lockScreen = null,
    Object? customSound = freezed,
    Object? vibrationPattern = freezed,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as NotificationFrequency,
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool,
      vibration: null == vibration
          ? _value.vibration
          : vibration // ignore: cast_nullable_to_non_nullable
              as bool,
      badge: null == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as bool,
      lockScreen: null == lockScreen
          ? _value.lockScreen
          : lockScreen // ignore: cast_nullable_to_non_nullable
              as bool,
      customSound: freezed == customSound
          ? _value.customSound
          : customSound // ignore: cast_nullable_to_non_nullable
              as String?,
      vibrationPattern: freezed == vibrationPattern
          ? _value.vibrationPattern
          : vibrationPattern // ignore: cast_nullable_to_non_nullable
              as List<int>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryNotificationSettingsImplCopyWith<$Res>
    implements $CategoryNotificationSettingsCopyWith<$Res> {
  factory _$$CategoryNotificationSettingsImplCopyWith(
          _$CategoryNotificationSettingsImpl value,
          $Res Function(_$CategoryNotificationSettingsImpl) then) =
      __$$CategoryNotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {NotificationCategory category,
      bool enabled,
      NotificationFrequency frequency,
      bool sound,
      bool vibration,
      bool badge,
      bool lockScreen,
      String? customSound,
      List<int>? vibrationPattern});
}

/// @nodoc
class __$$CategoryNotificationSettingsImplCopyWithImpl<$Res>
    extends _$CategoryNotificationSettingsCopyWithImpl<$Res,
        _$CategoryNotificationSettingsImpl>
    implements _$$CategoryNotificationSettingsImplCopyWith<$Res> {
  __$$CategoryNotificationSettingsImplCopyWithImpl(
      _$CategoryNotificationSettingsImpl _value,
      $Res Function(_$CategoryNotificationSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? enabled = null,
    Object? frequency = null,
    Object? sound = null,
    Object? vibration = null,
    Object? badge = null,
    Object? lockScreen = null,
    Object? customSound = freezed,
    Object? vibrationPattern = freezed,
  }) {
    return _then(_$CategoryNotificationSettingsImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as NotificationFrequency,
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool,
      vibration: null == vibration
          ? _value.vibration
          : vibration // ignore: cast_nullable_to_non_nullable
              as bool,
      badge: null == badge
          ? _value.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as bool,
      lockScreen: null == lockScreen
          ? _value.lockScreen
          : lockScreen // ignore: cast_nullable_to_non_nullable
              as bool,
      customSound: freezed == customSound
          ? _value.customSound
          : customSound // ignore: cast_nullable_to_non_nullable
              as String?,
      vibrationPattern: freezed == vibrationPattern
          ? _value._vibrationPattern
          : vibrationPattern // ignore: cast_nullable_to_non_nullable
              as List<int>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryNotificationSettingsImpl
    implements _CategoryNotificationSettings {
  const _$CategoryNotificationSettingsImpl(
      {required this.category,
      this.enabled = true,
      this.frequency = NotificationFrequency.immediate,
      this.sound = true,
      this.vibration = true,
      this.badge = true,
      this.lockScreen = true,
      this.customSound,
      final List<int>? vibrationPattern})
      : _vibrationPattern = vibrationPattern;

  factory _$CategoryNotificationSettingsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CategoryNotificationSettingsImplFromJson(json);

  @override
  final NotificationCategory category;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final NotificationFrequency frequency;
  @override
  @JsonKey()
  final bool sound;
  @override
  @JsonKey()
  final bool vibration;
  @override
  @JsonKey()
  final bool badge;
  @override
  @JsonKey()
  final bool lockScreen;
  @override
  final String? customSound;
  final List<int>? _vibrationPattern;
  @override
  List<int>? get vibrationPattern {
    final value = _vibrationPattern;
    if (value == null) return null;
    if (_vibrationPattern is EqualUnmodifiableListView)
      return _vibrationPattern;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CategoryNotificationSettings(category: $category, enabled: $enabled, frequency: $frequency, sound: $sound, vibration: $vibration, badge: $badge, lockScreen: $lockScreen, customSound: $customSound, vibrationPattern: $vibrationPattern)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryNotificationSettingsImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.vibration, vibration) ||
                other.vibration == vibration) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            (identical(other.lockScreen, lockScreen) ||
                other.lockScreen == lockScreen) &&
            (identical(other.customSound, customSound) ||
                other.customSound == customSound) &&
            const DeepCollectionEquality()
                .equals(other._vibrationPattern, _vibrationPattern));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      category,
      enabled,
      frequency,
      sound,
      vibration,
      badge,
      lockScreen,
      customSound,
      const DeepCollectionEquality().hash(_vibrationPattern));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryNotificationSettingsImplCopyWith<
          _$CategoryNotificationSettingsImpl>
      get copyWith => __$$CategoryNotificationSettingsImplCopyWithImpl<
          _$CategoryNotificationSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryNotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _CategoryNotificationSettings
    implements CategoryNotificationSettings {
  const factory _CategoryNotificationSettings(
      {required final NotificationCategory category,
      final bool enabled,
      final NotificationFrequency frequency,
      final bool sound,
      final bool vibration,
      final bool badge,
      final bool lockScreen,
      final String? customSound,
      final List<int>? vibrationPattern}) = _$CategoryNotificationSettingsImpl;

  factory _CategoryNotificationSettings.fromJson(Map<String, dynamic> json) =
      _$CategoryNotificationSettingsImpl.fromJson;

  @override
  NotificationCategory get category;
  @override
  bool get enabled;
  @override
  NotificationFrequency get frequency;
  @override
  bool get sound;
  @override
  bool get vibration;
  @override
  bool get badge;
  @override
  bool get lockScreen;
  @override
  String? get customSound;
  @override
  List<int>? get vibrationPattern;
  @override
  @JsonKey(ignore: true)
  _$$CategoryNotificationSettingsImplCopyWith<
          _$CategoryNotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TimeBasedNotificationSettings _$TimeBasedNotificationSettingsFromJson(
    Map<String, dynamic> json) {
  return _TimeBasedNotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$TimeBasedNotificationSettings {
  bool get enabled => throw _privateConstructorUsedError;
  TimeSlot? get sleepTime => throw _privateConstructorUsedError; // 就寝時間（通知停止）
  TimeSlot? get workTime => throw _privateConstructorUsedError; // 勤務時間（制限モード）
  List<TimeSlot> get customQuietHours =>
      throw _privateConstructorUsedError; // カスタム静音時間
  bool get respectSystemDnd =>
      throw _privateConstructorUsedError; // システムのDNDモードを尊重
  bool get weekendMode => throw _privateConstructorUsedError; // 週末モード（異なる時間設定）
  TimeSlot? get weekendSleepTime => throw _privateConstructorUsedError;
  TimeSlot? get weekendWorkTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeBasedNotificationSettingsCopyWith<TimeBasedNotificationSettings>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeBasedNotificationSettingsCopyWith<$Res> {
  factory $TimeBasedNotificationSettingsCopyWith(
          TimeBasedNotificationSettings value,
          $Res Function(TimeBasedNotificationSettings) then) =
      _$TimeBasedNotificationSettingsCopyWithImpl<$Res,
          TimeBasedNotificationSettings>;
  @useResult
  $Res call(
      {bool enabled,
      TimeSlot? sleepTime,
      TimeSlot? workTime,
      List<TimeSlot> customQuietHours,
      bool respectSystemDnd,
      bool weekendMode,
      TimeSlot? weekendSleepTime,
      TimeSlot? weekendWorkTime});

  $TimeSlotCopyWith<$Res>? get sleepTime;
  $TimeSlotCopyWith<$Res>? get workTime;
  $TimeSlotCopyWith<$Res>? get weekendSleepTime;
  $TimeSlotCopyWith<$Res>? get weekendWorkTime;
}

/// @nodoc
class _$TimeBasedNotificationSettingsCopyWithImpl<$Res,
        $Val extends TimeBasedNotificationSettings>
    implements $TimeBasedNotificationSettingsCopyWith<$Res> {
  _$TimeBasedNotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? sleepTime = freezed,
    Object? workTime = freezed,
    Object? customQuietHours = null,
    Object? respectSystemDnd = null,
    Object? weekendMode = null,
    Object? weekendSleepTime = freezed,
    Object? weekendWorkTime = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepTime: freezed == sleepTime
          ? _value.sleepTime
          : sleepTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
      workTime: freezed == workTime
          ? _value.workTime
          : workTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
      customQuietHours: null == customQuietHours
          ? _value.customQuietHours
          : customQuietHours // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      respectSystemDnd: null == respectSystemDnd
          ? _value.respectSystemDnd
          : respectSystemDnd // ignore: cast_nullable_to_non_nullable
              as bool,
      weekendMode: null == weekendMode
          ? _value.weekendMode
          : weekendMode // ignore: cast_nullable_to_non_nullable
              as bool,
      weekendSleepTime: freezed == weekendSleepTime
          ? _value.weekendSleepTime
          : weekendSleepTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
      weekendWorkTime: freezed == weekendWorkTime
          ? _value.weekendWorkTime
          : weekendWorkTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeSlotCopyWith<$Res>? get sleepTime {
    if (_value.sleepTime == null) {
      return null;
    }

    return $TimeSlotCopyWith<$Res>(_value.sleepTime!, (value) {
      return _then(_value.copyWith(sleepTime: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeSlotCopyWith<$Res>? get workTime {
    if (_value.workTime == null) {
      return null;
    }

    return $TimeSlotCopyWith<$Res>(_value.workTime!, (value) {
      return _then(_value.copyWith(workTime: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeSlotCopyWith<$Res>? get weekendSleepTime {
    if (_value.weekendSleepTime == null) {
      return null;
    }

    return $TimeSlotCopyWith<$Res>(_value.weekendSleepTime!, (value) {
      return _then(_value.copyWith(weekendSleepTime: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeSlotCopyWith<$Res>? get weekendWorkTime {
    if (_value.weekendWorkTime == null) {
      return null;
    }

    return $TimeSlotCopyWith<$Res>(_value.weekendWorkTime!, (value) {
      return _then(_value.copyWith(weekendWorkTime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TimeBasedNotificationSettingsImplCopyWith<$Res>
    implements $TimeBasedNotificationSettingsCopyWith<$Res> {
  factory _$$TimeBasedNotificationSettingsImplCopyWith(
          _$TimeBasedNotificationSettingsImpl value,
          $Res Function(_$TimeBasedNotificationSettingsImpl) then) =
      __$$TimeBasedNotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      TimeSlot? sleepTime,
      TimeSlot? workTime,
      List<TimeSlot> customQuietHours,
      bool respectSystemDnd,
      bool weekendMode,
      TimeSlot? weekendSleepTime,
      TimeSlot? weekendWorkTime});

  @override
  $TimeSlotCopyWith<$Res>? get sleepTime;
  @override
  $TimeSlotCopyWith<$Res>? get workTime;
  @override
  $TimeSlotCopyWith<$Res>? get weekendSleepTime;
  @override
  $TimeSlotCopyWith<$Res>? get weekendWorkTime;
}

/// @nodoc
class __$$TimeBasedNotificationSettingsImplCopyWithImpl<$Res>
    extends _$TimeBasedNotificationSettingsCopyWithImpl<$Res,
        _$TimeBasedNotificationSettingsImpl>
    implements _$$TimeBasedNotificationSettingsImplCopyWith<$Res> {
  __$$TimeBasedNotificationSettingsImplCopyWithImpl(
      _$TimeBasedNotificationSettingsImpl _value,
      $Res Function(_$TimeBasedNotificationSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? sleepTime = freezed,
    Object? workTime = freezed,
    Object? customQuietHours = null,
    Object? respectSystemDnd = null,
    Object? weekendMode = null,
    Object? weekendSleepTime = freezed,
    Object? weekendWorkTime = freezed,
  }) {
    return _then(_$TimeBasedNotificationSettingsImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      sleepTime: freezed == sleepTime
          ? _value.sleepTime
          : sleepTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
      workTime: freezed == workTime
          ? _value.workTime
          : workTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
      customQuietHours: null == customQuietHours
          ? _value._customQuietHours
          : customQuietHours // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      respectSystemDnd: null == respectSystemDnd
          ? _value.respectSystemDnd
          : respectSystemDnd // ignore: cast_nullable_to_non_nullable
              as bool,
      weekendMode: null == weekendMode
          ? _value.weekendMode
          : weekendMode // ignore: cast_nullable_to_non_nullable
              as bool,
      weekendSleepTime: freezed == weekendSleepTime
          ? _value.weekendSleepTime
          : weekendSleepTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
      weekendWorkTime: freezed == weekendWorkTime
          ? _value.weekendWorkTime
          : weekendWorkTime // ignore: cast_nullable_to_non_nullable
              as TimeSlot?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeBasedNotificationSettingsImpl
    implements _TimeBasedNotificationSettings {
  const _$TimeBasedNotificationSettingsImpl(
      {this.enabled = true,
      this.sleepTime,
      this.workTime,
      final List<TimeSlot> customQuietHours = const [],
      this.respectSystemDnd = true,
      this.weekendMode = false,
      this.weekendSleepTime,
      this.weekendWorkTime})
      : _customQuietHours = customQuietHours;

  factory _$TimeBasedNotificationSettingsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$TimeBasedNotificationSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool enabled;
  @override
  final TimeSlot? sleepTime;
// 就寝時間（通知停止）
  @override
  final TimeSlot? workTime;
// 勤務時間（制限モード）
  final List<TimeSlot> _customQuietHours;
// 勤務時間（制限モード）
  @override
  @JsonKey()
  List<TimeSlot> get customQuietHours {
    if (_customQuietHours is EqualUnmodifiableListView)
      return _customQuietHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customQuietHours);
  }

// カスタム静音時間
  @override
  @JsonKey()
  final bool respectSystemDnd;
// システムのDNDモードを尊重
  @override
  @JsonKey()
  final bool weekendMode;
// 週末モード（異なる時間設定）
  @override
  final TimeSlot? weekendSleepTime;
  @override
  final TimeSlot? weekendWorkTime;

  @override
  String toString() {
    return 'TimeBasedNotificationSettings(enabled: $enabled, sleepTime: $sleepTime, workTime: $workTime, customQuietHours: $customQuietHours, respectSystemDnd: $respectSystemDnd, weekendMode: $weekendMode, weekendSleepTime: $weekendSleepTime, weekendWorkTime: $weekendWorkTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeBasedNotificationSettingsImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.sleepTime, sleepTime) ||
                other.sleepTime == sleepTime) &&
            (identical(other.workTime, workTime) ||
                other.workTime == workTime) &&
            const DeepCollectionEquality()
                .equals(other._customQuietHours, _customQuietHours) &&
            (identical(other.respectSystemDnd, respectSystemDnd) ||
                other.respectSystemDnd == respectSystemDnd) &&
            (identical(other.weekendMode, weekendMode) ||
                other.weekendMode == weekendMode) &&
            (identical(other.weekendSleepTime, weekendSleepTime) ||
                other.weekendSleepTime == weekendSleepTime) &&
            (identical(other.weekendWorkTime, weekendWorkTime) ||
                other.weekendWorkTime == weekendWorkTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enabled,
      sleepTime,
      workTime,
      const DeepCollectionEquality().hash(_customQuietHours),
      respectSystemDnd,
      weekendMode,
      weekendSleepTime,
      weekendWorkTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeBasedNotificationSettingsImplCopyWith<
          _$TimeBasedNotificationSettingsImpl>
      get copyWith => __$$TimeBasedNotificationSettingsImplCopyWithImpl<
          _$TimeBasedNotificationSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeBasedNotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _TimeBasedNotificationSettings
    implements TimeBasedNotificationSettings {
  const factory _TimeBasedNotificationSettings(
      {final bool enabled,
      final TimeSlot? sleepTime,
      final TimeSlot? workTime,
      final List<TimeSlot> customQuietHours,
      final bool respectSystemDnd,
      final bool weekendMode,
      final TimeSlot? weekendSleepTime,
      final TimeSlot? weekendWorkTime}) = _$TimeBasedNotificationSettingsImpl;

  factory _TimeBasedNotificationSettings.fromJson(Map<String, dynamic> json) =
      _$TimeBasedNotificationSettingsImpl.fromJson;

  @override
  bool get enabled;
  @override
  TimeSlot? get sleepTime;
  @override // 就寝時間（通知停止）
  TimeSlot? get workTime;
  @override // 勤務時間（制限モード）
  List<TimeSlot> get customQuietHours;
  @override // カスタム静音時間
  bool get respectSystemDnd;
  @override // システムのDNDモードを尊重
  bool get weekendMode;
  @override // 週末モード（異なる時間設定）
  TimeSlot? get weekendSleepTime;
  @override
  TimeSlot? get weekendWorkTime;
  @override
  @JsonKey(ignore: true)
  _$$TimeBasedNotificationSettingsImplCopyWith<
          _$TimeBasedNotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SmartNotificationSettings _$SmartNotificationSettingsFromJson(
    Map<String, dynamic> json) {
  return _SmartNotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$SmartNotificationSettings {
  bool get enabled => throw _privateConstructorUsedError;
  bool get behaviorLearning => throw _privateConstructorUsedError; // 行動パターン学習
  bool get adaptiveFrequency => throw _privateConstructorUsedError; // 適応的頻度調整
  bool get contextAware => throw _privateConstructorUsedError; // コンテキスト認識
  bool get engagementOptimization =>
      throw _privateConstructorUsedError; // エンゲージメント最適化
  double get confidenceThreshold =>
      throw _privateConstructorUsedError; // 予測信頼度閾値
  int get learningPeriodDays => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SmartNotificationSettingsCopyWith<SmartNotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmartNotificationSettingsCopyWith<$Res> {
  factory $SmartNotificationSettingsCopyWith(SmartNotificationSettings value,
          $Res Function(SmartNotificationSettings) then) =
      _$SmartNotificationSettingsCopyWithImpl<$Res, SmartNotificationSettings>;
  @useResult
  $Res call(
      {bool enabled,
      bool behaviorLearning,
      bool adaptiveFrequency,
      bool contextAware,
      bool engagementOptimization,
      double confidenceThreshold,
      int learningPeriodDays});
}

/// @nodoc
class _$SmartNotificationSettingsCopyWithImpl<$Res,
        $Val extends SmartNotificationSettings>
    implements $SmartNotificationSettingsCopyWith<$Res> {
  _$SmartNotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? behaviorLearning = null,
    Object? adaptiveFrequency = null,
    Object? contextAware = null,
    Object? engagementOptimization = null,
    Object? confidenceThreshold = null,
    Object? learningPeriodDays = null,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      behaviorLearning: null == behaviorLearning
          ? _value.behaviorLearning
          : behaviorLearning // ignore: cast_nullable_to_non_nullable
              as bool,
      adaptiveFrequency: null == adaptiveFrequency
          ? _value.adaptiveFrequency
          : adaptiveFrequency // ignore: cast_nullable_to_non_nullable
              as bool,
      contextAware: null == contextAware
          ? _value.contextAware
          : contextAware // ignore: cast_nullable_to_non_nullable
              as bool,
      engagementOptimization: null == engagementOptimization
          ? _value.engagementOptimization
          : engagementOptimization // ignore: cast_nullable_to_non_nullable
              as bool,
      confidenceThreshold: null == confidenceThreshold
          ? _value.confidenceThreshold
          : confidenceThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      learningPeriodDays: null == learningPeriodDays
          ? _value.learningPeriodDays
          : learningPeriodDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SmartNotificationSettingsImplCopyWith<$Res>
    implements $SmartNotificationSettingsCopyWith<$Res> {
  factory _$$SmartNotificationSettingsImplCopyWith(
          _$SmartNotificationSettingsImpl value,
          $Res Function(_$SmartNotificationSettingsImpl) then) =
      __$$SmartNotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      bool behaviorLearning,
      bool adaptiveFrequency,
      bool contextAware,
      bool engagementOptimization,
      double confidenceThreshold,
      int learningPeriodDays});
}

/// @nodoc
class __$$SmartNotificationSettingsImplCopyWithImpl<$Res>
    extends _$SmartNotificationSettingsCopyWithImpl<$Res,
        _$SmartNotificationSettingsImpl>
    implements _$$SmartNotificationSettingsImplCopyWith<$Res> {
  __$$SmartNotificationSettingsImplCopyWithImpl(
      _$SmartNotificationSettingsImpl _value,
      $Res Function(_$SmartNotificationSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? behaviorLearning = null,
    Object? adaptiveFrequency = null,
    Object? contextAware = null,
    Object? engagementOptimization = null,
    Object? confidenceThreshold = null,
    Object? learningPeriodDays = null,
  }) {
    return _then(_$SmartNotificationSettingsImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      behaviorLearning: null == behaviorLearning
          ? _value.behaviorLearning
          : behaviorLearning // ignore: cast_nullable_to_non_nullable
              as bool,
      adaptiveFrequency: null == adaptiveFrequency
          ? _value.adaptiveFrequency
          : adaptiveFrequency // ignore: cast_nullable_to_non_nullable
              as bool,
      contextAware: null == contextAware
          ? _value.contextAware
          : contextAware // ignore: cast_nullable_to_non_nullable
              as bool,
      engagementOptimization: null == engagementOptimization
          ? _value.engagementOptimization
          : engagementOptimization // ignore: cast_nullable_to_non_nullable
              as bool,
      confidenceThreshold: null == confidenceThreshold
          ? _value.confidenceThreshold
          : confidenceThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      learningPeriodDays: null == learningPeriodDays
          ? _value.learningPeriodDays
          : learningPeriodDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SmartNotificationSettingsImpl implements _SmartNotificationSettings {
  const _$SmartNotificationSettingsImpl(
      {this.enabled = true,
      this.behaviorLearning = true,
      this.adaptiveFrequency = true,
      this.contextAware = true,
      this.engagementOptimization = true,
      this.confidenceThreshold = 0.7,
      this.learningPeriodDays = 7});

  factory _$SmartNotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmartNotificationSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final bool behaviorLearning;
// 行動パターン学習
  @override
  @JsonKey()
  final bool adaptiveFrequency;
// 適応的頻度調整
  @override
  @JsonKey()
  final bool contextAware;
// コンテキスト認識
  @override
  @JsonKey()
  final bool engagementOptimization;
// エンゲージメント最適化
  @override
  @JsonKey()
  final double confidenceThreshold;
// 予測信頼度閾値
  @override
  @JsonKey()
  final int learningPeriodDays;

  @override
  String toString() {
    return 'SmartNotificationSettings(enabled: $enabled, behaviorLearning: $behaviorLearning, adaptiveFrequency: $adaptiveFrequency, contextAware: $contextAware, engagementOptimization: $engagementOptimization, confidenceThreshold: $confidenceThreshold, learningPeriodDays: $learningPeriodDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmartNotificationSettingsImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.behaviorLearning, behaviorLearning) ||
                other.behaviorLearning == behaviorLearning) &&
            (identical(other.adaptiveFrequency, adaptiveFrequency) ||
                other.adaptiveFrequency == adaptiveFrequency) &&
            (identical(other.contextAware, contextAware) ||
                other.contextAware == contextAware) &&
            (identical(other.engagementOptimization, engagementOptimization) ||
                other.engagementOptimization == engagementOptimization) &&
            (identical(other.confidenceThreshold, confidenceThreshold) ||
                other.confidenceThreshold == confidenceThreshold) &&
            (identical(other.learningPeriodDays, learningPeriodDays) ||
                other.learningPeriodDays == learningPeriodDays));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enabled,
      behaviorLearning,
      adaptiveFrequency,
      contextAware,
      engagementOptimization,
      confidenceThreshold,
      learningPeriodDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SmartNotificationSettingsImplCopyWith<_$SmartNotificationSettingsImpl>
      get copyWith => __$$SmartNotificationSettingsImplCopyWithImpl<
          _$SmartNotificationSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmartNotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _SmartNotificationSettings implements SmartNotificationSettings {
  const factory _SmartNotificationSettings(
      {final bool enabled,
      final bool behaviorLearning,
      final bool adaptiveFrequency,
      final bool contextAware,
      final bool engagementOptimization,
      final double confidenceThreshold,
      final int learningPeriodDays}) = _$SmartNotificationSettingsImpl;

  factory _SmartNotificationSettings.fromJson(Map<String, dynamic> json) =
      _$SmartNotificationSettingsImpl.fromJson;

  @override
  bool get enabled;
  @override
  bool get behaviorLearning;
  @override // 行動パターン学習
  bool get adaptiveFrequency;
  @override // 適応的頻度調整
  bool get contextAware;
  @override // コンテキスト認識
  bool get engagementOptimization;
  @override // エンゲージメント最適化
  double get confidenceThreshold;
  @override // 予測信頼度閾値
  int get learningPeriodDays;
  @override
  @JsonKey(ignore: true)
  _$$SmartNotificationSettingsImplCopyWith<_$SmartNotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationAnalyticsSettings _$NotificationAnalyticsSettingsFromJson(
    Map<String, dynamic> json) {
  return _NotificationAnalyticsSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationAnalyticsSettings {
  bool get enabled => throw _privateConstructorUsedError;
  bool get trackOpenRate => throw _privateConstructorUsedError; // 開封率追跡
  bool get trackEngagementRate =>
      throw _privateConstructorUsedError; // エンゲージメント率追跡
  bool get trackConversionRate =>
      throw _privateConstructorUsedError; // コンバージョン率追跡
  bool get trackOptimalTiming =>
      throw _privateConstructorUsedError; // 最適タイミング分析
  int get retentionPeriodDays => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationAnalyticsSettingsCopyWith<NotificationAnalyticsSettings>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationAnalyticsSettingsCopyWith<$Res> {
  factory $NotificationAnalyticsSettingsCopyWith(
          NotificationAnalyticsSettings value,
          $Res Function(NotificationAnalyticsSettings) then) =
      _$NotificationAnalyticsSettingsCopyWithImpl<$Res,
          NotificationAnalyticsSettings>;
  @useResult
  $Res call(
      {bool enabled,
      bool trackOpenRate,
      bool trackEngagementRate,
      bool trackConversionRate,
      bool trackOptimalTiming,
      int retentionPeriodDays});
}

/// @nodoc
class _$NotificationAnalyticsSettingsCopyWithImpl<$Res,
        $Val extends NotificationAnalyticsSettings>
    implements $NotificationAnalyticsSettingsCopyWith<$Res> {
  _$NotificationAnalyticsSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? trackOpenRate = null,
    Object? trackEngagementRate = null,
    Object? trackConversionRate = null,
    Object? trackOptimalTiming = null,
    Object? retentionPeriodDays = null,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      trackOpenRate: null == trackOpenRate
          ? _value.trackOpenRate
          : trackOpenRate // ignore: cast_nullable_to_non_nullable
              as bool,
      trackEngagementRate: null == trackEngagementRate
          ? _value.trackEngagementRate
          : trackEngagementRate // ignore: cast_nullable_to_non_nullable
              as bool,
      trackConversionRate: null == trackConversionRate
          ? _value.trackConversionRate
          : trackConversionRate // ignore: cast_nullable_to_non_nullable
              as bool,
      trackOptimalTiming: null == trackOptimalTiming
          ? _value.trackOptimalTiming
          : trackOptimalTiming // ignore: cast_nullable_to_non_nullable
              as bool,
      retentionPeriodDays: null == retentionPeriodDays
          ? _value.retentionPeriodDays
          : retentionPeriodDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationAnalyticsSettingsImplCopyWith<$Res>
    implements $NotificationAnalyticsSettingsCopyWith<$Res> {
  factory _$$NotificationAnalyticsSettingsImplCopyWith(
          _$NotificationAnalyticsSettingsImpl value,
          $Res Function(_$NotificationAnalyticsSettingsImpl) then) =
      __$$NotificationAnalyticsSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      bool trackOpenRate,
      bool trackEngagementRate,
      bool trackConversionRate,
      bool trackOptimalTiming,
      int retentionPeriodDays});
}

/// @nodoc
class __$$NotificationAnalyticsSettingsImplCopyWithImpl<$Res>
    extends _$NotificationAnalyticsSettingsCopyWithImpl<$Res,
        _$NotificationAnalyticsSettingsImpl>
    implements _$$NotificationAnalyticsSettingsImplCopyWith<$Res> {
  __$$NotificationAnalyticsSettingsImplCopyWithImpl(
      _$NotificationAnalyticsSettingsImpl _value,
      $Res Function(_$NotificationAnalyticsSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? trackOpenRate = null,
    Object? trackEngagementRate = null,
    Object? trackConversionRate = null,
    Object? trackOptimalTiming = null,
    Object? retentionPeriodDays = null,
  }) {
    return _then(_$NotificationAnalyticsSettingsImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      trackOpenRate: null == trackOpenRate
          ? _value.trackOpenRate
          : trackOpenRate // ignore: cast_nullable_to_non_nullable
              as bool,
      trackEngagementRate: null == trackEngagementRate
          ? _value.trackEngagementRate
          : trackEngagementRate // ignore: cast_nullable_to_non_nullable
              as bool,
      trackConversionRate: null == trackConversionRate
          ? _value.trackConversionRate
          : trackConversionRate // ignore: cast_nullable_to_non_nullable
              as bool,
      trackOptimalTiming: null == trackOptimalTiming
          ? _value.trackOptimalTiming
          : trackOptimalTiming // ignore: cast_nullable_to_non_nullable
              as bool,
      retentionPeriodDays: null == retentionPeriodDays
          ? _value.retentionPeriodDays
          : retentionPeriodDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationAnalyticsSettingsImpl
    implements _NotificationAnalyticsSettings {
  const _$NotificationAnalyticsSettingsImpl(
      {this.enabled = true,
      this.trackOpenRate = true,
      this.trackEngagementRate = true,
      this.trackConversionRate = true,
      this.trackOptimalTiming = true,
      this.retentionPeriodDays = 30});

  factory _$NotificationAnalyticsSettingsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$NotificationAnalyticsSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final bool trackOpenRate;
// 開封率追跡
  @override
  @JsonKey()
  final bool trackEngagementRate;
// エンゲージメント率追跡
  @override
  @JsonKey()
  final bool trackConversionRate;
// コンバージョン率追跡
  @override
  @JsonKey()
  final bool trackOptimalTiming;
// 最適タイミング分析
  @override
  @JsonKey()
  final int retentionPeriodDays;

  @override
  String toString() {
    return 'NotificationAnalyticsSettings(enabled: $enabled, trackOpenRate: $trackOpenRate, trackEngagementRate: $trackEngagementRate, trackConversionRate: $trackConversionRate, trackOptimalTiming: $trackOptimalTiming, retentionPeriodDays: $retentionPeriodDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationAnalyticsSettingsImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.trackOpenRate, trackOpenRate) ||
                other.trackOpenRate == trackOpenRate) &&
            (identical(other.trackEngagementRate, trackEngagementRate) ||
                other.trackEngagementRate == trackEngagementRate) &&
            (identical(other.trackConversionRate, trackConversionRate) ||
                other.trackConversionRate == trackConversionRate) &&
            (identical(other.trackOptimalTiming, trackOptimalTiming) ||
                other.trackOptimalTiming == trackOptimalTiming) &&
            (identical(other.retentionPeriodDays, retentionPeriodDays) ||
                other.retentionPeriodDays == retentionPeriodDays));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enabled,
      trackOpenRate,
      trackEngagementRate,
      trackConversionRate,
      trackOptimalTiming,
      retentionPeriodDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationAnalyticsSettingsImplCopyWith<
          _$NotificationAnalyticsSettingsImpl>
      get copyWith => __$$NotificationAnalyticsSettingsImplCopyWithImpl<
          _$NotificationAnalyticsSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationAnalyticsSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationAnalyticsSettings
    implements NotificationAnalyticsSettings {
  const factory _NotificationAnalyticsSettings(
      {final bool enabled,
      final bool trackOpenRate,
      final bool trackEngagementRate,
      final bool trackConversionRate,
      final bool trackOptimalTiming,
      final int retentionPeriodDays}) = _$NotificationAnalyticsSettingsImpl;

  factory _NotificationAnalyticsSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationAnalyticsSettingsImpl.fromJson;

  @override
  bool get enabled;
  @override
  bool get trackOpenRate;
  @override // 開封率追跡
  bool get trackEngagementRate;
  @override // エンゲージメント率追跡
  bool get trackConversionRate;
  @override // コンバージョン率追跡
  bool get trackOptimalTiming;
  @override // 最適タイミング分析
  int get retentionPeriodDays;
  @override
  @JsonKey(ignore: true)
  _$$NotificationAnalyticsSettingsImplCopyWith<
          _$NotificationAnalyticsSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  bool get globalEnabled => throw _privateConstructorUsedError;
  Map<NotificationCategory, CategoryNotificationSettings>
      get categorySettings => throw _privateConstructorUsedError;
  TimeBasedNotificationSettings get timeSettings =>
      throw _privateConstructorUsedError;
  SmartNotificationSettings get smartSettings =>
      throw _privateConstructorUsedError;
  NotificationAnalyticsSettings get analyticsSettings =>
      throw _privateConstructorUsedError;
  String get deviceToken => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(NotificationSettings value,
          $Res Function(NotificationSettings) then) =
      _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call(
      {bool globalEnabled,
      Map<NotificationCategory, CategoryNotificationSettings> categorySettings,
      TimeBasedNotificationSettings timeSettings,
      SmartNotificationSettings smartSettings,
      NotificationAnalyticsSettings analyticsSettings,
      String deviceToken,
      DateTime? lastUpdated});

  $TimeBasedNotificationSettingsCopyWith<$Res> get timeSettings;
  $SmartNotificationSettingsCopyWith<$Res> get smartSettings;
  $NotificationAnalyticsSettingsCopyWith<$Res> get analyticsSettings;
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res,
        $Val extends NotificationSettings>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalEnabled = null,
    Object? categorySettings = null,
    Object? timeSettings = null,
    Object? smartSettings = null,
    Object? analyticsSettings = null,
    Object? deviceToken = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      globalEnabled: null == globalEnabled
          ? _value.globalEnabled
          : globalEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      categorySettings: null == categorySettings
          ? _value.categorySettings
          : categorySettings // ignore: cast_nullable_to_non_nullable
              as Map<NotificationCategory, CategoryNotificationSettings>,
      timeSettings: null == timeSettings
          ? _value.timeSettings
          : timeSettings // ignore: cast_nullable_to_non_nullable
              as TimeBasedNotificationSettings,
      smartSettings: null == smartSettings
          ? _value.smartSettings
          : smartSettings // ignore: cast_nullable_to_non_nullable
              as SmartNotificationSettings,
      analyticsSettings: null == analyticsSettings
          ? _value.analyticsSettings
          : analyticsSettings // ignore: cast_nullable_to_non_nullable
              as NotificationAnalyticsSettings,
      deviceToken: null == deviceToken
          ? _value.deviceToken
          : deviceToken // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeBasedNotificationSettingsCopyWith<$Res> get timeSettings {
    return $TimeBasedNotificationSettingsCopyWith<$Res>(_value.timeSettings,
        (value) {
      return _then(_value.copyWith(timeSettings: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SmartNotificationSettingsCopyWith<$Res> get smartSettings {
    return $SmartNotificationSettingsCopyWith<$Res>(_value.smartSettings,
        (value) {
      return _then(_value.copyWith(smartSettings: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationAnalyticsSettingsCopyWith<$Res> get analyticsSettings {
    return $NotificationAnalyticsSettingsCopyWith<$Res>(
        _value.analyticsSettings, (value) {
      return _then(_value.copyWith(analyticsSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(_$NotificationSettingsImpl value,
          $Res Function(_$NotificationSettingsImpl) then) =
      __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool globalEnabled,
      Map<NotificationCategory, CategoryNotificationSettings> categorySettings,
      TimeBasedNotificationSettings timeSettings,
      SmartNotificationSettings smartSettings,
      NotificationAnalyticsSettings analyticsSettings,
      String deviceToken,
      DateTime? lastUpdated});

  @override
  $TimeBasedNotificationSettingsCopyWith<$Res> get timeSettings;
  @override
  $SmartNotificationSettingsCopyWith<$Res> get smartSettings;
  @override
  $NotificationAnalyticsSettingsCopyWith<$Res> get analyticsSettings;
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(_$NotificationSettingsImpl _value,
      $Res Function(_$NotificationSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalEnabled = null,
    Object? categorySettings = null,
    Object? timeSettings = null,
    Object? smartSettings = null,
    Object? analyticsSettings = null,
    Object? deviceToken = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$NotificationSettingsImpl(
      globalEnabled: null == globalEnabled
          ? _value.globalEnabled
          : globalEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      categorySettings: null == categorySettings
          ? _value._categorySettings
          : categorySettings // ignore: cast_nullable_to_non_nullable
              as Map<NotificationCategory, CategoryNotificationSettings>,
      timeSettings: null == timeSettings
          ? _value.timeSettings
          : timeSettings // ignore: cast_nullable_to_non_nullable
              as TimeBasedNotificationSettings,
      smartSettings: null == smartSettings
          ? _value.smartSettings
          : smartSettings // ignore: cast_nullable_to_non_nullable
              as SmartNotificationSettings,
      analyticsSettings: null == analyticsSettings
          ? _value.analyticsSettings
          : analyticsSettings // ignore: cast_nullable_to_non_nullable
              as NotificationAnalyticsSettings,
      deviceToken: null == deviceToken
          ? _value.deviceToken
          : deviceToken // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl(
      {this.globalEnabled = true,
      final Map<NotificationCategory, CategoryNotificationSettings>
          categorySettings = const {},
      this.timeSettings = const TimeBasedNotificationSettings(),
      this.smartSettings = const SmartNotificationSettings(),
      this.analyticsSettings = const NotificationAnalyticsSettings(),
      this.deviceToken = '',
      this.lastUpdated})
      : _categorySettings = categorySettings;

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool globalEnabled;
  final Map<NotificationCategory, CategoryNotificationSettings>
      _categorySettings;
  @override
  @JsonKey()
  Map<NotificationCategory, CategoryNotificationSettings> get categorySettings {
    if (_categorySettings is EqualUnmodifiableMapView) return _categorySettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categorySettings);
  }

  @override
  @JsonKey()
  final TimeBasedNotificationSettings timeSettings;
  @override
  @JsonKey()
  final SmartNotificationSettings smartSettings;
  @override
  @JsonKey()
  final NotificationAnalyticsSettings analyticsSettings;
  @override
  @JsonKey()
  final String deviceToken;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'NotificationSettings(globalEnabled: $globalEnabled, categorySettings: $categorySettings, timeSettings: $timeSettings, smartSettings: $smartSettings, analyticsSettings: $analyticsSettings, deviceToken: $deviceToken, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.globalEnabled, globalEnabled) ||
                other.globalEnabled == globalEnabled) &&
            const DeepCollectionEquality()
                .equals(other._categorySettings, _categorySettings) &&
            (identical(other.timeSettings, timeSettings) ||
                other.timeSettings == timeSettings) &&
            (identical(other.smartSettings, smartSettings) ||
                other.smartSettings == smartSettings) &&
            (identical(other.analyticsSettings, analyticsSettings) ||
                other.analyticsSettings == analyticsSettings) &&
            (identical(other.deviceToken, deviceToken) ||
                other.deviceToken == deviceToken) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      globalEnabled,
      const DeepCollectionEquality().hash(_categorySettings),
      timeSettings,
      smartSettings,
      analyticsSettings,
      deviceToken,
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith =>
          __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings(
      {final bool globalEnabled,
      final Map<NotificationCategory, CategoryNotificationSettings>
          categorySettings,
      final TimeBasedNotificationSettings timeSettings,
      final SmartNotificationSettings smartSettings,
      final NotificationAnalyticsSettings analyticsSettings,
      final String deviceToken,
      final DateTime? lastUpdated}) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override
  bool get globalEnabled;
  @override
  Map<NotificationCategory, CategoryNotificationSettings> get categorySettings;
  @override
  TimeBasedNotificationSettings get timeSettings;
  @override
  SmartNotificationSettings get smartSettings;
  @override
  NotificationAnalyticsSettings get analyticsSettings;
  @override
  String get deviceToken;
  @override
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationContext _$NotificationContextFromJson(Map<String, dynamic> json) {
  return _NotificationContext.fromJson(json);
}

/// @nodoc
mixin _$NotificationContext {
  DateTime get timestamp => throw _privateConstructorUsedError;
  NotificationCategory get category => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get questId => throw _privateConstructorUsedError;
  String? get challengeId => throw _privateConstructorUsedError;
  String? get pairId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool get isUrgent => throw _privateConstructorUsedError;
  double get priority => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationContextCopyWith<NotificationContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationContextCopyWith<$Res> {
  factory $NotificationContextCopyWith(
          NotificationContext value, $Res Function(NotificationContext) then) =
      _$NotificationContextCopyWithImpl<$Res, NotificationContext>;
  @useResult
  $Res call(
      {DateTime timestamp,
      NotificationCategory category,
      String userId,
      String? questId,
      String? challengeId,
      String? pairId,
      Map<String, dynamic>? metadata,
      bool isUrgent,
      double priority});
}

/// @nodoc
class _$NotificationContextCopyWithImpl<$Res, $Val extends NotificationContext>
    implements $NotificationContextCopyWith<$Res> {
  _$NotificationContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? category = null,
    Object? userId = null,
    Object? questId = freezed,
    Object? challengeId = freezed,
    Object? pairId = freezed,
    Object? metadata = freezed,
    Object? isUrgent = null,
    Object? priority = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      questId: freezed == questId
          ? _value.questId
          : questId // ignore: cast_nullable_to_non_nullable
              as String?,
      challengeId: freezed == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String?,
      pairId: freezed == pairId
          ? _value.pairId
          : pairId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationContextImplCopyWith<$Res>
    implements $NotificationContextCopyWith<$Res> {
  factory _$$NotificationContextImplCopyWith(_$NotificationContextImpl value,
          $Res Function(_$NotificationContextImpl) then) =
      __$$NotificationContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      NotificationCategory category,
      String userId,
      String? questId,
      String? challengeId,
      String? pairId,
      Map<String, dynamic>? metadata,
      bool isUrgent,
      double priority});
}

/// @nodoc
class __$$NotificationContextImplCopyWithImpl<$Res>
    extends _$NotificationContextCopyWithImpl<$Res, _$NotificationContextImpl>
    implements _$$NotificationContextImplCopyWith<$Res> {
  __$$NotificationContextImplCopyWithImpl(_$NotificationContextImpl _value,
      $Res Function(_$NotificationContextImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? category = null,
    Object? userId = null,
    Object? questId = freezed,
    Object? challengeId = freezed,
    Object? pairId = freezed,
    Object? metadata = freezed,
    Object? isUrgent = null,
    Object? priority = null,
  }) {
    return _then(_$NotificationContextImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as NotificationCategory,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      questId: freezed == questId
          ? _value.questId
          : questId // ignore: cast_nullable_to_non_nullable
              as String?,
      challengeId: freezed == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String?,
      pairId: freezed == pairId
          ? _value.pairId
          : pairId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationContextImpl implements _NotificationContext {
  const _$NotificationContextImpl(
      {required this.timestamp,
      required this.category,
      required this.userId,
      this.questId,
      this.challengeId,
      this.pairId,
      final Map<String, dynamic>? metadata,
      this.isUrgent = false,
      this.priority = 1.0})
      : _metadata = metadata;

  factory _$NotificationContextImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationContextImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final NotificationCategory category;
  @override
  final String userId;
  @override
  final String? questId;
  @override
  final String? challengeId;
  @override
  final String? pairId;
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
  @JsonKey()
  final bool isUrgent;
  @override
  @JsonKey()
  final double priority;

  @override
  String toString() {
    return 'NotificationContext(timestamp: $timestamp, category: $category, userId: $userId, questId: $questId, challengeId: $challengeId, pairId: $pairId, metadata: $metadata, isUrgent: $isUrgent, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationContextImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.questId, questId) || other.questId == questId) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.pairId, pairId) || other.pairId == pairId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isUrgent, isUrgent) ||
                other.isUrgent == isUrgent) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      timestamp,
      category,
      userId,
      questId,
      challengeId,
      pairId,
      const DeepCollectionEquality().hash(_metadata),
      isUrgent,
      priority);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationContextImplCopyWith<_$NotificationContextImpl> get copyWith =>
      __$$NotificationContextImplCopyWithImpl<_$NotificationContextImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationContextImplToJson(
      this,
    );
  }
}

abstract class _NotificationContext implements NotificationContext {
  const factory _NotificationContext(
      {required final DateTime timestamp,
      required final NotificationCategory category,
      required final String userId,
      final String? questId,
      final String? challengeId,
      final String? pairId,
      final Map<String, dynamic>? metadata,
      final bool isUrgent,
      final double priority}) = _$NotificationContextImpl;

  factory _NotificationContext.fromJson(Map<String, dynamic> json) =
      _$NotificationContextImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  NotificationCategory get category;
  @override
  String get userId;
  @override
  String? get questId;
  @override
  String? get challengeId;
  @override
  String? get pairId;
  @override
  Map<String, dynamic>? get metadata;
  @override
  bool get isUrgent;
  @override
  double get priority;
  @override
  @JsonKey(ignore: true)
  _$$NotificationContextImplCopyWith<_$NotificationContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
