import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Comprehensive performance monitoring service
class PerformanceMonitoringService {
  static const Duration _monitoringInterval = Duration(seconds: 5);
  static const int _maxMetricsHistory = 1000;
  static const double _frameDropThreshold = 16.67; // 60 FPS threshold
  static const int _memoryWarningThreshold = 200 * 1024 * 1024; // 200MB
  
  Timer? _monitoringTimer;
  final List<PerformanceMetric> _metricsHistory = [];
  final Map<String, PerformanceTracker> _activeTrackers = {};
  final List<PerformanceCallback> _callbacks = [];
  
  bool _isMonitoring = false;
  DateTime? _appStartTime;
  int _frameCount = 0;
  double _totalFrameTime = 0;
  
  static final PerformanceMonitoringService _instance = PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal() {
    _appStartTime = DateTime.now();
  }
  
  /// Start performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _setupFrameCallbacks();
    _startPeriodicMonitoring();
    
    debugPrint('Performance monitoring started');
  }
  
  /// Stop performance monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    
    debugPrint('Performance monitoring stopped');
  }
  
  /// Register performance callback
  void registerCallback(PerformanceCallback callback) {
    _callbacks.add(callback);
  }
  
  /// Unregister performance callback
  void unregisterCallback(PerformanceCallback callback) {
    _callbacks.remove(callback);
  }
  
  /// Start tracking a specific operation
  PerformanceTracker startTracking(String operationName) {
    final tracker = PerformanceTracker(operationName);
    _activeTrackers[operationName] = tracker;
    return tracker;
  }
  
  /// Stop tracking an operation
  void stopTracking(String operationName) {
    final tracker = _activeTrackers.remove(operationName);
    if (tracker != null) {
      tracker.stop();
      _recordOperationMetric(tracker);
    }
  }
  
  /// Get current performance metrics
  PerformanceSnapshot getCurrentMetrics() {
    return PerformanceSnapshot(
      timestamp: DateTime.now(),
      memoryUsage: _getCurrentMemoryUsage(),
      cpuUsage: _getCurrentCPUUsage(),
      frameRate: _getCurrentFrameRate(),
      appStartupTime: _getAppStartupTime(),
      activeOperations: _activeTrackers.length,
      networkLatency: _getNetworkLatency(),
      diskIORate: _getDiskIORate(),
    );
  }
  
  /// Get performance history
  List<PerformanceMetric> getPerformanceHistory({
    Duration? timeRange,
    int? maxCount,
  }) {
    var history = _metricsHistory;
    
    if (timeRange != null) {
      final cutoff = DateTime.now().subtract(timeRange);
      history = history.where((m) => m.timestamp.isAfter(cutoff)).toList();
    }
    
    if (maxCount != null && history.length > maxCount) {
      history = history.takeLast(maxCount).toList();
    }
    
    return List.unmodifiable(history);
  }
  
  /// Get performance statistics
  PerformanceStatistics getPerformanceStatistics() {
    if (_metricsHistory.isEmpty) {
      return PerformanceStatistics.empty();
    }
    
    final metrics = _metricsHistory;
    
    return PerformanceStatistics(
      averageFrameRate: _calculateAverageFrameRate(metrics),
      averageMemoryUsage: _calculateAverageMemoryUsage(metrics),
      averageCPUUsage: _calculateAverageCPUUsage(metrics),
      frameDropCount: _calculateFrameDropCount(metrics),
      memoryLeaks: _detectMemoryLeaks(metrics),
      performanceIssues: _detectPerformanceIssues(metrics),
      recommendations: _generateRecommendations(metrics),
    );
  }
  
  /// Record custom performance event
  void recordEvent(String eventName, {
    Map<String, dynamic>? properties,
    Duration? duration,
  }) {
    final event = PerformanceEvent(
      name: eventName,
      timestamp: DateTime.now(),
      properties: properties ?? {},
      duration: duration,
    );
    
    _recordEvent(event);
  }
  
  /// Measure function execution time
  Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTracking(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      stopTracking(operationName);
    }
  }
  
  /// Measure synchronous function execution time
  T measure<T>(
    String operationName,
    T Function() operation,
  ) {
    startTracking(operationName);
    try {
      return operation();
    } finally {
      stopTracking(operationName);
    }
  }
  
  /// Generate performance report
  PerformanceReport generateReport({Duration? timeRange}) {
    final history = getPerformanceHistory(timeRange: timeRange);
    final statistics = getPerformanceStatistics();
    final currentMetrics = getCurrentMetrics();
    
    return PerformanceReport(
      generatedAt: DateTime.now(),
      timeRange: timeRange,
      currentMetrics: currentMetrics,
      statistics: statistics,
      history: history,
      recommendations: statistics.recommendations,
    );
  }
  
  // Private methods
  
  void _setupFrameCallbacks() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      if (!_isMonitoring) return;
      
      _frameCount++;
      final frameTime = timeStamp.inMicroseconds / 1000.0; // Convert to milliseconds
      _totalFrameTime += frameTime;
      
      // Check for frame drops
      if (frameTime > _frameDropThreshold) {
        _recordFrameDrop(frameTime);
      }
    });
  }
  
  void _startPeriodicMonitoring() {
    _monitoringTimer = Timer.periodic(_monitoringInterval, (_) {
      _collectMetrics();
    });
  }
  
  void _collectMetrics() {
    final metric = PerformanceMetric(
      timestamp: DateTime.now(),
      memoryUsage: _getCurrentMemoryUsage(),
      cpuUsage: _getCurrentCPUUsage(),
      frameRate: _getCurrentFrameRate(),
      networkLatency: _getNetworkLatency(),
      diskIORate: _getDiskIORate(),
      activeOperations: _activeTrackers.length,
    );
    
    _metricsHistory.add(metric);
    
    // Limit history size
    if (_metricsHistory.length > _maxMetricsHistory) {
      _metricsHistory.removeAt(0);
    }
    
    // Check for performance issues
    _checkPerformanceThresholds(metric);
    
    // Notify callbacks
    for (final callback in _callbacks) {
      callback(PerformanceEventType.metricsUpdated, metric);
    }
  }
  
  int _getCurrentMemoryUsage() {
    try {
      // This would use platform-specific memory monitoring
      return 50 * 1024 * 1024; // 50MB placeholder
    } catch (e) {
      return 0;
    }
  }
  
  double _getCurrentCPUUsage() {
    try {
      // This would use platform-specific CPU monitoring
      return 15.0; // 15% placeholder
    } catch (e) {
      return 0.0;
    }
  }
  
  double _getCurrentFrameRate() {
    if (_frameCount == 0) return 0.0;
    
    final averageFrameTime = _totalFrameTime / _frameCount;
    return 1000.0 / averageFrameTime; // Convert to FPS
  }
  
  Duration _getAppStartupTime() {
    if (_appStartTime == null) return Duration.zero;
    return DateTime.now().difference(_appStartTime!);
  }
  
  double _getNetworkLatency() {
    // This would measure actual network latency
    return 50.0; // 50ms placeholder
  }
  
  double _getDiskIORate() {
    // This would measure actual disk I/O
    return 1.5; // 1.5 MB/s placeholder
  }
  
  void _recordFrameDrop(double frameTime) {
    final event = PerformanceEvent(
      name: 'frame_drop',
      timestamp: DateTime.now(),
      properties: {'frameTime': frameTime},
    );
    
    _recordEvent(event);
  }
  
  void _recordOperationMetric(PerformanceTracker tracker) {
    final event = PerformanceEvent(
      name: 'operation_completed',
      timestamp: DateTime.now(),
      properties: {
        'operationName': tracker.operationName,
        'duration': tracker.duration.inMilliseconds,
      },
      duration: tracker.duration,
    );
    
    _recordEvent(event);
  }
  
  void _recordEvent(PerformanceEvent event) {
    // Store event for analysis
    debugPrint('Performance event: ${event.name} - ${event.duration?.inMilliseconds}ms');
  }
  
  void _checkPerformanceThresholds(PerformanceMetric metric) {
    // Check memory usage
    if (metric.memoryUsage > _memoryWarningThreshold) {
      for (final callback in _callbacks) {
        callback(PerformanceEventType.memoryWarning, metric);
      }
    }
    
    // Check frame rate
    if (metric.frameRate < 30) {
      for (final callback in _callbacks) {
        callback(PerformanceEventType.lowFrameRate, metric);
      }
    }
    
    // Check CPU usage
    if (metric.cpuUsage > 80) {
      for (final callback in _callbacks) {
        callback(PerformanceEventType.highCPUUsage, metric);
      }
    }
  }
  
  double _calculateAverageFrameRate(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    final total = metrics.map((m) => m.frameRate).reduce((a, b) => a + b);
    return total / metrics.length;
  }
  
  double _calculateAverageMemoryUsage(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    final total = metrics.map((m) => m.memoryUsage).reduce((a, b) => a + b);
    return total / metrics.length;
  }
  
  double _calculateAverageCPUUsage(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return 0.0;
    final total = metrics.map((m) => m.cpuUsage).reduce((a, b) => a + b);
    return total / metrics.length;
  }
  
  int _calculateFrameDropCount(List<PerformanceMetric> metrics) {
    return metrics.where((m) => m.frameRate < 30).length;
  }
  
  List<String> _detectMemoryLeaks(List<PerformanceMetric> metrics) {
    final leaks = <String>[];
    
    if (metrics.length < 10) return leaks;
    
    // Check for consistent memory growth
    final recent = metrics.takeLast(10).toList();
    bool consistentGrowth = true;
    
    for (int i = 1; i < recent.length; i++) {
      if (recent[i].memoryUsage <= recent[i - 1].memoryUsage) {
        consistentGrowth = false;
        break;
      }
    }
    
    if (consistentGrowth) {
      leaks.add('Potential memory leak detected - consistent memory growth');
    }
    
    return leaks;
  }
  
  List<String> _detectPerformanceIssues(List<PerformanceMetric> metrics) {
    final issues = <String>[];
    
    final avgFrameRate = _calculateAverageFrameRate(metrics);
    if (avgFrameRate < 30) {
      issues.add('Low frame rate detected - average ${avgFrameRate.toStringAsFixed(1)} FPS');
    }
    
    final avgMemory = _calculateAverageMemoryUsage(metrics);
    if (avgMemory > _memoryWarningThreshold) {
      issues.add('High memory usage - average ${(avgMemory / 1024 / 1024).toStringAsFixed(1)} MB');
    }
    
    return issues;
  }
  
  List<String> _generateRecommendations(List<PerformanceMetric> metrics) {
    final recommendations = <String>[];
    
    final avgFrameRate = _calculateAverageFrameRate(metrics);
    if (avgFrameRate < 30) {
      recommendations.add('Consider reducing animation complexity or enabling performance mode');
    }
    
    final avgMemory = _calculateAverageMemoryUsage(metrics);
    if (avgMemory > _memoryWarningThreshold) {
      recommendations.add('Consider clearing caches or reducing memory-intensive operations');
    }
    
    final frameDrops = _calculateFrameDropCount(metrics);
    if (frameDrops > metrics.length * 0.1) {
      recommendations.add('Frequent frame drops detected - optimize UI rendering');
    }
    
    return recommendations;
  }
}

// Data classes

class PerformanceMetric {
  final DateTime timestamp;
  final int memoryUsage;
  final double cpuUsage;
  final double frameRate;
  final double networkLatency;
  final double diskIORate;
  final int activeOperations;
  
  const PerformanceMetric({
    required this.timestamp,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.frameRate,
    required this.networkLatency,
    required this.diskIORate,
    required this.activeOperations,
  });
}

class PerformanceSnapshot {
  final DateTime timestamp;
  final int memoryUsage;
  final double cpuUsage;
  final double frameRate;
  final Duration appStartupTime;
  final int activeOperations;
  final double networkLatency;
  final double diskIORate;
  
  const PerformanceSnapshot({
    required this.timestamp,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.frameRate,
    required this.appStartupTime,
    required this.activeOperations,
    required this.networkLatency,
    required this.diskIORate,
  });
}

class PerformanceStatistics {
  final double averageFrameRate;
  final double averageMemoryUsage;
  final double averageCPUUsage;
  final int frameDropCount;
  final List<String> memoryLeaks;
  final List<String> performanceIssues;
  final List<String> recommendations;
  
  const PerformanceStatistics({
    required this.averageFrameRate,
    required this.averageMemoryUsage,
    required this.averageCPUUsage,
    required this.frameDropCount,
    required this.memoryLeaks,
    required this.performanceIssues,
    required this.recommendations,
  });
  
  factory PerformanceStatistics.empty() {
    return const PerformanceStatistics(
      averageFrameRate: 0.0,
      averageMemoryUsage: 0.0,
      averageCPUUsage: 0.0,
      frameDropCount: 0,
      memoryLeaks: [],
      performanceIssues: [],
      recommendations: ['Start monitoring to collect statistics'],
    );
  }
}

class PerformanceReport {
  final DateTime generatedAt;
  final Duration? timeRange;
  final PerformanceSnapshot currentMetrics;
  final PerformanceStatistics statistics;
  final List<PerformanceMetric> history;
  final List<String> recommendations;
  
  const PerformanceReport({
    required this.generatedAt,
    this.timeRange,
    required this.currentMetrics,
    required this.statistics,
    required this.history,
    required this.recommendations,
  });
}

class PerformanceTracker {
  final String operationName;
  final DateTime startTime;
  DateTime? endTime;
  
  PerformanceTracker(this.operationName) : startTime = DateTime.now();
  
  void stop() {
    endTime = DateTime.now();
  }
  
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  bool get isActive => endTime == null;
}

class PerformanceEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final Duration? duration;
  
  const PerformanceEvent({
    required this.name,
    required this.timestamp,
    required this.properties,
    this.duration,
  });
}

enum PerformanceEventType {
  metricsUpdated,
  memoryWarning,
  lowFrameRate,
  highCPUUsage,
  operationCompleted,
}

typedef PerformanceCallback = void Function(PerformanceEventType type, dynamic data);

extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}