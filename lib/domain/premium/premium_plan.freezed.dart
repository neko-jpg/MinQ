// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PremiumPlan _$PremiumPlanFromJson(Map<String, dynamic> json) {
  return _PremiumPlan.fromJson(json);
}

/// @nodoc
mixin _$PremiumPlan {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get monthlyPrice => throw _privateConstructorUsedError;
  double get yearlyPrice => throw _privateConstructorUsedError;
  List<String> get features => throw _privateConstructorUsedError;
  PremiumTier get tier => throw _privateConstructorUsedError;
  bool get isPopular => throw _privateConstructorUsedError;
  bool get isStudentPlan => throw _privateConstructorUsedError;
  bool get isFamilyPlan => throw _privateConstructorUsedError;
  int get maxUsers => throw _privateConstructorUsedError;
  String? get discountCode => throw _privateConstructorUsedError;
  double? get discountPercentage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PremiumPlanCopyWith<PremiumPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumPlanCopyWith<$Res> {
  factory $PremiumPlanCopyWith(
          PremiumPlan value, $Res Function(PremiumPlan) then) =
      _$PremiumPlanCopyWithImpl<$Res, PremiumPlan>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double monthlyPrice,
      double yearlyPrice,
      List<String> features,
      PremiumTier tier,
      bool isPopular,
      bool isStudentPlan,
      bool isFamilyPlan,
      int maxUsers,
      String? discountCode,
      double? discountPercentage});
}

/// @nodoc
class _$PremiumPlanCopyWithImpl<$Res, $Val extends PremiumPlan>
    implements $PremiumPlanCopyWith<$Res> {
  _$PremiumPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? monthlyPrice = null,
    Object? yearlyPrice = null,
    Object? features = null,
    Object? tier = null,
    Object? isPopular = null,
    Object? isStudentPlan = null,
    Object? isFamilyPlan = null,
    Object? maxUsers = null,
    Object? discountCode = freezed,
    Object? discountPercentage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyPrice: null == monthlyPrice
          ? _value.monthlyPrice
          : monthlyPrice // ignore: cast_nullable_to_non_nullable
              as double,
      yearlyPrice: null == yearlyPrice
          ? _value.yearlyPrice
          : yearlyPrice // ignore: cast_nullable_to_non_nullable
              as double,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as PremiumTier,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isStudentPlan: null == isStudentPlan
          ? _value.isStudentPlan
          : isStudentPlan // ignore: cast_nullable_to_non_nullable
              as bool,
      isFamilyPlan: null == isFamilyPlan
          ? _value.isFamilyPlan
          : isFamilyPlan // ignore: cast_nullable_to_non_nullable
              as bool,
      maxUsers: null == maxUsers
          ? _value.maxUsers
          : maxUsers // ignore: cast_nullable_to_non_nullable
              as int,
      discountCode: freezed == discountCode
          ? _value.discountCode
          : discountCode // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercentage: freezed == discountPercentage
          ? _value.discountPercentage
          : discountPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumPlanImplCopyWith<$Res>
    implements $PremiumPlanCopyWith<$Res> {
  factory _$$PremiumPlanImplCopyWith(
          _$PremiumPlanImpl value, $Res Function(_$PremiumPlanImpl) then) =
      __$$PremiumPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      double monthlyPrice,
      double yearlyPrice,
      List<String> features,
      PremiumTier tier,
      bool isPopular,
      bool isStudentPlan,
      bool isFamilyPlan,
      int maxUsers,
      String? discountCode,
      double? discountPercentage});
}

/// @nodoc
class __$$PremiumPlanImplCopyWithImpl<$Res>
    extends _$PremiumPlanCopyWithImpl<$Res, _$PremiumPlanImpl>
    implements _$$PremiumPlanImplCopyWith<$Res> {
  __$$PremiumPlanImplCopyWithImpl(
      _$PremiumPlanImpl _value, $Res Function(_$PremiumPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? monthlyPrice = null,
    Object? yearlyPrice = null,
    Object? features = null,
    Object? tier = null,
    Object? isPopular = null,
    Object? isStudentPlan = null,
    Object? isFamilyPlan = null,
    Object? maxUsers = null,
    Object? discountCode = freezed,
    Object? discountPercentage = freezed,
  }) {
    return _then(_$PremiumPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyPrice: null == monthlyPrice
          ? _value.monthlyPrice
          : monthlyPrice // ignore: cast_nullable_to_non_nullable
              as double,
      yearlyPrice: null == yearlyPrice
          ? _value.yearlyPrice
          : yearlyPrice // ignore: cast_nullable_to_non_nullable
              as double,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as PremiumTier,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isStudentPlan: null == isStudentPlan
          ? _value.isStudentPlan
          : isStudentPlan // ignore: cast_nullable_to_non_nullable
              as bool,
      isFamilyPlan: null == isFamilyPlan
          ? _value.isFamilyPlan
          : isFamilyPlan // ignore: cast_nullable_to_non_nullable
              as bool,
      maxUsers: null == maxUsers
          ? _value.maxUsers
          : maxUsers // ignore: cast_nullable_to_non_nullable
              as int,
      discountCode: freezed == discountCode
          ? _value.discountCode
          : discountCode // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercentage: freezed == discountPercentage
          ? _value.discountPercentage
          : discountPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumPlanImpl implements _PremiumPlan {
  const _$PremiumPlanImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.monthlyPrice,
      required this.yearlyPrice,
      required final List<String> features,
      required this.tier,
      this.isPopular = false,
      this.isStudentPlan = false,
      this.isFamilyPlan = false,
      this.maxUsers = 1,
      this.discountCode,
      this.discountPercentage})
      : _features = features;

  factory _$PremiumPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double monthlyPrice;
  @override
  final double yearlyPrice;
  final List<String> _features;
  @override
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  final PremiumTier tier;
  @override
  @JsonKey()
  final bool isPopular;
  @override
  @JsonKey()
  final bool isStudentPlan;
  @override
  @JsonKey()
  final bool isFamilyPlan;
  @override
  @JsonKey()
  final int maxUsers;
  @override
  final String? discountCode;
  @override
  final double? discountPercentage;

  @override
  String toString() {
    return 'PremiumPlan(id: $id, name: $name, description: $description, monthlyPrice: $monthlyPrice, yearlyPrice: $yearlyPrice, features: $features, tier: $tier, isPopular: $isPopular, isStudentPlan: $isStudentPlan, isFamilyPlan: $isFamilyPlan, maxUsers: $maxUsers, discountCode: $discountCode, discountPercentage: $discountPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.monthlyPrice, monthlyPrice) ||
                other.monthlyPrice == monthlyPrice) &&
            (identical(other.yearlyPrice, yearlyPrice) ||
                other.yearlyPrice == yearlyPrice) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.isStudentPlan, isStudentPlan) ||
                other.isStudentPlan == isStudentPlan) &&
            (identical(other.isFamilyPlan, isFamilyPlan) ||
                other.isFamilyPlan == isFamilyPlan) &&
            (identical(other.maxUsers, maxUsers) ||
                other.maxUsers == maxUsers) &&
            (identical(other.discountCode, discountCode) ||
                other.discountCode == discountCode) &&
            (identical(other.discountPercentage, discountPercentage) ||
                other.discountPercentage == discountPercentage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      monthlyPrice,
      yearlyPrice,
      const DeepCollectionEquality().hash(_features),
      tier,
      isPopular,
      isStudentPlan,
      isFamilyPlan,
      maxUsers,
      discountCode,
      discountPercentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumPlanImplCopyWith<_$PremiumPlanImpl> get copyWith =>
      __$$PremiumPlanImplCopyWithImpl<_$PremiumPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumPlanImplToJson(
      this,
    );
  }
}

abstract class _PremiumPlan implements PremiumPlan {
  const factory _PremiumPlan(
      {required final String id,
      required final String name,
      required final String description,
      required final double monthlyPrice,
      required final double yearlyPrice,
      required final List<String> features,
      required final PremiumTier tier,
      final bool isPopular,
      final bool isStudentPlan,
      final bool isFamilyPlan,
      final int maxUsers,
      final String? discountCode,
      final double? discountPercentage}) = _$PremiumPlanImpl;

  factory _PremiumPlan.fromJson(Map<String, dynamic> json) =
      _$PremiumPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get monthlyPrice;
  @override
  double get yearlyPrice;
  @override
  List<String> get features;
  @override
  PremiumTier get tier;
  @override
  bool get isPopular;
  @override
  bool get isStudentPlan;
  @override
  bool get isFamilyPlan;
  @override
  int get maxUsers;
  @override
  String? get discountCode;
  @override
  double? get discountPercentage;
  @override
  @JsonKey(ignore: true)
  _$$PremiumPlanImplCopyWith<_$PremiumPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PremiumSubscription _$PremiumSubscriptionFromJson(Map<String, dynamic> json) {
  return _PremiumSubscription.fromJson(json);
}

/// @nodoc
mixin _$PremiumSubscription {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  PremiumTier get tier => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  BillingCycle get billingCycle => throw _privateConstructorUsedError;
  bool get autoRenew => throw _privateConstructorUsedError;
  String? get paymentMethodId => throw _privateConstructorUsedError;
  DateTime? get lastPaymentDate => throw _privateConstructorUsedError;
  DateTime? get nextPaymentDate => throw _privateConstructorUsedError;
  double? get lastPaymentAmount => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  DateTime? get cancellationDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PremiumSubscriptionCopyWith<PremiumSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumSubscriptionCopyWith<$Res> {
  factory $PremiumSubscriptionCopyWith(
          PremiumSubscription value, $Res Function(PremiumSubscription) then) =
      _$PremiumSubscriptionCopyWithImpl<$Res, PremiumSubscription>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String planId,
      PremiumTier tier,
      DateTime startDate,
      DateTime endDate,
      SubscriptionStatus status,
      BillingCycle billingCycle,
      bool autoRenew,
      String? paymentMethodId,
      DateTime? lastPaymentDate,
      DateTime? nextPaymentDate,
      double? lastPaymentAmount,
      String? cancellationReason,
      DateTime? cancellationDate});
}

/// @nodoc
class _$PremiumSubscriptionCopyWithImpl<$Res, $Val extends PremiumSubscription>
    implements $PremiumSubscriptionCopyWith<$Res> {
  _$PremiumSubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? planId = null,
    Object? tier = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
    Object? billingCycle = null,
    Object? autoRenew = null,
    Object? paymentMethodId = freezed,
    Object? lastPaymentDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? lastPaymentAmount = freezed,
    Object? cancellationReason = freezed,
    Object? cancellationDate = freezed,
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
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as PremiumTier,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      billingCycle: null == billingCycle
          ? _value.billingCycle
          : billingCycle // ignore: cast_nullable_to_non_nullable
              as BillingCycle,
      autoRenew: null == autoRenew
          ? _value.autoRenew
          : autoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
      paymentMethodId: freezed == paymentMethodId
          ? _value.paymentMethodId
          : paymentMethodId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPaymentDate: freezed == lastPaymentDate
          ? _value.lastPaymentDate
          : lastPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPaymentAmount: freezed == lastPaymentAmount
          ? _value.lastPaymentAmount
          : lastPaymentAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationDate: freezed == cancellationDate
          ? _value.cancellationDate
          : cancellationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumSubscriptionImplCopyWith<$Res>
    implements $PremiumSubscriptionCopyWith<$Res> {
  factory _$$PremiumSubscriptionImplCopyWith(_$PremiumSubscriptionImpl value,
          $Res Function(_$PremiumSubscriptionImpl) then) =
      __$$PremiumSubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String planId,
      PremiumTier tier,
      DateTime startDate,
      DateTime endDate,
      SubscriptionStatus status,
      BillingCycle billingCycle,
      bool autoRenew,
      String? paymentMethodId,
      DateTime? lastPaymentDate,
      DateTime? nextPaymentDate,
      double? lastPaymentAmount,
      String? cancellationReason,
      DateTime? cancellationDate});
}

/// @nodoc
class __$$PremiumSubscriptionImplCopyWithImpl<$Res>
    extends _$PremiumSubscriptionCopyWithImpl<$Res, _$PremiumSubscriptionImpl>
    implements _$$PremiumSubscriptionImplCopyWith<$Res> {
  __$$PremiumSubscriptionImplCopyWithImpl(_$PremiumSubscriptionImpl _value,
      $Res Function(_$PremiumSubscriptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? planId = null,
    Object? tier = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
    Object? billingCycle = null,
    Object? autoRenew = null,
    Object? paymentMethodId = freezed,
    Object? lastPaymentDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? lastPaymentAmount = freezed,
    Object? cancellationReason = freezed,
    Object? cancellationDate = freezed,
  }) {
    return _then(_$PremiumSubscriptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as PremiumTier,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      billingCycle: null == billingCycle
          ? _value.billingCycle
          : billingCycle // ignore: cast_nullable_to_non_nullable
              as BillingCycle,
      autoRenew: null == autoRenew
          ? _value.autoRenew
          : autoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
      paymentMethodId: freezed == paymentMethodId
          ? _value.paymentMethodId
          : paymentMethodId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPaymentDate: freezed == lastPaymentDate
          ? _value.lastPaymentDate
          : lastPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPaymentAmount: freezed == lastPaymentAmount
          ? _value.lastPaymentAmount
          : lastPaymentAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationDate: freezed == cancellationDate
          ? _value.cancellationDate
          : cancellationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumSubscriptionImpl implements _PremiumSubscription {
  const _$PremiumSubscriptionImpl(
      {required this.id,
      required this.userId,
      required this.planId,
      required this.tier,
      required this.startDate,
      required this.endDate,
      required this.status,
      required this.billingCycle,
      this.autoRenew = false,
      this.paymentMethodId,
      this.lastPaymentDate,
      this.nextPaymentDate,
      this.lastPaymentAmount,
      this.cancellationReason,
      this.cancellationDate});

  factory _$PremiumSubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumSubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String planId;
  @override
  final PremiumTier tier;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final SubscriptionStatus status;
  @override
  final BillingCycle billingCycle;
  @override
  @JsonKey()
  final bool autoRenew;
  @override
  final String? paymentMethodId;
  @override
  final DateTime? lastPaymentDate;
  @override
  final DateTime? nextPaymentDate;
  @override
  final double? lastPaymentAmount;
  @override
  final String? cancellationReason;
  @override
  final DateTime? cancellationDate;

  @override
  String toString() {
    return 'PremiumSubscription(id: $id, userId: $userId, planId: $planId, tier: $tier, startDate: $startDate, endDate: $endDate, status: $status, billingCycle: $billingCycle, autoRenew: $autoRenew, paymentMethodId: $paymentMethodId, lastPaymentDate: $lastPaymentDate, nextPaymentDate: $nextPaymentDate, lastPaymentAmount: $lastPaymentAmount, cancellationReason: $cancellationReason, cancellationDate: $cancellationDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumSubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.billingCycle, billingCycle) ||
                other.billingCycle == billingCycle) &&
            (identical(other.autoRenew, autoRenew) ||
                other.autoRenew == autoRenew) &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId) &&
            (identical(other.lastPaymentDate, lastPaymentDate) ||
                other.lastPaymentDate == lastPaymentDate) &&
            (identical(other.nextPaymentDate, nextPaymentDate) ||
                other.nextPaymentDate == nextPaymentDate) &&
            (identical(other.lastPaymentAmount, lastPaymentAmount) ||
                other.lastPaymentAmount == lastPaymentAmount) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.cancellationDate, cancellationDate) ||
                other.cancellationDate == cancellationDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      planId,
      tier,
      startDate,
      endDate,
      status,
      billingCycle,
      autoRenew,
      paymentMethodId,
      lastPaymentDate,
      nextPaymentDate,
      lastPaymentAmount,
      cancellationReason,
      cancellationDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumSubscriptionImplCopyWith<_$PremiumSubscriptionImpl> get copyWith =>
      __$$PremiumSubscriptionImplCopyWithImpl<_$PremiumSubscriptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumSubscriptionImplToJson(
      this,
    );
  }
}

abstract class _PremiumSubscription implements PremiumSubscription {
  const factory _PremiumSubscription(
      {required final String id,
      required final String userId,
      required final String planId,
      required final PremiumTier tier,
      required final DateTime startDate,
      required final DateTime endDate,
      required final SubscriptionStatus status,
      required final BillingCycle billingCycle,
      final bool autoRenew,
      final String? paymentMethodId,
      final DateTime? lastPaymentDate,
      final DateTime? nextPaymentDate,
      final double? lastPaymentAmount,
      final String? cancellationReason,
      final DateTime? cancellationDate}) = _$PremiumSubscriptionImpl;

  factory _PremiumSubscription.fromJson(Map<String, dynamic> json) =
      _$PremiumSubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get planId;
  @override
  PremiumTier get tier;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  SubscriptionStatus get status;
  @override
  BillingCycle get billingCycle;
  @override
  bool get autoRenew;
  @override
  String? get paymentMethodId;
  @override
  DateTime? get lastPaymentDate;
  @override
  DateTime? get nextPaymentDate;
  @override
  double? get lastPaymentAmount;
  @override
  String? get cancellationReason;
  @override
  DateTime? get cancellationDate;
  @override
  @JsonKey(ignore: true)
  _$$PremiumSubscriptionImplCopyWith<_$PremiumSubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PremiumFeature _$PremiumFeatureFromJson(Map<String, dynamic> json) {
  return _PremiumFeature.fromJson(json);
}

/// @nodoc
mixin _$PremiumFeature {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  PremiumTier get requiredTier => throw _privateConstructorUsedError;
  FeatureType get type => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  Map<String, dynamic>? get configuration => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PremiumFeatureCopyWith<PremiumFeature> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumFeatureCopyWith<$Res> {
  factory $PremiumFeatureCopyWith(
          PremiumFeature value, $Res Function(PremiumFeature) then) =
      _$PremiumFeatureCopyWithImpl<$Res, PremiumFeature>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      PremiumTier requiredTier,
      FeatureType type,
      bool isEnabled,
      Map<String, dynamic>? configuration});
}

/// @nodoc
class _$PremiumFeatureCopyWithImpl<$Res, $Val extends PremiumFeature>
    implements $PremiumFeatureCopyWith<$Res> {
  _$PremiumFeatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? requiredTier = null,
    Object? type = null,
    Object? isEnabled = null,
    Object? configuration = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      requiredTier: null == requiredTier
          ? _value.requiredTier
          : requiredTier // ignore: cast_nullable_to_non_nullable
              as PremiumTier,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeatureType,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      configuration: freezed == configuration
          ? _value.configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumFeatureImplCopyWith<$Res>
    implements $PremiumFeatureCopyWith<$Res> {
  factory _$$PremiumFeatureImplCopyWith(_$PremiumFeatureImpl value,
          $Res Function(_$PremiumFeatureImpl) then) =
      __$$PremiumFeatureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      PremiumTier requiredTier,
      FeatureType type,
      bool isEnabled,
      Map<String, dynamic>? configuration});
}

/// @nodoc
class __$$PremiumFeatureImplCopyWithImpl<$Res>
    extends _$PremiumFeatureCopyWithImpl<$Res, _$PremiumFeatureImpl>
    implements _$$PremiumFeatureImplCopyWith<$Res> {
  __$$PremiumFeatureImplCopyWithImpl(
      _$PremiumFeatureImpl _value, $Res Function(_$PremiumFeatureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? requiredTier = null,
    Object? type = null,
    Object? isEnabled = null,
    Object? configuration = freezed,
  }) {
    return _then(_$PremiumFeatureImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      requiredTier: null == requiredTier
          ? _value.requiredTier
          : requiredTier // ignore: cast_nullable_to_non_nullable
              as PremiumTier,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeatureType,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      configuration: freezed == configuration
          ? _value._configuration
          : configuration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumFeatureImpl implements _PremiumFeature {
  const _$PremiumFeatureImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.requiredTier,
      required this.type,
      this.isEnabled = true,
      final Map<String, dynamic>? configuration})
      : _configuration = configuration;

  factory _$PremiumFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumFeatureImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final PremiumTier requiredTier;
  @override
  final FeatureType type;
  @override
  @JsonKey()
  final bool isEnabled;
  final Map<String, dynamic>? _configuration;
  @override
  Map<String, dynamic>? get configuration {
    final value = _configuration;
    if (value == null) return null;
    if (_configuration is EqualUnmodifiableMapView) return _configuration;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'PremiumFeature(id: $id, name: $name, description: $description, requiredTier: $requiredTier, type: $type, isEnabled: $isEnabled, configuration: $configuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumFeatureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.requiredTier, requiredTier) ||
                other.requiredTier == requiredTier) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            const DeepCollectionEquality()
                .equals(other._configuration, _configuration));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      requiredTier,
      type,
      isEnabled,
      const DeepCollectionEquality().hash(_configuration));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumFeatureImplCopyWith<_$PremiumFeatureImpl> get copyWith =>
      __$$PremiumFeatureImplCopyWithImpl<_$PremiumFeatureImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumFeatureImplToJson(
      this,
    );
  }
}

abstract class _PremiumFeature implements PremiumFeature {
  const factory _PremiumFeature(
      {required final String id,
      required final String name,
      required final String description,
      required final PremiumTier requiredTier,
      required final FeatureType type,
      final bool isEnabled,
      final Map<String, dynamic>? configuration}) = _$PremiumFeatureImpl;

  factory _PremiumFeature.fromJson(Map<String, dynamic> json) =
      _$PremiumFeatureImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  PremiumTier get requiredTier;
  @override
  FeatureType get type;
  @override
  bool get isEnabled;
  @override
  Map<String, dynamic>? get configuration;
  @override
  @JsonKey(ignore: true)
  _$$PremiumFeatureImplCopyWith<_$PremiumFeatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FamilyMember _$FamilyMemberFromJson(Map<String, dynamic> json) {
  return _FamilyMember.fromJson(json);
}

/// @nodoc
mixin _$FamilyMember {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  FamilyRole get role => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FamilyMemberCopyWith<FamilyMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyMemberCopyWith<$Res> {
  factory $FamilyMemberCopyWith(
          FamilyMember value, $Res Function(FamilyMember) then) =
      _$FamilyMemberCopyWithImpl<$Res, FamilyMember>;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      FamilyRole role,
      DateTime joinedAt,
      bool isActive,
      String? avatarUrl,
      DateTime? lastActiveAt});
}

/// @nodoc
class _$FamilyMemberCopyWithImpl<$Res, $Val extends FamilyMember>
    implements $FamilyMemberCopyWith<$Res> {
  _$FamilyMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? joinedAt = null,
    Object? isActive = null,
    Object? avatarUrl = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as FamilyRole,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FamilyMemberImplCopyWith<$Res>
    implements $FamilyMemberCopyWith<$Res> {
  factory _$$FamilyMemberImplCopyWith(
          _$FamilyMemberImpl value, $Res Function(_$FamilyMemberImpl) then) =
      __$$FamilyMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      FamilyRole role,
      DateTime joinedAt,
      bool isActive,
      String? avatarUrl,
      DateTime? lastActiveAt});
}

/// @nodoc
class __$$FamilyMemberImplCopyWithImpl<$Res>
    extends _$FamilyMemberCopyWithImpl<$Res, _$FamilyMemberImpl>
    implements _$$FamilyMemberImplCopyWith<$Res> {
  __$$FamilyMemberImplCopyWithImpl(
      _$FamilyMemberImpl _value, $Res Function(_$FamilyMemberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? joinedAt = null,
    Object? isActive = null,
    Object? avatarUrl = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_$FamilyMemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as FamilyRole,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilyMemberImpl implements _FamilyMember {
  const _$FamilyMemberImpl(
      {required this.id,
      required this.name,
      required this.email,
      required this.role,
      required this.joinedAt,
      required this.isActive,
      this.avatarUrl,
      this.lastActiveAt});

  factory _$FamilyMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyMemberImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final FamilyRole role;
  @override
  final DateTime joinedAt;
  @override
  final bool isActive;
  @override
  final String? avatarUrl;
  @override
  final DateTime? lastActiveAt;

  @override
  String toString() {
    return 'FamilyMember(id: $id, name: $name, email: $email, role: $role, joinedAt: $joinedAt, isActive: $isActive, avatarUrl: $avatarUrl, lastActiveAt: $lastActiveAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, role, joinedAt,
      isActive, avatarUrl, lastActiveAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyMemberImplCopyWith<_$FamilyMemberImpl> get copyWith =>
      __$$FamilyMemberImplCopyWithImpl<_$FamilyMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyMemberImplToJson(
      this,
    );
  }
}

abstract class _FamilyMember implements FamilyMember {
  const factory _FamilyMember(
      {required final String id,
      required final String name,
      required final String email,
      required final FamilyRole role,
      required final DateTime joinedAt,
      required final bool isActive,
      final String? avatarUrl,
      final DateTime? lastActiveAt}) = _$FamilyMemberImpl;

  factory _FamilyMember.fromJson(Map<String, dynamic> json) =
      _$FamilyMemberImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  FamilyRole get role;
  @override
  DateTime get joinedAt;
  @override
  bool get isActive;
  @override
  String? get avatarUrl;
  @override
  DateTime? get lastActiveAt;
  @override
  @JsonKey(ignore: true)
  _$$FamilyMemberImplCopyWith<_$FamilyMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PremiumUsageStats _$PremiumUsageStatsFromJson(Map<String, dynamic> json) {
  return _PremiumUsageStats.fromJson(json);
}

/// @nodoc
mixin _$PremiumUsageStats {
  int get questsCreated => throw _privateConstructorUsedError;
  int get questLimit => throw _privateConstructorUsedError;
  int get aiCoachInteractions => throw _privateConstructorUsedError;
  int get dataExports => throw _privateConstructorUsedError;
  int get backupsCreated => throw _privateConstructorUsedError;
  int get themesUsed => throw _privateConstructorUsedError;
  int get familyMembersActive => throw _privateConstructorUsedError;
  double get storageUsed => throw _privateConstructorUsedError;
  double get storageLimit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PremiumUsageStatsCopyWith<PremiumUsageStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumUsageStatsCopyWith<$Res> {
  factory $PremiumUsageStatsCopyWith(
          PremiumUsageStats value, $Res Function(PremiumUsageStats) then) =
      _$PremiumUsageStatsCopyWithImpl<$Res, PremiumUsageStats>;
  @useResult
  $Res call(
      {int questsCreated,
      int questLimit,
      int aiCoachInteractions,
      int dataExports,
      int backupsCreated,
      int themesUsed,
      int familyMembersActive,
      double storageUsed,
      double storageLimit});
}

/// @nodoc
class _$PremiumUsageStatsCopyWithImpl<$Res, $Val extends PremiumUsageStats>
    implements $PremiumUsageStatsCopyWith<$Res> {
  _$PremiumUsageStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questsCreated = null,
    Object? questLimit = null,
    Object? aiCoachInteractions = null,
    Object? dataExports = null,
    Object? backupsCreated = null,
    Object? themesUsed = null,
    Object? familyMembersActive = null,
    Object? storageUsed = null,
    Object? storageLimit = null,
  }) {
    return _then(_value.copyWith(
      questsCreated: null == questsCreated
          ? _value.questsCreated
          : questsCreated // ignore: cast_nullable_to_non_nullable
              as int,
      questLimit: null == questLimit
          ? _value.questLimit
          : questLimit // ignore: cast_nullable_to_non_nullable
              as int,
      aiCoachInteractions: null == aiCoachInteractions
          ? _value.aiCoachInteractions
          : aiCoachInteractions // ignore: cast_nullable_to_non_nullable
              as int,
      dataExports: null == dataExports
          ? _value.dataExports
          : dataExports // ignore: cast_nullable_to_non_nullable
              as int,
      backupsCreated: null == backupsCreated
          ? _value.backupsCreated
          : backupsCreated // ignore: cast_nullable_to_non_nullable
              as int,
      themesUsed: null == themesUsed
          ? _value.themesUsed
          : themesUsed // ignore: cast_nullable_to_non_nullable
              as int,
      familyMembersActive: null == familyMembersActive
          ? _value.familyMembersActive
          : familyMembersActive // ignore: cast_nullable_to_non_nullable
              as int,
      storageUsed: null == storageUsed
          ? _value.storageUsed
          : storageUsed // ignore: cast_nullable_to_non_nullable
              as double,
      storageLimit: null == storageLimit
          ? _value.storageLimit
          : storageLimit // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumUsageStatsImplCopyWith<$Res>
    implements $PremiumUsageStatsCopyWith<$Res> {
  factory _$$PremiumUsageStatsImplCopyWith(_$PremiumUsageStatsImpl value,
          $Res Function(_$PremiumUsageStatsImpl) then) =
      __$$PremiumUsageStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int questsCreated,
      int questLimit,
      int aiCoachInteractions,
      int dataExports,
      int backupsCreated,
      int themesUsed,
      int familyMembersActive,
      double storageUsed,
      double storageLimit});
}

/// @nodoc
class __$$PremiumUsageStatsImplCopyWithImpl<$Res>
    extends _$PremiumUsageStatsCopyWithImpl<$Res, _$PremiumUsageStatsImpl>
    implements _$$PremiumUsageStatsImplCopyWith<$Res> {
  __$$PremiumUsageStatsImplCopyWithImpl(_$PremiumUsageStatsImpl _value,
      $Res Function(_$PremiumUsageStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questsCreated = null,
    Object? questLimit = null,
    Object? aiCoachInteractions = null,
    Object? dataExports = null,
    Object? backupsCreated = null,
    Object? themesUsed = null,
    Object? familyMembersActive = null,
    Object? storageUsed = null,
    Object? storageLimit = null,
  }) {
    return _then(_$PremiumUsageStatsImpl(
      questsCreated: null == questsCreated
          ? _value.questsCreated
          : questsCreated // ignore: cast_nullable_to_non_nullable
              as int,
      questLimit: null == questLimit
          ? _value.questLimit
          : questLimit // ignore: cast_nullable_to_non_nullable
              as int,
      aiCoachInteractions: null == aiCoachInteractions
          ? _value.aiCoachInteractions
          : aiCoachInteractions // ignore: cast_nullable_to_non_nullable
              as int,
      dataExports: null == dataExports
          ? _value.dataExports
          : dataExports // ignore: cast_nullable_to_non_nullable
              as int,
      backupsCreated: null == backupsCreated
          ? _value.backupsCreated
          : backupsCreated // ignore: cast_nullable_to_non_nullable
              as int,
      themesUsed: null == themesUsed
          ? _value.themesUsed
          : themesUsed // ignore: cast_nullable_to_non_nullable
              as int,
      familyMembersActive: null == familyMembersActive
          ? _value.familyMembersActive
          : familyMembersActive // ignore: cast_nullable_to_non_nullable
              as int,
      storageUsed: null == storageUsed
          ? _value.storageUsed
          : storageUsed // ignore: cast_nullable_to_non_nullable
              as double,
      storageLimit: null == storageLimit
          ? _value.storageLimit
          : storageLimit // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumUsageStatsImpl implements _PremiumUsageStats {
  const _$PremiumUsageStatsImpl(
      {required this.questsCreated,
      required this.questLimit,
      required this.aiCoachInteractions,
      required this.dataExports,
      required this.backupsCreated,
      required this.themesUsed,
      required this.familyMembersActive,
      required this.storageUsed,
      required this.storageLimit});

  factory _$PremiumUsageStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumUsageStatsImplFromJson(json);

  @override
  final int questsCreated;
  @override
  final int questLimit;
  @override
  final int aiCoachInteractions;
  @override
  final int dataExports;
  @override
  final int backupsCreated;
  @override
  final int themesUsed;
  @override
  final int familyMembersActive;
  @override
  final double storageUsed;
  @override
  final double storageLimit;

  @override
  String toString() {
    return 'PremiumUsageStats(questsCreated: $questsCreated, questLimit: $questLimit, aiCoachInteractions: $aiCoachInteractions, dataExports: $dataExports, backupsCreated: $backupsCreated, themesUsed: $themesUsed, familyMembersActive: $familyMembersActive, storageUsed: $storageUsed, storageLimit: $storageLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumUsageStatsImpl &&
            (identical(other.questsCreated, questsCreated) ||
                other.questsCreated == questsCreated) &&
            (identical(other.questLimit, questLimit) ||
                other.questLimit == questLimit) &&
            (identical(other.aiCoachInteractions, aiCoachInteractions) ||
                other.aiCoachInteractions == aiCoachInteractions) &&
            (identical(other.dataExports, dataExports) ||
                other.dataExports == dataExports) &&
            (identical(other.backupsCreated, backupsCreated) ||
                other.backupsCreated == backupsCreated) &&
            (identical(other.themesUsed, themesUsed) ||
                other.themesUsed == themesUsed) &&
            (identical(other.familyMembersActive, familyMembersActive) ||
                other.familyMembersActive == familyMembersActive) &&
            (identical(other.storageUsed, storageUsed) ||
                other.storageUsed == storageUsed) &&
            (identical(other.storageLimit, storageLimit) ||
                other.storageLimit == storageLimit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questsCreated,
      questLimit,
      aiCoachInteractions,
      dataExports,
      backupsCreated,
      themesUsed,
      familyMembersActive,
      storageUsed,
      storageLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumUsageStatsImplCopyWith<_$PremiumUsageStatsImpl> get copyWith =>
      __$$PremiumUsageStatsImplCopyWithImpl<_$PremiumUsageStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumUsageStatsImplToJson(
      this,
    );
  }
}

abstract class _PremiumUsageStats implements PremiumUsageStats {
  const factory _PremiumUsageStats(
      {required final int questsCreated,
      required final int questLimit,
      required final int aiCoachInteractions,
      required final int dataExports,
      required final int backupsCreated,
      required final int themesUsed,
      required final int familyMembersActive,
      required final double storageUsed,
      required final double storageLimit}) = _$PremiumUsageStatsImpl;

  factory _PremiumUsageStats.fromJson(Map<String, dynamic> json) =
      _$PremiumUsageStatsImpl.fromJson;

  @override
  int get questsCreated;
  @override
  int get questLimit;
  @override
  int get aiCoachInteractions;
  @override
  int get dataExports;
  @override
  int get backupsCreated;
  @override
  int get themesUsed;
  @override
  int get familyMembersActive;
  @override
  double get storageUsed;
  @override
  double get storageLimit;
  @override
  @JsonKey(ignore: true)
  _$$PremiumUsageStatsImplCopyWith<_$PremiumUsageStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PremiumBenefit _$PremiumBenefitFromJson(Map<String, dynamic> json) {
  return _PremiumBenefit.fromJson(json);
}

/// @nodoc
mixin _$PremiumBenefit {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get badgeText => throw _privateConstructorUsedError;
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PremiumBenefitCopyWith<PremiumBenefit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumBenefitCopyWith<$Res> {
  factory $PremiumBenefitCopyWith(
          PremiumBenefit value, $Res Function(PremiumBenefit) then) =
      _$PremiumBenefitCopyWithImpl<$Res, PremiumBenefit>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String icon,
      bool isActive,
      String? badgeText,
      DateTime? unlockedAt});
}

/// @nodoc
class _$PremiumBenefitCopyWithImpl<$Res, $Val extends PremiumBenefit>
    implements $PremiumBenefitCopyWith<$Res> {
  _$PremiumBenefitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? isActive = null,
    Object? badgeText = freezed,
    Object? unlockedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      badgeText: freezed == badgeText
          ? _value.badgeText
          : badgeText // ignore: cast_nullable_to_non_nullable
              as String?,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumBenefitImplCopyWith<$Res>
    implements $PremiumBenefitCopyWith<$Res> {
  factory _$$PremiumBenefitImplCopyWith(_$PremiumBenefitImpl value,
          $Res Function(_$PremiumBenefitImpl) then) =
      __$$PremiumBenefitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String icon,
      bool isActive,
      String? badgeText,
      DateTime? unlockedAt});
}

/// @nodoc
class __$$PremiumBenefitImplCopyWithImpl<$Res>
    extends _$PremiumBenefitCopyWithImpl<$Res, _$PremiumBenefitImpl>
    implements _$$PremiumBenefitImplCopyWith<$Res> {
  __$$PremiumBenefitImplCopyWithImpl(
      _$PremiumBenefitImpl _value, $Res Function(_$PremiumBenefitImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? isActive = null,
    Object? badgeText = freezed,
    Object? unlockedAt = freezed,
  }) {
    return _then(_$PremiumBenefitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      badgeText: freezed == badgeText
          ? _value.badgeText
          : badgeText // ignore: cast_nullable_to_non_nullable
              as String?,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumBenefitImpl implements _PremiumBenefit {
  const _$PremiumBenefitImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.icon,
      required this.isActive,
      this.badgeText,
      this.unlockedAt});

  factory _$PremiumBenefitImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumBenefitImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String icon;
  @override
  final bool isActive;
  @override
  final String? badgeText;
  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'PremiumBenefit(id: $id, title: $title, description: $description, icon: $icon, isActive: $isActive, badgeText: $badgeText, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumBenefitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.badgeText, badgeText) ||
                other.badgeText == badgeText) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, icon,
      isActive, badgeText, unlockedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumBenefitImplCopyWith<_$PremiumBenefitImpl> get copyWith =>
      __$$PremiumBenefitImplCopyWithImpl<_$PremiumBenefitImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumBenefitImplToJson(
      this,
    );
  }
}

abstract class _PremiumBenefit implements PremiumBenefit {
  const factory _PremiumBenefit(
      {required final String id,
      required final String title,
      required final String description,
      required final String icon,
      required final bool isActive,
      final String? badgeText,
      final DateTime? unlockedAt}) = _$PremiumBenefitImpl;

  factory _PremiumBenefit.fromJson(Map<String, dynamic> json) =
      _$PremiumBenefitImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get icon;
  @override
  bool get isActive;
  @override
  String? get badgeText;
  @override
  DateTime? get unlockedAt;
  @override
  @JsonKey(ignore: true)
  _$$PremiumBenefitImplCopyWith<_$PremiumBenefitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
