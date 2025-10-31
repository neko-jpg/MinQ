import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:minq/core/analytics/analytics_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';

/// Comprehensive user behavior analytics service
class UserBehaviorAnalytics {
  static final UserBehaviorAnalytics _instance = UserBehaviorAnalytics._internal();
  factory UserBehaviorAnalytics() => _instance;
  UserBehaviorAnalytics._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final LocalStorageService _storage = LocalStorageService();
  
  // Session tracking
  DateTime? _sessionStart;
  String? _currentSessionId;
  final List<UserAction> _sessionActions = [];
  
  // Screen tracking
  String? _currentScreen;
  DateTime? _screenStartTime;
  final Map<String, ScreenMetrics> _screenMetrics = {};
  
  // Feature usage tracking
  final Map<String, FeatureUsage> _featureUsage = {};
  
  // User journey tracking
  final List<String> _userJourney = [];
  final Map<String, UserFlow> _userFlows = {};
  
  // Engagement tracking
  int _totalSessions = 0;
  Duration _totalSessionTime = Duration.zero;
  DateTime? _lastActiveTime;
  
  // Funnel tracking
  final Map<String, FunnelStep> _activeFunnels = {};

  /// Initialize user behavior analytics
  Future<void> initialize() async {
    await _loadStoredData();
    _startNewSession();
    
    debugPrint('UserBehaviorAnalytics initialized');
  }

  /// Start a new user session
  void _startNewSession() {
    _sessionStart = DateTime.now();
    _currentSessionId = _generateSessionId();
    _sessionActions.clear();
    _totalSessions++;
    
    _trackEvent('session_start', {
      'session_id': _currentSessionId,
      'session_number': _totalSessions,
    });
  }

  /// End current session
  Future<void> endSession() async {
    if (_sessionStart == null || _currentSessionId == null) return;
    
    final sessionDuration = DateTime.now().difference(_sessionStart!);
    _totalSessionTime += sessionDuration;
    
    final sessionData = {
      'session_id': _currentSessionId,
      'duration_seconds': sessionDuration.inSeconds,
      'actions_count': _sessionActions.length,
      'screens_visited': _screenMetrics.keys.length,
      'features_used': _featureUsage.keys.length,
    };
    
    await _trackEvent('session_end', sessionData);
    await _storage.storeSessionData(_currentSessionId!, sessionData);
    
    _sessionStart = null;
    _currentSessionId = null;
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    // End previous screen tracking
    if (_currentScreen != null && _screenStartTime != null) {
      await _endScreenTracking();
    }
    
    // Start new screen tracking
    _currentScreen = screenName;
    _screenStartTime = DateTime.now();
    
    // Add to user journey
    _userJourney.add(screenName);
    if (_userJourney.length > 50) {
      _userJourney.removeAt(0);
    }
    
    await _trackEvent('screen_view', {
      'screen_name': screenName,
      'parameters': parameters ?? {},
      'session_id': _currentSessionId,
    });
  }

  /// Track user action
  Future<void> trackUserAction(String action, {
    Map<String, dynamic>? properties,
    String? category,
  }) async {
    final userAction = UserAction(
      action: action,
      timestamp: DateTime.now(),
      properties: properties ?? {},
      category: category,
      screenName: _currentScreen,
      sessionId: _currentSessionId,
    );
    
    _sessionActions.add(userAction);
    _lastActiveTime = DateTime.now();
    
    // Track feature usage
    if (category != null) {
      _trackFeatureUsage(category, action);
    }
    
    await _trackEvent('user_action', {
      'action': action,
      'category': category,
      'properties': properties,
      'screen_name': _currentScreen,
      'session_id': _currentSessionId,
    });
  }

  /// Track feature usage
  void _trackFeatureUsage(String feature, String action) {
    final usage = _featureUsage.putIfAbsent(feature, () => FeatureUsage(
      featureName: feature,
      firstUsed: DateTime.now(),
      totalUsage: 0,
      lastUsed: DateTime.now(),
    ));
    
    usage.totalUsage++;
    usage.lastUsed = DateTime.now();
    
    // Track specific actions within feature
    usage.actions.putIfAbsent(action, () => 0);
    usage.actions[action] = usage.actions[action]! + 1;
  }

  /// Track conversion funnel step
  Future<void> trackFunnelStep(String funnelName, String stepName, {
    Map<String, dynamic>? properties,
  }) async {
    final funnel = _activeFunnels.putIfAbsent(funnelName, () => FunnelStep(
      funnelName: funnelName,
      steps: [],
      startTime: DateTime.now(),
    ));
    
    funnel.steps.add(FunnelStepData(
      stepName: stepName,
      timestamp: DateTime.now(),
      properties: properties ?? {},
    ));
    
    await _trackEvent('funnel_step', {
      'funnel_name': funnelName,
      'step_name': stepName,
      'step_number': funnel.steps.length,
      'properties': properties,
      'session_id': _currentSessionId,
    });
  }

  /// Complete conversion funnel
  Future<void> completeFunnel(String funnelName, {
    Map<String, dynamic>? properties,
  }) async {
    final funnel = _activeFunnels.remove(funnelName);
    if (funnel == null) return;
    
    final completionTime = DateTime.now();
    final totalDuration = completionTime.difference(funnel.startTime);
    
    await _trackEvent('funnel_completed', {
      'funnel_name': funnelName,
      'total_steps': funnel.steps.length,
      'duration_seconds': totalDuration.inSeconds,
      'properties': properties,
      'session_id': _currentSessionId,
    });
  }

  /// Track user engagement
  Future<void> trackEngagement(String engagementType, double value, {
    Map<String, dynamic>? context,
  }) async {
    await _trackEvent('user_engagement', {
      'engagement_type': engagementType,
      'value': value,
      'context': context,
      'session_id': _currentSessionId,
    });
  }

  /// Track error or issue
  Future<void> trackUserIssue(String issueType, String description, {
    Map<String, dynamic>? context,
  }) async {
    await _trackEvent('user_issue', {
      'issue_type': issueType,
      'description': description,
      'context': context,
      'screen_name': _currentScreen,
      'session_id': _currentSessionId,
    });
  }

  /// Get user behavior insights
  Future<UserBehaviorInsights> getUserBehaviorInsights() async {
    final sessionData = await _storage.getSessionData();
    
    // Calculate engagement metrics
    final avgSessionDuration = _totalSessions > 0 
        ? _totalSessionTime.inSeconds / _totalSessions 
        : 0.0;
    
    // Most used features
    final sortedFeatures = _featureUsage.values.toList()
      ..sort((a, b) => b.totalUsage.compareTo(a.totalUsage));
    
    // Most visited screens
    final sortedScreens = _screenMetrics.values.toList()
      ..sort((a, b) => b.totalVisits.compareTo(a.totalVisits));
    
    // User journey patterns
    final journeyPatterns = _analyzeUserJourneyPatterns();
    
    // Engagement score
    final engagementScore = _calculateEngagementScore();
    
    return UserBehaviorInsights(
      totalSessions: _totalSessions,
      averageSessionDuration: avgSessionDuration,
      totalActions: _sessionActions.length,
      mostUsedFeatures: sortedFeatures.take(10).toList(),
      mostVisitedScreens: sortedScreens.take(10).toList(),
      journeyPatterns: journeyPatterns,
      engagementScore: engagementScore,
      lastActiveTime: _lastActiveTime,
    );
  }

  /// Get feature adoption metrics
  Map<String, FeatureAdoption> getFeatureAdoption() {
    final adoption = <String, FeatureAdoption>{};
    
    for (final feature in _featureUsage.values) {
      final daysSinceFirstUse = DateTime.now().difference(feature.firstUsed).inDays;
      final usageFrequency = daysSinceFirstUse > 0 
          ? feature.totalUsage / daysSinceFirstUse 
          : feature.totalUsage.toDouble();
      
      adoption[feature.featureName] = FeatureAdoption(
        featureName: feature.featureName,
        adoptionDate: feature.firstUsed,
        usageFrequency: usageFrequency,
        totalUsage: feature.totalUsage,
        lastUsed: feature.lastUsed,
      );
    }
    
    return adoption;
  }

  /// Get user flow analysis
  List<UserFlowStep> getUserFlowAnalysis(String flowName) {
    final flow = _userFlows[flowName];
    if (flow == null) return [];
    
    return flow.steps;
  }

  /// Analyze user retention
  Future<RetentionAnalysis> analyzeRetention() async {
    final sessionData = await _storage.getSessionData();
    
    // Group sessions by day
    final sessionsByDay = <String, int>{};
    for (final session in sessionData) {
      final date = DateTime.parse(session['timestamp']).toIso8601String().split('T')[0];
      sessionsByDay[date] = (sessionsByDay[date] ?? 0) + 1;
    }
    
    // Calculate retention metrics
    final totalDays = sessionsByDay.length;
    final activeDays = sessionsByDay.values.where((count) => count > 0).length;
    final retentionRate = totalDays > 0 ? activeDays / totalDays : 0.0;
    
    return RetentionAnalysis(
      totalDays: totalDays,
      activeDays: activeDays,
      retentionRate: retentionRate,
      sessionsByDay: sessionsByDay,
    );
  }

  /// End screen tracking
  Future<void> _endScreenTracking() async {
    if (_currentScreen == null || _screenStartTime == null) return;
    
    final duration = DateTime.now().difference(_screenStartTime!);
    
    final metrics = _screenMetrics.putIfAbsent(_currentScreen!, () => ScreenMetrics(
      screenName: _currentScreen!,
      totalVisits: 0,
      totalTime: Duration.zero,
      averageTime: Duration.zero,
    ));
    
    metrics.totalVisits++;
    metrics.totalTime += duration;
    metrics.averageTime = Duration(
      milliseconds: metrics.totalTime.inMilliseconds ~/ metrics.totalVisits,
    );
    
    await _trackEvent('screen_exit', {
      'screen_name': _currentScreen,
      'duration_seconds': duration.inSeconds,
      'session_id': _currentSessionId,
    });
  }

  /// Analyze user journey patterns
  List<JourneyPattern> _analyzeUserJourneyPatterns() {
    final patterns = <String, int>{};
    
    // Look for common 3-step patterns
    for (int i = 0; i < _userJourney.length - 2; i++) {
      final pattern = '${_userJourney[i]} -> ${_userJourney[i + 1]} -> ${_userJourney[i + 2]}';
      patterns[pattern] = (patterns[pattern] ?? 0) + 1;
    }
    
    // Sort by frequency
    final sortedPatterns = patterns.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedPatterns.take(10).map((entry) => JourneyPattern(
      pattern: entry.key,
      frequency: entry.value,
    )).toList();
  }

  /// Calculate engagement score
  double _calculateEngagementScore() {
    if (_totalSessions == 0) return 0.0;
    
    final avgSessionDuration = _totalSessionTime.inMinutes / _totalSessions;
    final actionsPerSession = _sessionActions.length / _totalSessions;
    final featuresUsed = _featureUsage.length;
    
    // Weighted engagement score (0-100)
    final durationScore = (avgSessionDuration / 30).clamp(0.0, 1.0) * 40; // Max 40 points
    final actionScore = (actionsPerSession / 20).clamp(0.0, 1.0) * 30; // Max 30 points
    final featureScore = (featuresUsed / 10).clamp(0.0, 1.0) * 30; // Max 30 points
    
    return durationScore + actionScore + featureScore;
  }

  /// Track event to analytics
  Future<void> _trackEvent(String eventName, Map<String, dynamic> properties) async {
    await _analytics.trackEvent(eventName, properties);
  }

  /// Load stored analytics data
  Future<void> _loadStoredData() async {
    final data = await _storage.getAnalyticsData();
    if (data != null) {
      _totalSessions = data['total_sessions'] ?? 0;
      _totalSessionTime = Duration(seconds: data['total_session_time'] ?? 0);
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '${timestamp}_$random';
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await endSession();
    await _storage.storeAnalyticsData({
      'total_sessions': _totalSessions,
      'total_session_time': _totalSessionTime.inSeconds,
    });
  }
}

/// User action data model
class UserAction {
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final String? category;
  final String? screenName;
  final String? sessionId;

  UserAction({
    required this.action,
    required this.timestamp,
    required this.properties,
    this.category,
    this.screenName,
    this.sessionId,
  });
}

/// Screen metrics data model
class ScreenMetrics {
  final String screenName;
  int totalVisits;
  Duration totalTime;
  Duration averageTime;

  ScreenMetrics({
    required this.screenName,
    required this.totalVisits,
    required this.totalTime,
    required this.averageTime,
  });
}

/// Feature usage data model
class FeatureUsage {
  final String featureName;
  final DateTime firstUsed;
  int totalUsage;
  DateTime lastUsed;
  final Map<String, int> actions = {};

  FeatureUsage({
    required this.featureName,
    required this.firstUsed,
    required this.totalUsage,
    required this.lastUsed,
  });
}

/// Funnel tracking data model
class FunnelStep {
  final String funnelName;
  final List<FunnelStepData> steps;
  final DateTime startTime;

  FunnelStep({
    required this.funnelName,
    required this.steps,
    required this.startTime,
  });
}

class FunnelStepData {
  final String stepName;
  final DateTime timestamp;
  final Map<String, dynamic> properties;

  FunnelStepData({
    required this.stepName,
    required this.timestamp,
    required this.properties,
  });
}

/// User flow data model
class UserFlow {
  final String flowName;
  final List<UserFlowStep> steps;

  UserFlow({
    required this.flowName,
    required this.steps,
  });
}

class UserFlowStep {
  final String stepName;
  final int userCount;
  final double conversionRate;

  UserFlowStep({
    required this.stepName,
    required this.userCount,
    required this.conversionRate,
  });
}

/// User behavior insights summary
class UserBehaviorInsights {
  final int totalSessions;
  final double averageSessionDuration;
  final int totalActions;
  final List<FeatureUsage> mostUsedFeatures;
  final List<ScreenMetrics> mostVisitedScreens;
  final List<JourneyPattern> journeyPatterns;
  final double engagementScore;
  final DateTime? lastActiveTime;

  UserBehaviorInsights({
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.totalActions,
    required this.mostUsedFeatures,
    required this.mostVisitedScreens,
    required this.journeyPatterns,
    required this.engagementScore,
    this.lastActiveTime,
  });
}

/// Feature adoption metrics
class FeatureAdoption {
  final String featureName;
  final DateTime adoptionDate;
  final double usageFrequency;
  final int totalUsage;
  final DateTime lastUsed;

  FeatureAdoption({
    required this.featureName,
    required this.adoptionDate,
    required this.usageFrequency,
    required this.totalUsage,
    required this.lastUsed,
  });
}

/// Journey pattern analysis
class JourneyPattern {
  final String pattern;
  final int frequency;

  JourneyPattern({
    required this.pattern,
    required this.frequency,
  });
}

/// Retention analysis results
class RetentionAnalysis {
  final int totalDays;
  final int activeDays;
  final double retentionRate;
  final Map<String, int> sessionsByDay;

  RetentionAnalysis({
    required this.totalDays,
    required this.activeDays,
    required this.retentionRate,
    required this.sessionsByDay,
  });
}