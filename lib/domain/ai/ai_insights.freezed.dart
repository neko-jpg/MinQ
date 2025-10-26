// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_insights.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIInsights _$AIInsightsFromJson(Map<String, dynamic> json) {
  return _AIInsights.fromJson(json);
}

/// @nodoc
mixin _$AIInsights {
  String get userId => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;
  HabitCompletionTrends get trends => throw _privateConstructorUsedError;
  List<PersonalizedRecommendation> get recommendations =>
      throw _privateConstructorUsedError;
  ProgressAnalysis get progressAnalysis => throw _privateConstructorUsedError;
  FailurePrediction? get failurePrediction =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AIInsightsCopyWith<AIInsights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIInsightsCopyWith<$Res> {
  factory $AIInsightsCopyWith(
          AIInsights value, $Res Function(AIInsights) then) =
      _$AIInsightsCopyWithImpl<$Res, AIInsights>;
  @useResult
  $Res call(
      {String userId,
      DateTime generatedAt,
      HabitCompletionTrends trends,
      List<PersonalizedRecommendation> recommendations,
      ProgressAnalysis progressAnalysis,
      FailurePrediction? failurePrediction});

  $HabitCompletionTrendsCopyWith<$Res> get trends;
  $ProgressAnalysisCopyWith<$Res> get progressAnalysis;
  $FailurePredictionCopyWith<$Res>? get failurePrediction;
}

/// @nodoc
class _$AIInsightsCopyWithImpl<$Res, $Val extends AIInsights>
    implements $AIInsightsCopyWith<$Res> {
  _$AIInsightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? generatedAt = null,
    Object? trends = null,
    Object? recommendations = null,
    Object? progressAnalysis = null,
    Object? failurePrediction = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trends: null == trends
          ? _value.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as HabitCompletionTrends,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<PersonalizedRecommendation>,
      progressAnalysis: null == progressAnalysis
          ? _value.progressAnalysis
          : progressAnalysis // ignore: cast_nullable_to_non_nullable
              as ProgressAnalysis,
      failurePrediction: freezed == failurePrediction
          ? _value.failurePrediction
          : failurePrediction // ignore: cast_nullable_to_non_nullable
              as FailurePrediction?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HabitCompletionTrendsCopyWith<$Res> get trends {
    return $HabitCompletionTrendsCopyWith<$Res>(_value.trends, (value) {
      return _then(_value.copyWith(trends: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProgressAnalysisCopyWith<$Res> get progressAnalysis {
    return $ProgressAnalysisCopyWith<$Res>(_value.progressAnalysis, (value) {
      return _then(_value.copyWith(progressAnalysis: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $FailurePredictionCopyWith<$Res>? get failurePrediction {
    if (_value.failurePrediction == null) {
      return null;
    }

    return $FailurePredictionCopyWith<$Res>(_value.failurePrediction!, (value) {
      return _then(_value.copyWith(failurePrediction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AIInsightsImplCopyWith<$Res>
    implements $AIInsightsCopyWith<$Res> {
  factory _$$AIInsightsImplCopyWith(
          _$AIInsightsImpl value, $Res Function(_$AIInsightsImpl) then) =
      __$$AIInsightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime generatedAt,
      HabitCompletionTrends trends,
      List<PersonalizedRecommendation> recommendations,
      ProgressAnalysis progressAnalysis,
      FailurePrediction? failurePrediction});

  @override
  $HabitCompletionTrendsCopyWith<$Res> get trends;
  @override
  $ProgressAnalysisCopyWith<$Res> get progressAnalysis;
  @override
  $FailurePredictionCopyWith<$Res>? get failurePrediction;
}

/// @nodoc
class __$$AIInsightsImplCopyWithImpl<$Res>
    extends _$AIInsightsCopyWithImpl<$Res, _$AIInsightsImpl>
    implements _$$AIInsightsImplCopyWith<$Res> {
  __$$AIInsightsImplCopyWithImpl(
      _$AIInsightsImpl _value, $Res Function(_$AIInsightsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? generatedAt = null,
    Object? trends = null,
    Object? recommendations = null,
    Object? progressAnalysis = null,
    Object? failurePrediction = freezed,
  }) {
    return _then(_$AIInsightsImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trends: null == trends
          ? _value.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as HabitCompletionTrends,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<PersonalizedRecommendation>,
      progressAnalysis: null == progressAnalysis
          ? _value.progressAnalysis
          : progressAnalysis // ignore: cast_nullable_to_non_nullable
              as ProgressAnalysis,
      failurePrediction: freezed == failurePrediction
          ? _value.failurePrediction
          : failurePrediction // ignore: cast_nullable_to_non_nullable
              as FailurePrediction?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIInsightsImpl implements _AIInsights {
  const _$AIInsightsImpl(
      {required this.userId,
      required this.generatedAt,
      required this.trends,
      required final List<PersonalizedRecommendation> recommendations,
      required this.progressAnalysis,
      this.failurePrediction})
      : _recommendations = recommendations;

  factory _$AIInsightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIInsightsImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime generatedAt;
  @override
  final HabitCompletionTrends trends;
  final List<PersonalizedRecommendation> _recommendations;
  @override
  List<PersonalizedRecommendation> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  final ProgressAnalysis progressAnalysis;
  @override
  final FailurePrediction? failurePrediction;

  @override
  String toString() {
    return 'AIInsights(userId: $userId, generatedAt: $generatedAt, trends: $trends, recommendations: $recommendations, progressAnalysis: $progressAnalysis, failurePrediction: $failurePrediction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIInsightsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.trends, trends) || other.trends == trends) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations) &&
            (identical(other.progressAnalysis, progressAnalysis) ||
                other.progressAnalysis == progressAnalysis) &&
            (identical(other.failurePrediction, failurePrediction) ||
                other.failurePrediction == failurePrediction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      generatedAt,
      trends,
      const DeepCollectionEquality().hash(_recommendations),
      progressAnalysis,
      failurePrediction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AIInsightsImplCopyWith<_$AIInsightsImpl> get copyWith =>
      __$$AIInsightsImplCopyWithImpl<_$AIInsightsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIInsightsImplToJson(
      this,
    );
  }
}

abstract class _AIInsights implements AIInsights {
  const factory _AIInsights(
      {required final String userId,
      required final DateTime generatedAt,
      required final HabitCompletionTrends trends,
      required final List<PersonalizedRecommendation> recommendations,
      required final ProgressAnalysis progressAnalysis,
      final FailurePrediction? failurePrediction}) = _$AIInsightsImpl;

  factory _AIInsights.fromJson(Map<String, dynamic> json) =
      _$AIInsightsImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get generatedAt;
  @override
  HabitCompletionTrends get trends;
  @override
  List<PersonalizedRecommendation> get recommendations;
  @override
  ProgressAnalysis get progressAnalysis;
  @override
  FailurePrediction? get failurePrediction;
  @override
  @JsonKey(ignore: true)
  _$$AIInsightsImplCopyWith<_$AIInsightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HabitCompletionTrends _$HabitCompletionTrendsFromJson(
    Map<String, dynamic> json) {
  return _HabitCompletionTrends.fromJson(json);
}

/// @nodoc
mixin _$HabitCompletionTrends {
  Map<String, double> get weeklyTrends =>
      throw _privateConstructorUsedError; // Week -> completion rate
  Map<String, double> get dailyTrends =>
      throw _privateConstructorUsedError; // Day -> completion rate
  Map<String, int> get categoryDistribution =>
      throw _privateConstructorUsedError; // Category -> count
  double get overallTrend =>
      throw _privateConstructorUsedError; // -1.0 to 1.0 (declining to improving)
  String get trendDescription => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HabitCompletionTrendsCopyWith<HabitCompletionTrends> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitCompletionTrendsCopyWith<$Res> {
  factory $HabitCompletionTrendsCopyWith(HabitCompletionTrends value,
          $Res Function(HabitCompletionTrends) then) =
      _$HabitCompletionTrendsCopyWithImpl<$Res, HabitCompletionTrends>;
  @useResult
  $Res call(
      {Map<String, double> weeklyTrends,
      Map<String, double> dailyTrends,
      Map<String, int> categoryDistribution,
      double overallTrend,
      String trendDescription});
}

/// @nodoc
class _$HabitCompletionTrendsCopyWithImpl<$Res,
        $Val extends HabitCompletionTrends>
    implements $HabitCompletionTrendsCopyWith<$Res> {
  _$HabitCompletionTrendsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weeklyTrends = null,
    Object? dailyTrends = null,
    Object? categoryDistribution = null,
    Object? overallTrend = null,
    Object? trendDescription = null,
  }) {
    return _then(_value.copyWith(
      weeklyTrends: null == weeklyTrends
          ? _value.weeklyTrends
          : weeklyTrends // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      dailyTrends: null == dailyTrends
          ? _value.dailyTrends
          : dailyTrends // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      categoryDistribution: null == categoryDistribution
          ? _value.categoryDistribution
          : categoryDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      overallTrend: null == overallTrend
          ? _value.overallTrend
          : overallTrend // ignore: cast_nullable_to_non_nullable
              as double,
      trendDescription: null == trendDescription
          ? _value.trendDescription
          : trendDescription // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitCompletionTrendsImplCopyWith<$Res>
    implements $HabitCompletionTrendsCopyWith<$Res> {
  factory _$$HabitCompletionTrendsImplCopyWith(
          _$HabitCompletionTrendsImpl value,
          $Res Function(_$HabitCompletionTrendsImpl) then) =
      __$$HabitCompletionTrendsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, double> weeklyTrends,
      Map<String, double> dailyTrends,
      Map<String, int> categoryDistribution,
      double overallTrend,
      String trendDescription});
}

/// @nodoc
class __$$HabitCompletionTrendsImplCopyWithImpl<$Res>
    extends _$HabitCompletionTrendsCopyWithImpl<$Res,
        _$HabitCompletionTrendsImpl>
    implements _$$HabitCompletionTrendsImplCopyWith<$Res> {
  __$$HabitCompletionTrendsImplCopyWithImpl(_$HabitCompletionTrendsImpl _value,
      $Res Function(_$HabitCompletionTrendsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weeklyTrends = null,
    Object? dailyTrends = null,
    Object? categoryDistribution = null,
    Object? overallTrend = null,
    Object? trendDescription = null,
  }) {
    return _then(_$HabitCompletionTrendsImpl(
      weeklyTrends: null == weeklyTrends
          ? _value._weeklyTrends
          : weeklyTrends // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      dailyTrends: null == dailyTrends
          ? _value._dailyTrends
          : dailyTrends // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      categoryDistribution: null == categoryDistribution
          ? _value._categoryDistribution
          : categoryDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      overallTrend: null == overallTrend
          ? _value.overallTrend
          : overallTrend // ignore: cast_nullable_to_non_nullable
              as double,
      trendDescription: null == trendDescription
          ? _value.trendDescription
          : trendDescription // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitCompletionTrendsImpl implements _HabitCompletionTrends {
  const _$HabitCompletionTrendsImpl(
      {required final Map<String, double> weeklyTrends,
      required final Map<String, double> dailyTrends,
      required final Map<String, int> categoryDistribution,
      required this.overallTrend,
      required this.trendDescription})
      : _weeklyTrends = weeklyTrends,
        _dailyTrends = dailyTrends,
        _categoryDistribution = categoryDistribution;

  factory _$HabitCompletionTrendsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitCompletionTrendsImplFromJson(json);

  final Map<String, double> _weeklyTrends;
  @override
  Map<String, double> get weeklyTrends {
    if (_weeklyTrends is EqualUnmodifiableMapView) return _weeklyTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_weeklyTrends);
  }

// Week -> completion rate
  final Map<String, double> _dailyTrends;
// Week -> completion rate
  @override
  Map<String, double> get dailyTrends {
    if (_dailyTrends is EqualUnmodifiableMapView) return _dailyTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dailyTrends);
  }

// Day -> completion rate
  final Map<String, int> _categoryDistribution;
// Day -> completion rate
  @override
  Map<String, int> get categoryDistribution {
    if (_categoryDistribution is EqualUnmodifiableMapView)
      return _categoryDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryDistribution);
  }

// Category -> count
  @override
  final double overallTrend;
// -1.0 to 1.0 (declining to improving)
  @override
  final String trendDescription;

  @override
  String toString() {
    return 'HabitCompletionTrends(weeklyTrends: $weeklyTrends, dailyTrends: $dailyTrends, categoryDistribution: $categoryDistribution, overallTrend: $overallTrend, trendDescription: $trendDescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitCompletionTrendsImpl &&
            const DeepCollectionEquality()
                .equals(other._weeklyTrends, _weeklyTrends) &&
            const DeepCollectionEquality()
                .equals(other._dailyTrends, _dailyTrends) &&
            const DeepCollectionEquality()
                .equals(other._categoryDistribution, _categoryDistribution) &&
            (identical(other.overallTrend, overallTrend) ||
                other.overallTrend == overallTrend) &&
            (identical(other.trendDescription, trendDescription) ||
                other.trendDescription == trendDescription));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_weeklyTrends),
      const DeepCollectionEquality().hash(_dailyTrends),
      const DeepCollectionEquality().hash(_categoryDistribution),
      overallTrend,
      trendDescription);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitCompletionTrendsImplCopyWith<_$HabitCompletionTrendsImpl>
      get copyWith => __$$HabitCompletionTrendsImplCopyWithImpl<
          _$HabitCompletionTrendsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitCompletionTrendsImplToJson(
      this,
    );
  }
}

abstract class _HabitCompletionTrends implements HabitCompletionTrends {
  const factory _HabitCompletionTrends(
      {required final Map<String, double> weeklyTrends,
      required final Map<String, double> dailyTrends,
      required final Map<String, int> categoryDistribution,
      required final double overallTrend,
      required final String trendDescription}) = _$HabitCompletionTrendsImpl;

  factory _HabitCompletionTrends.fromJson(Map<String, dynamic> json) =
      _$HabitCompletionTrendsImpl.fromJson;

  @override
  Map<String, double> get weeklyTrends;
  @override // Week -> completion rate
  Map<String, double> get dailyTrends;
  @override // Day -> completion rate
  Map<String, int> get categoryDistribution;
  @override // Category -> count
  double get overallTrend;
  @override // -1.0 to 1.0 (declining to improving)
  String get trendDescription;
  @override
  @JsonKey(ignore: true)
  _$$HabitCompletionTrendsImplCopyWith<_$HabitCompletionTrendsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PersonalizedRecommendation _$PersonalizedRecommendationFromJson(
    Map<String, dynamic> json) {
  return _PersonalizedRecommendation.fromJson(json);
}

/// @nodoc
mixin _$PersonalizedRecommendation {
  String get id => throw _privateConstructorUsedError;
  RecommendationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError; // 0.0 to 1.0
  List<String> get relatedHabits => throw _privateConstructorUsedError;
  String get actionText => throw _privateConstructorUsedError;
  String? get iconKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersonalizedRecommendationCopyWith<PersonalizedRecommendation>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalizedRecommendationCopyWith<$Res> {
  factory $PersonalizedRecommendationCopyWith(PersonalizedRecommendation value,
          $Res Function(PersonalizedRecommendation) then) =
      _$PersonalizedRecommendationCopyWithImpl<$Res,
          PersonalizedRecommendation>;
  @useResult
  $Res call(
      {String id,
      RecommendationType type,
      String title,
      String description,
      double confidence,
      List<String> relatedHabits,
      String actionText,
      String? iconKey});
}

/// @nodoc
class _$PersonalizedRecommendationCopyWithImpl<$Res,
        $Val extends PersonalizedRecommendation>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  _$PersonalizedRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? confidence = null,
    Object? relatedHabits = null,
    Object? actionText = null,
    Object? iconKey = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      relatedHabits: null == relatedHabits
          ? _value.relatedHabits
          : relatedHabits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      actionText: null == actionText
          ? _value.actionText
          : actionText // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: freezed == iconKey
          ? _value.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalizedRecommendationImplCopyWith<$Res>
    implements $PersonalizedRecommendationCopyWith<$Res> {
  factory _$$PersonalizedRecommendationImplCopyWith(
          _$PersonalizedRecommendationImpl value,
          $Res Function(_$PersonalizedRecommendationImpl) then) =
      __$$PersonalizedRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      RecommendationType type,
      String title,
      String description,
      double confidence,
      List<String> relatedHabits,
      String actionText,
      String? iconKey});
}

/// @nodoc
class __$$PersonalizedRecommendationImplCopyWithImpl<$Res>
    extends _$PersonalizedRecommendationCopyWithImpl<$Res,
        _$PersonalizedRecommendationImpl>
    implements _$$PersonalizedRecommendationImplCopyWith<$Res> {
  __$$PersonalizedRecommendationImplCopyWithImpl(
      _$PersonalizedRecommendationImpl _value,
      $Res Function(_$PersonalizedRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? confidence = null,
    Object? relatedHabits = null,
    Object? actionText = null,
    Object? iconKey = freezed,
  }) {
    return _then(_$PersonalizedRecommendationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      relatedHabits: null == relatedHabits
          ? _value._relatedHabits
          : relatedHabits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      actionText: null == actionText
          ? _value.actionText
          : actionText // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: freezed == iconKey
          ? _value.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalizedRecommendationImpl implements _PersonalizedRecommendation {
  const _$PersonalizedRecommendationImpl(
      {required this.id,
      required this.type,
      required this.title,
      required this.description,
      required this.confidence,
      required final List<String> relatedHabits,
      required this.actionText,
      this.iconKey})
      : _relatedHabits = relatedHabits;

  factory _$PersonalizedRecommendationImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$PersonalizedRecommendationImplFromJson(json);

  @override
  final String id;
  @override
  final RecommendationType type;
  @override
  final String title;
  @override
  final String description;
  @override
  final double confidence;
// 0.0 to 1.0
  final List<String> _relatedHabits;
// 0.0 to 1.0
  @override
  List<String> get relatedHabits {
    if (_relatedHabits is EqualUnmodifiableListView) return _relatedHabits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedHabits);
  }

  @override
  final String actionText;
  @override
  final String? iconKey;

  @override
  String toString() {
    return 'PersonalizedRecommendation(id: $id, type: $type, title: $title, description: $description, confidence: $confidence, relatedHabits: $relatedHabits, actionText: $actionText, iconKey: $iconKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalizedRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality()
                .equals(other._relatedHabits, _relatedHabits) &&
            (identical(other.actionText, actionText) ||
                other.actionText == actionText) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      description,
      confidence,
      const DeepCollectionEquality().hash(_relatedHabits),
      actionText,
      iconKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalizedRecommendationImplCopyWith<_$PersonalizedRecommendationImpl>
      get copyWith => __$$PersonalizedRecommendationImplCopyWithImpl<
          _$PersonalizedRecommendationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalizedRecommendationImplToJson(
      this,
    );
  }
}

abstract class _PersonalizedRecommendation
    implements PersonalizedRecommendation {
  const factory _PersonalizedRecommendation(
      {required final String id,
      required final RecommendationType type,
      required final String title,
      required final String description,
      required final double confidence,
      required final List<String> relatedHabits,
      required final String actionText,
      final String? iconKey}) = _$PersonalizedRecommendationImpl;

  factory _PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =
      _$PersonalizedRecommendationImpl.fromJson;

  @override
  String get id;
  @override
  RecommendationType get type;
  @override
  String get title;
  @override
  String get description;
  @override
  double get confidence;
  @override // 0.0 to 1.0
  List<String> get relatedHabits;
  @override
  String get actionText;
  @override
  String? get iconKey;
  @override
  @JsonKey(ignore: true)
  _$$PersonalizedRecommendationImplCopyWith<_$PersonalizedRecommendationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ProgressAnalysis _$ProgressAnalysisFromJson(Map<String, dynamic> json) {
  return _ProgressAnalysis.fromJson(json);
}

/// @nodoc
mixin _$ProgressAnalysis {
  double get currentStreak => throw _privateConstructorUsedError;
  double get longestStreak => throw _privateConstructorUsedError;
  double get weeklyCompletionRate => throw _privateConstructorUsedError;
  double get monthlyCompletionRate => throw _privateConstructorUsedError;
  int get totalHabitsCompleted => throw _privateConstructorUsedError;
  Map<String, double> get categoryPerformance =>
      throw _privateConstructorUsedError; // Category -> completion rate
  List<ProgressInsight> get insights => throw _privateConstructorUsedError;
  double get overallScore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressAnalysisCopyWith<ProgressAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressAnalysisCopyWith<$Res> {
  factory $ProgressAnalysisCopyWith(
          ProgressAnalysis value, $Res Function(ProgressAnalysis) then) =
      _$ProgressAnalysisCopyWithImpl<$Res, ProgressAnalysis>;
  @useResult
  $Res call(
      {double currentStreak,
      double longestStreak,
      double weeklyCompletionRate,
      double monthlyCompletionRate,
      int totalHabitsCompleted,
      Map<String, double> categoryPerformance,
      List<ProgressInsight> insights,
      double overallScore});
}

/// @nodoc
class _$ProgressAnalysisCopyWithImpl<$Res, $Val extends ProgressAnalysis>
    implements $ProgressAnalysisCopyWith<$Res> {
  _$ProgressAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? weeklyCompletionRate = null,
    Object? monthlyCompletionRate = null,
    Object? totalHabitsCompleted = null,
    Object? categoryPerformance = null,
    Object? insights = null,
    Object? overallScore = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as double,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyCompletionRate: null == weeklyCompletionRate
          ? _value.weeklyCompletionRate
          : weeklyCompletionRate // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyCompletionRate: null == monthlyCompletionRate
          ? _value.monthlyCompletionRate
          : monthlyCompletionRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalHabitsCompleted: null == totalHabitsCompleted
          ? _value.totalHabitsCompleted
          : totalHabitsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      categoryPerformance: null == categoryPerformance
          ? _value.categoryPerformance
          : categoryPerformance // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<ProgressInsight>,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressAnalysisImplCopyWith<$Res>
    implements $ProgressAnalysisCopyWith<$Res> {
  factory _$$ProgressAnalysisImplCopyWith(_$ProgressAnalysisImpl value,
          $Res Function(_$ProgressAnalysisImpl) then) =
      __$$ProgressAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double currentStreak,
      double longestStreak,
      double weeklyCompletionRate,
      double monthlyCompletionRate,
      int totalHabitsCompleted,
      Map<String, double> categoryPerformance,
      List<ProgressInsight> insights,
      double overallScore});
}

/// @nodoc
class __$$ProgressAnalysisImplCopyWithImpl<$Res>
    extends _$ProgressAnalysisCopyWithImpl<$Res, _$ProgressAnalysisImpl>
    implements _$$ProgressAnalysisImplCopyWith<$Res> {
  __$$ProgressAnalysisImplCopyWithImpl(_$ProgressAnalysisImpl _value,
      $Res Function(_$ProgressAnalysisImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? weeklyCompletionRate = null,
    Object? monthlyCompletionRate = null,
    Object? totalHabitsCompleted = null,
    Object? categoryPerformance = null,
    Object? insights = null,
    Object? overallScore = null,
  }) {
    return _then(_$ProgressAnalysisImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as double,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyCompletionRate: null == weeklyCompletionRate
          ? _value.weeklyCompletionRate
          : weeklyCompletionRate // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyCompletionRate: null == monthlyCompletionRate
          ? _value.monthlyCompletionRate
          : monthlyCompletionRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalHabitsCompleted: null == totalHabitsCompleted
          ? _value.totalHabitsCompleted
          : totalHabitsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      categoryPerformance: null == categoryPerformance
          ? _value._categoryPerformance
          : categoryPerformance // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      insights: null == insights
          ? _value._insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<ProgressInsight>,
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressAnalysisImpl implements _ProgressAnalysis {
  const _$ProgressAnalysisImpl(
      {required this.currentStreak,
      required this.longestStreak,
      required this.weeklyCompletionRate,
      required this.monthlyCompletionRate,
      required this.totalHabitsCompleted,
      required final Map<String, double> categoryPerformance,
      required final List<ProgressInsight> insights,
      required this.overallScore})
      : _categoryPerformance = categoryPerformance,
        _insights = insights;

  factory _$ProgressAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressAnalysisImplFromJson(json);

  @override
  final double currentStreak;
  @override
  final double longestStreak;
  @override
  final double weeklyCompletionRate;
  @override
  final double monthlyCompletionRate;
  @override
  final int totalHabitsCompleted;
  final Map<String, double> _categoryPerformance;
  @override
  Map<String, double> get categoryPerformance {
    if (_categoryPerformance is EqualUnmodifiableMapView)
      return _categoryPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryPerformance);
  }

// Category -> completion rate
  final List<ProgressInsight> _insights;
// Category -> completion rate
  @override
  List<ProgressInsight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  @override
  final double overallScore;

  @override
  String toString() {
    return 'ProgressAnalysis(currentStreak: $currentStreak, longestStreak: $longestStreak, weeklyCompletionRate: $weeklyCompletionRate, monthlyCompletionRate: $monthlyCompletionRate, totalHabitsCompleted: $totalHabitsCompleted, categoryPerformance: $categoryPerformance, insights: $insights, overallScore: $overallScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressAnalysisImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.weeklyCompletionRate, weeklyCompletionRate) ||
                other.weeklyCompletionRate == weeklyCompletionRate) &&
            (identical(other.monthlyCompletionRate, monthlyCompletionRate) ||
                other.monthlyCompletionRate == monthlyCompletionRate) &&
            (identical(other.totalHabitsCompleted, totalHabitsCompleted) ||
                other.totalHabitsCompleted == totalHabitsCompleted) &&
            const DeepCollectionEquality()
                .equals(other._categoryPerformance, _categoryPerformance) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStreak,
      longestStreak,
      weeklyCompletionRate,
      monthlyCompletionRate,
      totalHabitsCompleted,
      const DeepCollectionEquality().hash(_categoryPerformance),
      const DeepCollectionEquality().hash(_insights),
      overallScore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressAnalysisImplCopyWith<_$ProgressAnalysisImpl> get copyWith =>
      __$$ProgressAnalysisImplCopyWithImpl<_$ProgressAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressAnalysisImplToJson(
      this,
    );
  }
}

abstract class _ProgressAnalysis implements ProgressAnalysis {
  const factory _ProgressAnalysis(
      {required final double currentStreak,
      required final double longestStreak,
      required final double weeklyCompletionRate,
      required final double monthlyCompletionRate,
      required final int totalHabitsCompleted,
      required final Map<String, double> categoryPerformance,
      required final List<ProgressInsight> insights,
      required final double overallScore}) = _$ProgressAnalysisImpl;

  factory _ProgressAnalysis.fromJson(Map<String, dynamic> json) =
      _$ProgressAnalysisImpl.fromJson;

  @override
  double get currentStreak;
  @override
  double get longestStreak;
  @override
  double get weeklyCompletionRate;
  @override
  double get monthlyCompletionRate;
  @override
  int get totalHabitsCompleted;
  @override
  Map<String, double> get categoryPerformance;
  @override // Category -> completion rate
  List<ProgressInsight> get insights;
  @override
  double get overallScore;
  @override
  @JsonKey(ignore: true)
  _$$ProgressAnalysisImplCopyWith<_$ProgressAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressInsight _$ProgressInsightFromJson(Map<String, dynamic> json) {
  return _ProgressInsight.fromJson(json);
}

/// @nodoc
mixin _$ProgressInsight {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  InsightType get type => throw _privateConstructorUsedError;
  double get impact => throw _privateConstructorUsedError; // 0.0 to 1.0
  String? get actionRecommendation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProgressInsightCopyWith<ProgressInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressInsightCopyWith<$Res> {
  factory $ProgressInsightCopyWith(
          ProgressInsight value, $Res Function(ProgressInsight) then) =
      _$ProgressInsightCopyWithImpl<$Res, ProgressInsight>;
  @useResult
  $Res call(
      {String title,
      String description,
      InsightType type,
      double impact,
      String? actionRecommendation});
}

/// @nodoc
class _$ProgressInsightCopyWithImpl<$Res, $Val extends ProgressInsight>
    implements $ProgressInsightCopyWith<$Res> {
  _$ProgressInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? impact = null,
    Object? actionRecommendation = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InsightType,
      impact: null == impact
          ? _value.impact
          : impact // ignore: cast_nullable_to_non_nullable
              as double,
      actionRecommendation: freezed == actionRecommendation
          ? _value.actionRecommendation
          : actionRecommendation // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressInsightImplCopyWith<$Res>
    implements $ProgressInsightCopyWith<$Res> {
  factory _$$ProgressInsightImplCopyWith(_$ProgressInsightImpl value,
          $Res Function(_$ProgressInsightImpl) then) =
      __$$ProgressInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      InsightType type,
      double impact,
      String? actionRecommendation});
}

/// @nodoc
class __$$ProgressInsightImplCopyWithImpl<$Res>
    extends _$ProgressInsightCopyWithImpl<$Res, _$ProgressInsightImpl>
    implements _$$ProgressInsightImplCopyWith<$Res> {
  __$$ProgressInsightImplCopyWithImpl(
      _$ProgressInsightImpl _value, $Res Function(_$ProgressInsightImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? impact = null,
    Object? actionRecommendation = freezed,
  }) {
    return _then(_$ProgressInsightImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InsightType,
      impact: null == impact
          ? _value.impact
          : impact // ignore: cast_nullable_to_non_nullable
              as double,
      actionRecommendation: freezed == actionRecommendation
          ? _value.actionRecommendation
          : actionRecommendation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressInsightImpl implements _ProgressInsight {
  const _$ProgressInsightImpl(
      {required this.title,
      required this.description,
      required this.type,
      required this.impact,
      this.actionRecommendation});

  factory _$ProgressInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressInsightImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final InsightType type;
  @override
  final double impact;
// 0.0 to 1.0
  @override
  final String? actionRecommendation;

  @override
  String toString() {
    return 'ProgressInsight(title: $title, description: $description, type: $type, impact: $impact, actionRecommendation: $actionRecommendation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressInsightImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.impact, impact) || other.impact == impact) &&
            (identical(other.actionRecommendation, actionRecommendation) ||
                other.actionRecommendation == actionRecommendation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, title, description, type, impact, actionRecommendation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressInsightImplCopyWith<_$ProgressInsightImpl> get copyWith =>
      __$$ProgressInsightImplCopyWithImpl<_$ProgressInsightImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressInsightImplToJson(
      this,
    );
  }
}

abstract class _ProgressInsight implements ProgressInsight {
  const factory _ProgressInsight(
      {required final String title,
      required final String description,
      required final InsightType type,
      required final double impact,
      final String? actionRecommendation}) = _$ProgressInsightImpl;

  factory _ProgressInsight.fromJson(Map<String, dynamic> json) =
      _$ProgressInsightImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  InsightType get type;
  @override
  double get impact;
  @override // 0.0 to 1.0
  String? get actionRecommendation;
  @override
  @JsonKey(ignore: true)
  _$$ProgressInsightImplCopyWith<_$ProgressInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FailurePrediction _$FailurePredictionFromJson(Map<String, dynamic> json) {
  return _FailurePrediction.fromJson(json);
}

/// @nodoc
mixin _$FailurePrediction {
  double get riskScore => throw _privateConstructorUsedError; // 0.0 to 1.0
  List<String> get riskFactors => throw _privateConstructorUsedError;
  List<String> get preventionStrategies => throw _privateConstructorUsedError;
  DateTime get predictedDate => throw _privateConstructorUsedError;
  String get riskLevel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FailurePredictionCopyWith<FailurePrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailurePredictionCopyWith<$Res> {
  factory $FailurePredictionCopyWith(
          FailurePrediction value, $Res Function(FailurePrediction) then) =
      _$FailurePredictionCopyWithImpl<$Res, FailurePrediction>;
  @useResult
  $Res call(
      {double riskScore,
      List<String> riskFactors,
      List<String> preventionStrategies,
      DateTime predictedDate,
      String riskLevel});
}

/// @nodoc
class _$FailurePredictionCopyWithImpl<$Res, $Val extends FailurePrediction>
    implements $FailurePredictionCopyWith<$Res> {
  _$FailurePredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskScore = null,
    Object? riskFactors = null,
    Object? preventionStrategies = null,
    Object? predictedDate = null,
    Object? riskLevel = null,
  }) {
    return _then(_value.copyWith(
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskFactors: null == riskFactors
          ? _value.riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preventionStrategies: null == preventionStrategies
          ? _value.preventionStrategies
          : preventionStrategies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      predictedDate: null == predictedDate
          ? _value.predictedDate
          : predictedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FailurePredictionImplCopyWith<$Res>
    implements $FailurePredictionCopyWith<$Res> {
  factory _$$FailurePredictionImplCopyWith(_$FailurePredictionImpl value,
          $Res Function(_$FailurePredictionImpl) then) =
      __$$FailurePredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double riskScore,
      List<String> riskFactors,
      List<String> preventionStrategies,
      DateTime predictedDate,
      String riskLevel});
}

/// @nodoc
class __$$FailurePredictionImplCopyWithImpl<$Res>
    extends _$FailurePredictionCopyWithImpl<$Res, _$FailurePredictionImpl>
    implements _$$FailurePredictionImplCopyWith<$Res> {
  __$$FailurePredictionImplCopyWithImpl(_$FailurePredictionImpl _value,
      $Res Function(_$FailurePredictionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskScore = null,
    Object? riskFactors = null,
    Object? preventionStrategies = null,
    Object? predictedDate = null,
    Object? riskLevel = null,
  }) {
    return _then(_$FailurePredictionImpl(
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskFactors: null == riskFactors
          ? _value._riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preventionStrategies: null == preventionStrategies
          ? _value._preventionStrategies
          : preventionStrategies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      predictedDate: null == predictedDate
          ? _value.predictedDate
          : predictedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FailurePredictionImpl implements _FailurePrediction {
  const _$FailurePredictionImpl(
      {required this.riskScore,
      required final List<String> riskFactors,
      required final List<String> preventionStrategies,
      required this.predictedDate,
      required this.riskLevel})
      : _riskFactors = riskFactors,
        _preventionStrategies = preventionStrategies;

  factory _$FailurePredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FailurePredictionImplFromJson(json);

  @override
  final double riskScore;
// 0.0 to 1.0
  final List<String> _riskFactors;
// 0.0 to 1.0
  @override
  List<String> get riskFactors {
    if (_riskFactors is EqualUnmodifiableListView) return _riskFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskFactors);
  }

  final List<String> _preventionStrategies;
  @override
  List<String> get preventionStrategies {
    if (_preventionStrategies is EqualUnmodifiableListView)
      return _preventionStrategies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preventionStrategies);
  }

  @override
  final DateTime predictedDate;
  @override
  final String riskLevel;

  @override
  String toString() {
    return 'FailurePrediction(riskScore: $riskScore, riskFactors: $riskFactors, preventionStrategies: $preventionStrategies, predictedDate: $predictedDate, riskLevel: $riskLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailurePredictionImpl &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            const DeepCollectionEquality()
                .equals(other._riskFactors, _riskFactors) &&
            const DeepCollectionEquality()
                .equals(other._preventionStrategies, _preventionStrategies) &&
            (identical(other.predictedDate, predictedDate) ||
                other.predictedDate == predictedDate) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      riskScore,
      const DeepCollectionEquality().hash(_riskFactors),
      const DeepCollectionEquality().hash(_preventionStrategies),
      predictedDate,
      riskLevel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FailurePredictionImplCopyWith<_$FailurePredictionImpl> get copyWith =>
      __$$FailurePredictionImplCopyWithImpl<_$FailurePredictionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FailurePredictionImplToJson(
      this,
    );
  }
}

abstract class _FailurePrediction implements FailurePrediction {
  const factory _FailurePrediction(
      {required final double riskScore,
      required final List<String> riskFactors,
      required final List<String> preventionStrategies,
      required final DateTime predictedDate,
      required final String riskLevel}) = _$FailurePredictionImpl;

  factory _FailurePrediction.fromJson(Map<String, dynamic> json) =
      _$FailurePredictionImpl.fromJson;

  @override
  double get riskScore;
  @override // 0.0 to 1.0
  List<String> get riskFactors;
  @override
  List<String> get preventionStrategies;
  @override
  DateTime get predictedDate;
  @override
  String get riskLevel;
  @override
  @JsonKey(ignore: true)
  _$$FailurePredictionImplCopyWith<_$FailurePredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
