import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:minq/core/analytics/analytics_service.dart';
import 'package:minq/core/network/network_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';

/// Comprehensive A/B testing framework
class ABTestingService {
  static final ABTestingService _instance = ABTestingService._internal();
  factory ABTestingService() => _instance;
  ABTestingService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final LocalStorageService _storage = LocalStorageService();
  final NetworkService _network = NetworkService();

  // Test management
  final Map<String, ABTest> _activeTests = {};
  final Map<String, String> _userAssignments = {};
  final Map<String, ABTestResult> _testResults = {};

  // User segmentation
  String? _userId;
  Map<String, dynamic> _userAttributes = {};

  // Configuration
  bool _isEnabled = true;
  Timer? _syncTimer;

  /// Initialize A/B testing service
  Future<void> initialize({String? userId}) async {
    _userId = userId;

    // Load stored assignments and results
    await _loadStoredData();

    // Fetch active tests from server
    await _fetchActiveTests();

    // Start periodic sync
    _startPeriodicSync();

    debugPrint('ABTestingService initialized');
  }

  /// Set user attributes for segmentation
  void setUserAttributes(Map<String, dynamic> attributes) {
    _userAttributes = Map<String, dynamic>.from(attributes);
  }

  /// Get variant for a test
  String getVariant(String testName, {String defaultVariant = 'control'}) {
    if (!_isEnabled) return defaultVariant;

    // Check if user is already assigned
    if (_userAssignments.containsKey(testName)) {
      return _userAssignments[testName]!;
    }

    // Get test configuration
    final test = _activeTests[testName];
    if (test == null || !test.isActive) {
      return defaultVariant;
    }

    // Check if user meets targeting criteria
    if (!_meetsTargetingCriteria(test)) {
      return defaultVariant;
    }

    // Assign user to variant
    final variant = _assignUserToVariant(test);
    _userAssignments[testName] = variant;

    // Track assignment
    _trackAssignment(testName, variant);

    // Store assignment
    _storeAssignment(testName, variant);

    return variant;
  }

  /// Check if user is in test variant
  bool isInVariant(String testName, String variantName) {
    return getVariant(testName) == variantName;
  }

  /// Track conversion event for A/B test
  Future<void> trackConversion(
    String testName,
    String eventName, {
    double? value,
    Map<String, dynamic>? properties,
  }) async {
    final variant = _userAssignments[testName];
    if (variant == null) return;

    final conversion = ABConversion(
      testName: testName,
      variant: variant,
      eventName: eventName,
      value: value,
      properties: properties ?? {},
      timestamp: DateTime.now(),
      userId: _userId,
    );

    // Store conversion
    await _storage.storeABConversion(conversion);

    // Track in analytics
    await _analytics.trackEvent('ab_conversion', {
      'test_name': testName,
      'variant': variant,
      'event_name': eventName,
      'value': value,
      'properties': properties,
      'user_id': _userId,
    });

    debugPrint('AB conversion tracked: $testName/$variant -> $eventName');
  }

  /// Track custom metric for A/B test
  Future<void> trackMetric(
    String testName,
    String metricName,
    double value, {
    Map<String, dynamic>? properties,
  }) async {
    final variant = _userAssignments[testName];
    if (variant == null) return;

    await _analytics.trackEvent('ab_metric', {
      'test_name': testName,
      'variant': variant,
      'metric_name': metricName,
      'value': value,
      'properties': properties,
      'user_id': _userId,
    });
  }

  /// Get test results and statistics
  Future<ABTestResult?> getTestResults(String testName) async {
    if (_testResults.containsKey(testName)) {
      return _testResults[testName];
    }

    // Fetch results from server
    try {
      final response = await _network.get('/api/ab-tests/$testName/results');
      final result = ABTestResult.fromJson(response);
      _testResults[testName] = result;
      return result;
    } catch (e) {
      debugPrint('Failed to fetch test results: $e');
      return null;
    }
  }

  /// Create a new A/B test (for admin/testing purposes)
  Future<void> createTest(ABTest test) async {
    _activeTests[test.name] = test;

    try {
      await _network.post('/api/ab-tests', test.toJson());
    } catch (e) {
      debugPrint('Failed to create test on server: $e');
    }
  }

  /// Force user into specific variant (for testing)
  void forceVariant(String testName, String variant) {
    _userAssignments[testName] = variant;
    _storeAssignment(testName, variant);

    _trackAssignment(testName, variant, forced: true);
  }

  /// Get all active test assignments for current user
  Map<String, String> getActiveAssignments() {
    return Map<String, String>.from(_userAssignments);
  }

  /// Get test configuration
  ABTest? getTestConfig(String testName) {
    return _activeTests[testName];
  }

  /// Enable/disable A/B testing
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Assign user to variant based on test configuration
  String _assignUserToVariant(ABTest test) {
    // Use consistent hashing for stable assignments
    final hash = _hashUserId(test.name);
    final bucket = hash % 100;

    double cumulativeWeight = 0;
    for (final variant in test.variants) {
      cumulativeWeight += variant.trafficAllocation;
      if (bucket < cumulativeWeight) {
        return variant.name;
      }
    }

    // Fallback to control
    return test.variants.first.name;
  }

  /// Check if user meets targeting criteria
  bool _meetsTargetingCriteria(ABTest test) {
    if (test.targeting == null) return true;

    final targeting = test.targeting!;

    // Check user attributes
    for (final condition in targeting.conditions) {
      if (!_evaluateCondition(condition)) {
        return false;
      }
    }

    // Check percentage rollout
    if (targeting.percentage < 100) {
      final hash = _hashUserId('${test.name}_rollout');
      if ((hash % 100) >= targeting.percentage) {
        return false;
      }
    }

    return true;
  }

  /// Evaluate targeting condition
  bool _evaluateCondition(TargetingCondition condition) {
    final userValue = _userAttributes[condition.attribute];
    if (userValue == null) return false;

    switch (condition.operator) {
      case 'equals':
        return userValue == condition.value;
      case 'not_equals':
        return userValue != condition.value;
      case 'contains':
        return userValue.toString().contains(condition.value.toString());
      case 'greater_than':
        return (userValue as num) > (condition.value as num);
      case 'less_than':
        return (userValue as num) < (condition.value as num);
      case 'in':
        return (condition.value as List).contains(userValue);
      case 'not_in':
        return !(condition.value as List).contains(userValue);
      default:
        return false;
    }
  }

  /// Generate consistent hash for user ID
  int _hashUserId(String salt) {
    if (_userId == null) return Random().nextInt(100);

    final combined = '$_userId$salt';
    var hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = ((hash << 5) - hash + combined.codeUnitAt(i)) & 0xffffffff;
    }
    return hash.abs();
  }

  /// Track test assignment
  void _trackAssignment(
    String testName,
    String variant, {
    bool forced = false,
  }) {
    _analytics.trackEvent('ab_assignment', {
      'test_name': testName,
      'variant': variant,
      'user_id': _userId,
      'forced': forced,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Store assignment locally
  void _storeAssignment(String testName, String variant) {
    _storage.storeABAssignment(testName, variant);
  }

  /// Fetch active tests from server
  Future<void> _fetchActiveTests() async {
    try {
      final response = await _network.get('/api/ab-tests/active');
      final testsData = response['tests'] as List;

      for (final testData in testsData) {
        final test = ABTest.fromJson(testData);
        _activeTests[test.name] = test;
      }

      debugPrint('Fetched ${_activeTests.length} active A/B tests');
    } catch (e) {
      debugPrint('Failed to fetch active tests: $e');
    }
  }

  /// Load stored assignments and data
  Future<void> _loadStoredData() async {
    final assignments = await _storage.getABAssignments();
    _userAssignments.addAll(assignments);
  }

  /// Start periodic sync with server
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _fetchActiveTests();
    });
  }

  /// Cleanup resources
  void dispose() {
    _syncTimer?.cancel();
  }
}

/// A/B test configuration
class ABTest {
  final String name;
  final String description;
  final List<ABVariant> variants;
  final ABTargeting? targeting;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, dynamic> metadata;

  ABTest({
    required this.name,
    required this.description,
    required this.variants,
    this.targeting,
    required this.isActive,
    required this.startDate,
    this.endDate,
    this.metadata = const {},
  });

  factory ABTest.fromJson(Map<String, dynamic> json) {
    return ABTest(
      name: json['name'],
      description: json['description'],
      variants:
          (json['variants'] as List).map((v) => ABVariant.fromJson(v)).toList(),
      targeting:
          json['targeting'] != null
              ? ABTargeting.fromJson(json['targeting'])
              : null,
      isActive: json['is_active'],
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'variants': variants.map((v) => v.toJson()).toList(),
      'targeting': targeting?.toJson(),
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// A/B test variant
class ABVariant {
  final String name;
  final String description;
  final double trafficAllocation; // Percentage (0-100)
  final Map<String, dynamic> parameters;

  ABVariant({
    required this.name,
    required this.description,
    required this.trafficAllocation,
    this.parameters = const {},
  });

  factory ABVariant.fromJson(Map<String, dynamic> json) {
    return ABVariant(
      name: json['name'],
      description: json['description'],
      trafficAllocation: json['traffic_allocation'].toDouble(),
      parameters: json['parameters'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'traffic_allocation': trafficAllocation,
      'parameters': parameters,
    };
  }
}

/// A/B test targeting configuration
class ABTargeting {
  final List<TargetingCondition> conditions;
  final int percentage; // Rollout percentage (0-100)

  ABTargeting({required this.conditions, required this.percentage});

  factory ABTargeting.fromJson(Map<String, dynamic> json) {
    return ABTargeting(
      conditions:
          (json['conditions'] as List)
              .map((c) => TargetingCondition.fromJson(c))
              .toList(),
      percentage: json['percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'percentage': percentage,
    };
  }
}

/// Targeting condition
class TargetingCondition {
  final String attribute;
  final String operator;
  final dynamic value;

  TargetingCondition({
    required this.attribute,
    required this.operator,
    required this.value,
  });

  factory TargetingCondition.fromJson(Map<String, dynamic> json) {
    return TargetingCondition(
      attribute: json['attribute'],
      operator: json['operator'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'attribute': attribute, 'operator': operator, 'value': value};
  }
}

/// A/B test conversion event
class ABConversion {
  final String testName;
  final String variant;
  final String eventName;
  final double? value;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String? userId;

  ABConversion({
    required this.testName,
    required this.variant,
    required this.eventName,
    this.value,
    required this.properties,
    required this.timestamp,
    this.userId,
  });
}

/// A/B test results and statistics
class ABTestResult {
  final String testName;
  final Map<String, VariantResult> variantResults;
  final ABTestStatistics statistics;
  final bool isSignificant;
  final String? winningVariant;

  ABTestResult({
    required this.testName,
    required this.variantResults,
    required this.statistics,
    required this.isSignificant,
    this.winningVariant,
  });

  factory ABTestResult.fromJson(Map<String, dynamic> json) {
    final variantResults = <String, VariantResult>{};
    for (final entry in (json['variant_results'] as Map).entries) {
      variantResults[entry.key] = VariantResult.fromJson(entry.value);
    }

    return ABTestResult(
      testName: json['test_name'],
      variantResults: variantResults,
      statistics: ABTestStatistics.fromJson(json['statistics']),
      isSignificant: json['is_significant'],
      winningVariant: json['winning_variant'],
    );
  }
}

/// Variant performance results
class VariantResult {
  final String variantName;
  final int participants;
  final int conversions;
  final double conversionRate;
  final double? averageValue;
  final double confidenceInterval;

  VariantResult({
    required this.variantName,
    required this.participants,
    required this.conversions,
    required this.conversionRate,
    this.averageValue,
    required this.confidenceInterval,
  });

  factory VariantResult.fromJson(Map<String, dynamic> json) {
    return VariantResult(
      variantName: json['variant_name'],
      participants: json['participants'],
      conversions: json['conversions'],
      conversionRate: json['conversion_rate'].toDouble(),
      averageValue: json['average_value']?.toDouble(),
      confidenceInterval: json['confidence_interval'].toDouble(),
    );
  }
}

/// A/B test statistical analysis
class ABTestStatistics {
  final double pValue;
  final double confidenceLevel;
  final int totalParticipants;
  final int totalConversions;
  final String testDuration;

  ABTestStatistics({
    required this.pValue,
    required this.confidenceLevel,
    required this.totalParticipants,
    required this.totalConversions,
    required this.testDuration,
  });

  factory ABTestStatistics.fromJson(Map<String, dynamic> json) {
    return ABTestStatistics(
      pValue: json['p_value'].toDouble(),
      confidenceLevel: json['confidence_level'].toDouble(),
      totalParticipants: json['total_participants'],
      totalConversions: json['total_conversions'],
      testDuration: json['test_duration'],
    );
  }
}
