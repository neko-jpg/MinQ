import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:minq/core/analytics/analytics_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';

/// Comprehensive performance monitoring service
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance = PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final LocalStorageService _storage = LocalStorageService();
  
  // Performance tracking
  final Map<String, PerformanceTrace> _activeTraces = {};
  final Queue<PerformanceMetric> _metrics = Queue<PerformanceMetric>();
  final Map<String, List<double>> _metricHistory = {};
  
  // Frame monitoring
  int _totalFrames = 0;
  int _droppedFrames = 0;
  Duration _totalFrameTime = Duration.zero;
  
  // Memory monitoring
  Timer? _memoryTimer;
  final List<MemorySnapshot> _memorySnapshots = [];
  
  // Network monitoring
  final Map<String, NetworkTrace> _networkTraces = {};
  
  // App lifecycle monitoring
  DateTime? _appStartTime;
  DateTime? _lastResumeTime;
  final Duration _totalBackgroundTime = Duration.zero;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    _appStartTime = DateTime.now();
    
    // Start frame monitoring
    _startFrameMonitoring();
    
    // Start memory monitoring
    _startMemoryMonitoring();
    
    // Monitor app lifecycle
    _monitorAppLifecycle();
    
    debugPrint('PerformanceMonitoringService initialized');
  }

  /// Start a performance trace
  PerformanceTrace startTrace(String name, {Map<String, dynamic>? attributes}) {
    final trace = PerformanceTrace(
      name: name,
      startTime: DateTime.now(),
      attributes: attributes ?? {},
    );
    
    _activeTraces[name] = trace;
    return trace;
  }

  /// Stop a performance trace
  Future<void> stopTrace(String name, {Map<String, dynamic>? additionalAttributes}) async {
    final trace = _activeTraces.remove(name);
    if (trace == null) return;

    trace.endTime = DateTime.now();
    trace.duration = trace.endTime!.difference(trace.startTime);
    
    if (additionalAttributes != null) {
      trace.attributes.addAll(additionalAttributes);
    }

    // Record the trace
    await _recordTrace(trace);
  }

  /// Record a custom metric
  Future<void> recordMetric(String name, double value, {
    Map<String, dynamic>? attributes,
  }) async {
    final metric = PerformanceMetric(
      name: name,
      value: value,
      timestamp: DateTime.now(),
      attributes: attributes ?? {},
    );

    _metrics.add(metric);
    
    // Keep history for trend analysis
    _metricHistory.putIfAbsent(name, () => []).add(value);
    if (_metricHistory[name]!.length > 100) {
      _metricHistory[name]!.removeAt(0);
    }

    // Store metric
    await _storage.storePerformanceMetric(metric);
    
    // Send to analytics if significant
    if (_isSignificantMetric(name, value)) {
      await _analytics.trackEvent('performance_metric', {
        'metric_name': name,
        'value': value,
        'attributes': attributes,
      });
    }
  }

  /// Start network request monitoring
  NetworkTrace startNetworkTrace(String url, String method) {
    final trace = NetworkTrace(
      url: url,
      method: method,
      startTime: DateTime.now(),
    );
    
    final key = '${method}_${url}_${DateTime.now().millisecondsSinceEpoch}';
    _networkTraces[key] = trace;
    
    return trace;
  }

  /// Stop network request monitoring
  Future<void> stopNetworkTrace(NetworkTrace trace, {
    int? statusCode,
    int? responseSize,
    String? errorMessage,
  }) async {
    trace.endTime = DateTime.now();
    trace.duration = trace.endTime!.difference(trace.startTime);
    trace.statusCode = statusCode;
    trace.responseSize = responseSize;
    trace.errorMessage = errorMessage;

    // Record network performance
    await _recordNetworkTrace(trace);
    
    // Remove from active traces
    _networkTraces.removeWhere((key, value) => value == trace);
  }

  /// Monitor screen rendering performance
  Future<void> monitorScreenPerformance(String screenName) async {
    final trace = startTrace('screen_render_$screenName');
    
    // Monitor first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      stopTrace('screen_render_$screenName', {
        'screen_name': screenName,
        'first_frame': true,
      });
    });
  }

  /// Monitor widget build performance
  T monitorWidgetBuild<T>(String widgetName, T Function() buildFunction) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = buildFunction();
      stopwatch.stop();
      
      recordMetric('widget_build_time', stopwatch.elapsedMicroseconds / 1000, attributes: {
        'widget_name': widgetName,
      });
      
      return result;
    } catch (e) {
      stopwatch.stop();
      recordMetric('widget_build_error', 1, attributes: {
        'widget_name': widgetName,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Monitor async operation performance
  Future<T> monitorAsyncOperation<T>(String operationName, Future<T> Function() operation) async {
    final trace = startTrace('async_$operationName');
    
    try {
      final result = await operation();
      await stopTrace('async_$operationName', {
        'operation_name': operationName,
        'success': true,
      });
      return result;
    } catch (e) {
      await stopTrace('async_$operationName', {
        'operation_name': operationName,
        'success': false,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get current performance statistics
  PerformanceStatistics getPerformanceStatistics() {
    final frameRate = _totalFrames > 0 
        ? 1000000 / (_totalFrameTime.inMicroseconds / _totalFrames)
        : 0.0;
    
    final frameDropRate = _totalFrames > 0 
        ? _droppedFrames / _totalFrames 
        : 0.0;

    final currentMemory = _memorySnapshots.isNotEmpty 
        ? _memorySnapshots.last.usedMemoryMB 
        : 0.0;

    final avgNetworkLatency = _calculateAverageNetworkLatency();

    return PerformanceStatistics(
      frameRate: frameRate,
      frameDropRate: frameDropRate,
      currentMemoryUsage: currentMemory,
      averageNetworkLatency: avgNetworkLatency,
      activeTraces: _activeTraces.length,
      totalMetrics: _metrics.length,
      appUptime: _getAppUptime(),
    );
  }

  /// Get performance trends
  Map<String, PerformanceTrend> getPerformanceTrends() {
    final trends = <String, PerformanceTrend>{};
    
    for (final entry in _metricHistory.entries) {
      final values = entry.value;
      if (values.length < 2) continue;
      
      final recent = values.sublist(values.length - 10);
      final older = values.sublist(0, values.length - 10);
      
      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.isNotEmpty 
          ? older.reduce((a, b) => a + b) / older.length 
          : recentAvg;
      
      final trend = recentAvg > olderAvg 
          ? TrendDirection.increasing 
          : recentAvg < olderAvg 
              ? TrendDirection.decreasing 
              : TrendDirection.stable;
      
      trends[entry.key] = PerformanceTrend(
        metricName: entry.key,
        direction: trend,
        changePercent: ((recentAvg - olderAvg) / olderAvg * 100).abs(),
        currentValue: recentAvg,
      );
    }
    
    return trends;
  }

  /// Get memory usage history
  List<MemorySnapshot> getMemoryHistory({int? limit}) {
    final snapshots = List<MemorySnapshot>.from(_memorySnapshots);
    if (limit != null && snapshots.length > limit) {
      return snapshots.sublist(snapshots.length - limit);
    }
    return snapshots;
  }

  /// Start frame monitoring
  void _startFrameMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _totalFrames++;
      
      final frameDuration = timeStamp;
      _totalFrameTime += frameDuration;
      
      // Check for dropped frames (>16.67ms for 60fps)
      if (frameDuration.inMicroseconds > 16670) {
        _droppedFrames++;
      }
      
      // Record frame metrics periodically
      if (_totalFrames % 60 == 0) {
        recordMetric('frame_rate', 60000000 / frameDuration.inMicroseconds);
        recordMetric('frame_drop_rate', _droppedFrames / _totalFrames);
      }
    });
  }

  /// Start memory monitoring
  void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final memoryUsage = await _getCurrentMemoryUsage();
      final snapshot = MemorySnapshot(
        timestamp: DateTime.now(),
        usedMemoryMB: memoryUsage,
      );
      
      _memorySnapshots.add(snapshot);
      
      // Keep only last 100 snapshots
      if (_memorySnapshots.length > 100) {
        _memorySnapshots.removeAt(0);
      }
      
      // Record memory metric
      await recordMetric('memory_usage', memoryUsage);
      
      // Check for memory leaks
      if (_memorySnapshots.length > 10) {
        final trend = _analyzeMemoryTrend();
        if (trend == MemoryTrend.increasing) {
          await _analytics.trackEvent('memory_leak_detected', {
            'current_usage': memoryUsage,
            'trend': 'increasing',
          });
        }
      }
    });
  }

  /// Monitor app lifecycle events
  void _monitorAppLifecycle() {
    // This would be integrated with app lifecycle callbacks
    _lastResumeTime = DateTime.now();
  }

  /// Record performance trace
  Future<void> _recordTrace(PerformanceTrace trace) async {
    await _storage.storePerformanceTrace(trace);
    
    // Send to analytics if trace is slow
    if (trace.duration.inMilliseconds > 1000) {
      await _analytics.trackEvent('slow_trace', {
        'trace_name': trace.name,
        'duration_ms': trace.duration.inMilliseconds,
        'attributes': trace.attributes,
      });
    }
  }

  /// Record network trace
  Future<void> _recordNetworkTrace(NetworkTrace trace) async {
    await _storage.storeNetworkTrace(trace);
    
    // Track network performance
    await recordMetric('network_latency', trace.duration.inMilliseconds.toDouble(), attributes: {
      'url': trace.url,
      'method': trace.method,
      'status_code': trace.statusCode,
    });
    
    // Track errors
    if (trace.statusCode != null && trace.statusCode! >= 400) {
      await _analytics.trackEvent('network_error', {
        'url': trace.url,
        'method': trace.method,
        'status_code': trace.statusCode,
        'error_message': trace.errorMessage,
      });
    }
  }

  /// Check if metric is significant enough to report
  bool _isSignificantMetric(String name, double value) {
    final history = _metricHistory[name];
    if (history == null || history.isEmpty) return true;
    
    final avg = history.reduce((a, b) => a + b) / history.length;
    final deviation = (value - avg).abs() / avg;
    
    // Report if deviation is more than 20%
    return deviation > 0.2;
  }

  /// Calculate average network latency
  double _calculateAverageNetworkLatency() {
    final completedTraces = _networkTraces.values
        .where((trace) => trace.endTime != null)
        .toList();
    
    if (completedTraces.isEmpty) return 0.0;
    
    final totalLatency = completedTraces
        .map((trace) => trace.duration.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return totalLatency / completedTraces.length;
  }

  /// Get app uptime
  Duration _getAppUptime() {
    if (_appStartTime == null) return Duration.zero;
    return DateTime.now().difference(_appStartTime!);
  }

  /// Get current memory usage
  Future<double> _getCurrentMemoryUsage() async {
    try {
      const platform = MethodChannel('minq/system_info');
      final result = await platform.invokeMethod('getMemoryUsage');
      return (result as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /// Analyze memory usage trend
  MemoryTrend _analyzeMemoryTrend() {
    if (_memorySnapshots.length < 5) return MemoryTrend.stable;
    
    final recent = _memorySnapshots.sublist(_memorySnapshots.length - 5);
    final older = _memorySnapshots.sublist(_memorySnapshots.length - 10, _memorySnapshots.length - 5);
    
    final recentAvg = recent.map((s) => s.usedMemoryMB).reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.map((s) => s.usedMemoryMB).reduce((a, b) => a + b) / older.length;
    
    final changePercent = (recentAvg - olderAvg) / olderAvg;
    
    if (changePercent > 0.1) return MemoryTrend.increasing;
    if (changePercent < -0.1) return MemoryTrend.decreasing;
    return MemoryTrend.stable;
  }

  /// Cleanup resources
  void dispose() {
    _memoryTimer?.cancel();
  }
}

/// Performance trace for measuring operation duration
class PerformanceTrace {
  final String name;
  final DateTime startTime;
  final Map<String, dynamic> attributes;
  
  DateTime? endTime;
  Duration duration = Duration.zero;

  PerformanceTrace({
    required this.name,
    required this.startTime,
    required this.attributes,
  });
}

/// Performance metric data point
class PerformanceMetric {
  final String name;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic> attributes;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    required this.attributes,
  });
}

/// Network request trace
class NetworkTrace {
  final String url;
  final String method;
  final DateTime startTime;
  
  DateTime? endTime;
  Duration duration = Duration.zero;
  int? statusCode;
  int? responseSize;
  String? errorMessage;

  NetworkTrace({
    required this.url,
    required this.method,
    required this.startTime,
  });
}

/// Memory usage snapshot
class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;

  MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
  });
}

/// Performance statistics summary
class PerformanceStatistics {
  final double frameRate;
  final double frameDropRate;
  final double currentMemoryUsage;
  final double averageNetworkLatency;
  final int activeTraces;
  final int totalMetrics;
  final Duration appUptime;

  PerformanceStatistics({
    required this.frameRate,
    required this.frameDropRate,
    required this.currentMemoryUsage,
    required this.averageNetworkLatency,
    required this.activeTraces,
    required this.totalMetrics,
    required this.appUptime,
  });
}

/// Performance trend analysis
class PerformanceTrend {
  final String metricName;
  final TrendDirection direction;
  final double changePercent;
  final double currentValue;

  PerformanceTrend({
    required this.metricName,
    required this.direction,
    required this.changePercent,
    required this.currentValue,
  });
}

enum TrendDirection { increasing, decreasing, stable }
enum MemoryTrend { increasing, decreasing, stable }