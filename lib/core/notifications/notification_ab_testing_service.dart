import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:minq/domain/notification/notification_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知A/Bテストサービス
class NotificationABTestingService {
  static const String _testsKey = 'notification_ab_tests';
  static const String _userVariantsKey = 'user_ab_variants';

  final SharedPreferences _prefs;
  final math.Random _random = math.Random();

  NotificationABTestingService({required SharedPreferences prefs})
    : _prefs = prefs;

  /// A/Bテストを作成
  Future<String> createABTest({
    required String testName,
    required NotificationCategory category,
    required List<ABTestVariant> variants,
    required DateTime startDate,
    required DateTime endDate,
    double trafficAllocation = 1.0,
  }) async {
    final testId = _generateTestId();

    final test = ABTest(
      id: testId,
      name: testName,
      category: category,
      variants: variants,
      startDate: startDate,
      endDate: endDate,
      trafficAllocation: trafficAllocation,
      status: ABTestStatus.active,
      createdAt: DateTime.now(),
    );

    await _saveTest(test);

    debugPrint('Created A/B test: $testName ($testId)');
    return testId;
  }

  /// ユーザーのバリアントを取得
  Future<ABTestVariant?> getUserVariant(String userId, String testId) async {
    final test = await _getTest(testId);
    if (test == null || !_isTestActive(test)) {
      return null;
    }

    // 既存のバリアント割り当てをチェック
    final existingVariant = await _getExistingVariant(userId, testId);
    if (existingVariant != null) {
      return existingVariant;
    }

    // トラフィック割り当てをチェック
    if (_random.nextDouble() > test.trafficAllocation) {
      return null; // テスト対象外
    }

    // バリアントを割り当て
    final variant = _assignVariant(test.variants);
    await _saveUserVariant(userId, testId, variant);

    debugPrint(
      'Assigned variant ${variant.name} to user $userId for test $testId',
    );
    return variant;
  }

  /// テスト結果を記録
  Future<void> recordTestResult({
    required String userId,
    required String testId,
    required String variantName,
    required ABTestEvent event,
    Map<String, dynamic>? metadata,
  }) async {
    final test = await _getTest(testId);
    if (test == null || !_isTestActive(test)) {
      return;
    }

    final result = ABTestResult(
      testId: testId,
      userId: userId,
      variantName: variantName,
      event: event,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await _saveTestResult(result);
  }

  /// テスト分析を実行
  Future<ABTestAnalysis> analyzeTest(String testId) async {
    final test = await _getTest(testId);
    if (test == null) {
      throw Exception('Test not found: $testId');
    }

    final results = await _getTestResults(testId);

    // バリアント別統計を計算
    final variantStats = <String, ABTestVariantStats>{};

    for (final variant in test.variants) {
      final variantResults =
          results.where((r) => r.variantName == variant.name).toList();

      final impressions =
          variantResults.where((r) => r.event == ABTestEvent.impression).length;
      final conversions =
          variantResults.where((r) => r.event == ABTestEvent.conversion).length;

      final conversionRate = impressions > 0 ? conversions / impressions : 0.0;

      variantStats[variant.name] = ABTestVariantStats(
        variantName: variant.name,
        impressions: impressions,
        conversions: conversions,
        conversionRate: conversionRate,
      );
    }

    // 統計的有意性を計算
    final significance = _calculateStatisticalSignificance(variantStats);

    // 勝者を決定
    final winner = _determineWinner(variantStats, significance);

    return ABTestAnalysis(
      testId: testId,
      testName: test.name,
      startDate: test.startDate,
      endDate: test.endDate,
      variantStats: variantStats,
      statisticalSignificance: significance,
      winner: winner,
      confidence: _calculateConfidence(variantStats),
      analyzedAt: DateTime.now(),
    );
  }

  /// アクティブなテスト一覧を取得
  Future<List<ABTest>> getActiveTests() async {
    final tests = await _getAllTests();
    return tests.where(_isTestActive).toList();
  }

  /// テストを停止
  Future<void> stopTest(String testId) async {
    final test = await _getTest(testId);
    if (test == null) return;

    final updatedTest = test.copyWith(
      status: ABTestStatus.stopped,
      endDate: DateTime.now(),
    );

    await _saveTest(updatedTest);
    debugPrint('Stopped A/B test: ${test.name} ($testId)');
  }

  /// テストがアクティブかチェック
  bool _isTestActive(ABTest test) {
    final now = DateTime.now();
    return test.status == ABTestStatus.active &&
        now.isAfter(test.startDate) &&
        now.isBefore(test.endDate);
  }

  /// バリアントを割り当て
  ABTestVariant _assignVariant(List<ABTestVariant> variants) {
    final totalWeight = variants.fold(0.0, (sum, v) => sum + v.weight);
    final randomValue = _random.nextDouble() * totalWeight;

    double currentWeight = 0.0;
    for (final variant in variants) {
      currentWeight += variant.weight;
      if (randomValue <= currentWeight) {
        return variant;
      }
    }

    return variants.last; // フォールバック
  }

  /// 統計的有意性を計算
  double _calculateStatisticalSignificance(
    Map<String, ABTestVariantStats> stats,
  ) {
    if (stats.length < 2) return 0.0;

    final variants = stats.values.toList();
    final control = variants.first;
    final treatment = variants.last;

    // 簡単なZ検定を実行
    final p1 = control.conversionRate;
    final p2 = treatment.conversionRate;
    final n1 = control.impressions;
    final n2 = treatment.impressions;

    if (n1 < 30 || n2 < 30) return 0.0; // サンプルサイズが小さすぎる

    final pooledP = (control.conversions + treatment.conversions) / (n1 + n2);
    final se = math.sqrt(pooledP * (1 - pooledP) * (1 / n1 + 1 / n2));

    if (se == 0) return 0.0;

    final z = (p2 - p1).abs() / se;

    // Z値から信頼度を計算（簡略化）
    if (z > 2.58) return 0.99; // 99%
    if (z > 1.96) return 0.95; // 95%
    if (z > 1.65) return 0.90; // 90%

    return 0.0;
  }

  /// 勝者を決定
  String? _determineWinner(
    Map<String, ABTestVariantStats> stats,
    double significance,
  ) {
    if (significance < 0.95) return null; // 統計的有意性が不十分

    final sortedVariants =
        stats.entries.toList()..sort(
          (a, b) => b.value.conversionRate.compareTo(a.value.conversionRate),
        );

    return sortedVariants.first.key;
  }

  /// 信頼度を計算
  double _calculateConfidence(Map<String, ABTestVariantStats> stats) {
    final totalImpressions = stats.values.fold(
      0,
      (sum, s) => sum + s.impressions,
    );

    if (totalImpressions < 100) return 0.0;
    if (totalImpressions < 500) return 0.3;
    if (totalImpressions < 1000) return 0.6;
    if (totalImpressions < 5000) return 0.8;

    return 1.0;
  }

  // データ永続化メソッド
  Future<void> _saveTest(ABTest test) async {
    final tests = await _getAllTests();
    final index = tests.indexWhere((t) => t.id == test.id);

    if (index >= 0) {
      tests[index] = test;
    } else {
      tests.add(test);
    }

    final testsJson = jsonEncode(tests.map((t) => t.toJson()).toList());
    await _prefs.setString(_testsKey, testsJson);
  }

  Future<ABTest?> _getTest(String testId) async {
    final tests = await _getAllTests();
    try {
      return tests.firstWhere((t) => t.id == testId);
    } catch (e) {
      return null;
    }
  }

  Future<List<ABTest>> _getAllTests() async {
    final testsJson = _prefs.getString(_testsKey) ?? '[]';
    try {
      final testsList = jsonDecode(testsJson) as List;
      return testsList
          .map((t) => ABTest.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load A/B tests: $e');
      return [];
    }
  }

  Future<ABTestVariant?> _getExistingVariant(
    String userId,
    String testId,
  ) async {
    final variantsJson = _prefs.getString(_userVariantsKey) ?? '{}';
    try {
      final variants = jsonDecode(variantsJson) as Map<String, dynamic>;
      final userVariants = variants[userId] as Map<String, dynamic>?;

      if (userVariants != null && userVariants.containsKey(testId)) {
        final variantData = userVariants[testId] as Map<String, dynamic>;
        return ABTestVariant.fromJson(variantData);
      }
    } catch (e) {
      debugPrint('Failed to load user variants: $e');
    }

    return null;
  }

  Future<void> _saveUserVariant(
    String userId,
    String testId,
    ABTestVariant variant,
  ) async {
    final variantsJson = _prefs.getString(_userVariantsKey) ?? '{}';
    final variants = jsonDecode(variantsJson) as Map<String, dynamic>;

    final userVariants =
        variants[userId] as Map<String, dynamic>? ?? <String, dynamic>{};
    userVariants[testId] = variant.toJson();
    variants[userId] = userVariants;

    await _prefs.setString(_userVariantsKey, jsonEncode(variants));
  }

  Future<void> _saveTestResult(ABTestResult result) async {
    final resultsKey = 'ab_test_results_${result.testId}';
    final resultsJson = _prefs.getString(resultsKey) ?? '[]';

    final results = jsonDecode(resultsJson) as List;
    results.add(result.toJson());

    await _prefs.setString(resultsKey, jsonEncode(results));
  }

  Future<List<ABTestResult>> _getTestResults(String testId) async {
    final resultsKey = 'ab_test_results_$testId';
    final resultsJson = _prefs.getString(resultsKey) ?? '[]';

    try {
      final resultsList = jsonDecode(resultsJson) as List;
      return resultsList
          .map((r) => ABTestResult.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to load test results: $e');
      return [];
    }
  }

  String _generateTestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
  }
}

// A/Bテスト関連のデータクラス
class ABTest {
  final String id;
  final String name;
  final NotificationCategory category;
  final List<ABTestVariant> variants;
  final DateTime startDate;
  final DateTime endDate;
  final double trafficAllocation;
  final ABTestStatus status;
  final DateTime createdAt;

  const ABTest({
    required this.id,
    required this.name,
    required this.category,
    required this.variants,
    required this.startDate,
    required this.endDate,
    required this.trafficAllocation,
    required this.status,
    required this.createdAt,
  });

  ABTest copyWith({
    String? id,
    String? name,
    NotificationCategory? category,
    List<ABTestVariant>? variants,
    DateTime? startDate,
    DateTime? endDate,
    double? trafficAllocation,
    ABTestStatus? status,
    DateTime? createdAt,
  }) => ABTest(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    variants: variants ?? this.variants,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    trafficAllocation: trafficAllocation ?? this.trafficAllocation,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.id,
    'variants': variants.map((v) => v.toJson()).toList(),
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'trafficAllocation': trafficAllocation,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ABTest.fromJson(Map<String, dynamic> json) => ABTest(
    id: json['id'] as String,
    name: json['name'] as String,
    category: NotificationCategory.values.firstWhere(
      (c) => c.id == json['category'],
    ),
    variants:
        (json['variants'] as List)
            .map((v) => ABTestVariant.fromJson(v))
            .toList(),
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    trafficAllocation: (json['trafficAllocation'] as num).toDouble(),
    status: ABTestStatus.values.firstWhere((s) => s.name == json['status']),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class ABTestVariant {
  final String name;
  final String title;
  final String body;
  final double weight;
  final Map<String, dynamic>? parameters;

  const ABTestVariant({
    required this.name,
    required this.title,
    required this.body,
    required this.weight,
    this.parameters,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'title': title,
    'body': body,
    'weight': weight,
    'parameters': parameters,
  };

  factory ABTestVariant.fromJson(Map<String, dynamic> json) => ABTestVariant(
    name: json['name'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    weight: (json['weight'] as num).toDouble(),
    parameters: json['parameters'] as Map<String, dynamic>?,
  );
}

enum ABTestStatus { active, stopped, completed }

enum ABTestEvent { impression, click, conversion, dismissal }

class ABTestResult {
  final String testId;
  final String userId;
  final String variantName;
  final ABTestEvent event;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ABTestResult({
    required this.testId,
    required this.userId,
    required this.variantName,
    required this.event,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'testId': testId,
    'userId': userId,
    'variantName': variantName,
    'event': event.name,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory ABTestResult.fromJson(Map<String, dynamic> json) => ABTestResult(
    testId: json['testId'] as String,
    userId: json['userId'] as String,
    variantName: json['variantName'] as String,
    event: ABTestEvent.values.firstWhere((e) => e.name == json['event']),
    timestamp: DateTime.parse(json['timestamp'] as String),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
}

class ABTestVariantStats {
  final String variantName;
  final int impressions;
  final int conversions;
  final double conversionRate;

  const ABTestVariantStats({
    required this.variantName,
    required this.impressions,
    required this.conversions,
    required this.conversionRate,
  });
}

class ABTestAnalysis {
  final String testId;
  final String testName;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, ABTestVariantStats> variantStats;
  final double statisticalSignificance;
  final String? winner;
  final double confidence;
  final DateTime analyzedAt;

  const ABTestAnalysis({
    required this.testId,
    required this.testName,
    required this.startDate,
    required this.endDate,
    required this.variantStats,
    required this.statisticalSignificance,
    this.winner,
    required this.confidence,
    required this.analyzedAt,
  });
}
