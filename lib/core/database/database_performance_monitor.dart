import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Database performance monitoring and optimization
class DatabasePerformanceMonitor {
  static DatabasePerformanceMonitor? _instance;
  static DatabasePerformanceMonitor get instance =>
      _instance ??= DatabasePerformanceMonitor._();

  DatabasePerformanceMonitor._();

  final Map<String, List<Duration>> _operationTimes = {};
  final Map<String, int> _operationCounts = {};
  final List<PerformanceAlert> _alerts = [];
  Timer? _monitoringTimer;

  /// Performance thresholds
  static const Duration _slowOperationThreshold = Duration(milliseconds: 500);
  static const Duration _verySlowOperationThreshold = Duration(seconds: 2);
  static const int _maxOperationHistory = 100;

  /// Start performance monitoring
  void startMonitoring() {
    if (_monitoringTimer != null) return;

    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _analyzePerformance(),
    );

    developer.log('Database performance monitoring started');
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    developer.log('Database performance monitoring stopped');
  }

  /// Record operation timing
  void recordOperation(String operationType, Duration duration) {
    if (!_operationTimes.containsKey(operationType)) {
      _operationTimes[operationType] = [];
      _operationCounts[operationType] = 0;
    }

    final times = _operationTimes[operationType]!;
    times.add(duration);
    _operationCounts[operationType] = _operationCounts[operationType]! + 1;

    // Keep only recent operations
    if (times.length > _maxOperationHistory) {
      times.removeAt(0);
    }

    // Check for immediate performance issues
    _checkOperationPerformance(operationType, duration);
  }

  /// Check individual operation performance
  void _checkOperationPerformance(String operationType, Duration duration) {
    if (duration > _verySlowOperationThreshold) {
      _addAlert(
        PerformanceAlert(
          type: AlertType.verySlowOperation,
          message:
              '$operationType took ${duration.inMilliseconds}ms (very slow)',
          operationType: operationType,
          duration: duration,
          timestamp: DateTime.now(),
        ),
      );
    } else if (duration > _slowOperationThreshold) {
      _addAlert(
        PerformanceAlert(
          type: AlertType.slowOperation,
          message: '$operationType took ${duration.inMilliseconds}ms (slow)',
          operationType: operationType,
          duration: duration,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Analyze overall performance trends
  void _analyzePerformance() {
    for (final entry in _operationTimes.entries) {
      final operationType = entry.key;
      final times = entry.value;

      if (times.isEmpty) continue;

      final stats = _calculateStatistics(times);

      // Check for performance degradation
      if (stats.averageDuration > _slowOperationThreshold) {
        _addAlert(
          PerformanceAlert(
            type: AlertType.performanceDegradation,
            message:
                '$operationType average time: ${stats.averageDuration.inMilliseconds}ms',
            operationType: operationType,
            duration: stats.averageDuration,
            timestamp: DateTime.now(),
          ),
        );
      }

      // Check for high operation frequency
      final count = _operationCounts[operationType] ?? 0;
      if (count > 1000) {
        // More than 1000 operations in monitoring period
        _addAlert(
          PerformanceAlert(
            type: AlertType.highFrequency,
            message: '$operationType executed $count times',
            operationType: operationType,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    // Clean up old alerts
    _cleanupAlerts();
  }

  /// Calculate operation statistics
  PerformanceStatistics _calculateStatistics(List<Duration> times) {
    if (times.isEmpty) {
      return const PerformanceStatistics(
        averageDuration: Duration.zero,
        minDuration: Duration.zero,
        maxDuration: Duration.zero,
        p95Duration: Duration.zero,
      );
    }

    final sortedTimes = List<Duration>.from(times)..sort();

    final totalMs = times.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    final averageMs = totalMs / times.length;

    final p95Index = (times.length * 0.95).floor();
    final p95Duration = sortedTimes[p95Index.clamp(0, sortedTimes.length - 1)];

    return PerformanceStatistics(
      averageDuration: Duration(milliseconds: averageMs.round()),
      minDuration: sortedTimes.first,
      maxDuration: sortedTimes.last,
      p95Duration: p95Duration,
    );
  }

  /// Add performance alert
  void _addAlert(PerformanceAlert alert) {
    _alerts.add(alert);

    // Log alert in debug mode
    if (kDebugMode) {
      developer.log('Performance Alert: ${alert.message}');
    }

    // Keep only recent alerts
    if (_alerts.length > 100) {
      _alerts.removeAt(0);
    }
  }

  /// Clean up old alerts
  void _cleanupAlerts() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _alerts.removeWhere((alert) => alert.timestamp.isBefore(cutoff));
  }

  /// Get performance report
  PerformanceReport getPerformanceReport() {
    final operationStats = <String, PerformanceStatistics>{};

    for (final entry in _operationTimes.entries) {
      operationStats[entry.key] = _calculateStatistics(entry.value);
    }

    return PerformanceReport(
      operationStatistics: operationStats,
      operationCounts: Map.from(_operationCounts),
      recentAlerts: List.from(_alerts),
      reportTimestamp: DateTime.now(),
    );
  }

  /// Get recent alerts
  List<PerformanceAlert> getRecentAlerts({Duration? since}) {
    if (since == null) return List.from(_alerts);

    final cutoff = DateTime.now().subtract(since);
    return _alerts.where((alert) => alert.timestamp.isAfter(cutoff)).toList();
  }

  /// Clear all monitoring data
  void clearData() {
    _operationTimes.clear();
    _operationCounts.clear();
    _alerts.clear();
    developer.log('Performance monitoring data cleared');
  }

  /// Dispose monitoring resources
  void dispose() {
    stopMonitoring();
    clearData();
    _instance = null;
  }
}

/// Performance statistics for an operation type
class PerformanceStatistics {
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration p95Duration;

  const PerformanceStatistics({
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.p95Duration,
  });

  @override
  String toString() {
    return 'PerformanceStatistics('
        'avg: ${averageDuration.inMilliseconds}ms, '
        'min: ${minDuration.inMilliseconds}ms, '
        'max: ${maxDuration.inMilliseconds}ms, '
        'p95: ${p95Duration.inMilliseconds}ms)';
  }
}

/// Performance alert
class PerformanceAlert {
  final AlertType type;
  final String message;
  final String? operationType;
  final Duration? duration;
  final DateTime timestamp;

  const PerformanceAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    this.operationType,
    this.duration,
  });

  @override
  String toString() {
    return 'PerformanceAlert(${type.name}: $message at $timestamp)';
  }
}

/// Alert types
enum AlertType {
  slowOperation,
  verySlowOperation,
  performanceDegradation,
  highFrequency,
  memoryLeak,
}

/// Performance report
class PerformanceReport {
  final Map<String, PerformanceStatistics> operationStatistics;
  final Map<String, int> operationCounts;
  final List<PerformanceAlert> recentAlerts;
  final DateTime reportTimestamp;

  const PerformanceReport({
    required this.operationStatistics,
    required this.operationCounts,
    required this.recentAlerts,
    required this.reportTimestamp,
  });

  /// Get summary of performance issues
  String getSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Performance Report - $reportTimestamp');
    buffer.writeln('');

    // Operation statistics
    buffer.writeln('Operation Statistics:');
    for (final entry in operationStatistics.entries) {
      final op = entry.key;
      final stats = entry.value;
      final count = operationCounts[op] ?? 0;

      buffer.writeln(
        '  $op: $count operations, ${stats.averageDuration.inMilliseconds}ms avg',
      );
    }

    // Recent alerts
    if (recentAlerts.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Recent Alerts:');
      for (final alert in recentAlerts.take(10)) {
        buffer.writeln('  ${alert.type.name}: ${alert.message}');
      }
    }

    return buffer.toString();
  }
}

/// Mixin for adding performance monitoring to database operations
mixin DatabasePerformanceTracking {
  /// Execute operation with performance tracking
  Future<T> trackOperation<T>(
    String operationType,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      DatabasePerformanceMonitor.instance.recordOperation(
        operationType,
        stopwatch.elapsed,
      );

      return result;
    } catch (error) {
      stopwatch.stop();

      // Record failed operations too
      DatabasePerformanceMonitor.instance.recordOperation(
        '${operationType}_failed',
        stopwatch.elapsed,
      );

      rethrow;
    }
  }

  /// Execute synchronous operation with performance tracking
  T trackSyncOperation<T>(String operationType, T Function() operation) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      DatabasePerformanceMonitor.instance.recordOperation(
        operationType,
        stopwatch.elapsed,
      );

      return result;
    } catch (error) {
      stopwatch.stop();

      DatabasePerformanceMonitor.instance.recordOperation(
        '${operationType}_failed',
        stopwatch.elapsed,
      );

      rethrow;
    }
  }
}
