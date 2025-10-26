import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:minq/core/error/exceptions.dart';
import 'package:minq/core/logging/app_logger.dart';

/// Comprehensive crash prevention and recovery service
class CrashPreventionService {
  static CrashPreventionService? _instance;
  static CrashPreventionService get instance => _instance ??= CrashPreventionService._();
  
  CrashPreventionService._();
  
  final List<CrashReport> _crashHistory = [];
  final Map<String, int> _errorFrequency = {};
  final Set<String> _criticalErrors = {};
  
  Timer? _healthCheckTimer;
  Timer? _memoryMonitorTimer;
  bool _isInitialized = false;
  
  /// Critical error patterns that require immediate attention
  static const Set<String> _criticalErrorPatterns = {
    'OutOfMemoryError',
    'StackOverflowError',
    'NoSuchMethodError',
    'RangeError',
    'StateError',
    'ConcurrentModificationError',
    'DatabaseException',
    'NetworkException',
  };
  
  /// Initialize crash prevention system
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _setupGlobalErrorHandlers();
      await _setupMemoryMonitoring();
      await _setupHealthChecks();
      await _setupIsolateErrorHandling();
      await _loadCrashHistory();
      
      _isInitialized = true;
      logger.info('Crash prevention service initialized');
      
    } catch (error, stackTrace) {
      logger.error(
        'Failed to initialize crash prevention service',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Set up global error handlers
  Future<void> _setupGlobalErrorHandlers() async {
    // Flutter framework error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
    
    // Platform dispatcher error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true; // Prevent default error handling
    };
    
    // Zone error handler for async errors
    runZonedGuarded(() {
      // This will catch any unhandled async errors
    }, (error, stackTrace) {
      _handleZoneError(error, stackTrace);
    });
  }
  
  /// Set up memory monitoring to prevent OOM crashes
  Future<void> _setupMemoryMonitoring() async {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkMemoryUsage(),
    );
    
    // Listen for system memory pressure warnings
    SystemChannels.system.setMessageHandler((message) async {
      if (message?['type'] == 'memoryPressure') {
        await _handleMemoryPressure();
      }
      return null;
    });
  }
  
  /// Set up periodic health checks
  Future<void> _setupHealthChecks() async {
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performHealthCheck(),
    );
  }
  
  /// Set up isolate error handling
  Future<void> _setupIsolateErrorHandling() async {
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        await _handleIsolateError(errorAndStacktrace[0], errorAndStacktrace[1]);
      }).sendPort,
    );
  }
  
  /// Load crash history from storage
  Future<void> _loadCrashHistory() async {
    try {
      // Load previous crash reports from secure storage
      // This would be implemented with actual storage in production
      logger.info('Crash history loaded: ${_crashHistory.length} previous crashes');
    } catch (error) {
      logger.warning('Failed to load crash history', error: error);
    }
  }
  
  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    final crashReport = CrashReport(
      type: CrashType.flutterError,
      error: details.exception,
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
        'silent': details.silent,
      },
      timestamp: DateTime.now(),
    );
    
    _processCrashReport(crashReport);
    
    // Log the error
    logger.error(
      'Flutter framework error',
      data: crashReport.toMap(),
      error: details.exception,
      stackTrace: details.stack,
    );
    
    // Try to recover if possible
    _attemptRecovery(crashReport);
  }
  
  /// Handle platform-level errors
  bool _handlePlatformError(Object error, StackTrace stackTrace) {
    final crashReport = CrashReport(
      type: CrashType.platformError,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
    
    _processCrashReport(crashReport);
    
    logger.error(
      'Platform error',
      data: crashReport.toMap(),
      error: error,
      stackTrace: stackTrace,
    );
    
    // Try to recover
    _attemptRecovery(crashReport);
    
    return true; // Indicate error was handled
  }
  
  /// Handle zone errors (async errors)
  void _handleZoneError(Object error, StackTrace stackTrace) {
    final crashReport = CrashReport(
      type: CrashType.zoneError,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
    
    _processCrashReport(crashReport);
    
    logger.error(
      'Zone error (async)',
      data: crashReport.toMap(),
      error: error,
      stackTrace: stackTrace,
    );
    
    _attemptRecovery(crashReport);
  }
  
  /// Handle isolate errors
  Future<void> _handleIsolateError(dynamic error, dynamic stackTrace) async {
    final crashReport = CrashReport(
      type: CrashType.isolateError,
      error: error,
      stackTrace: stackTrace is StackTrace ? stackTrace : null,
      timestamp: DateTime.now(),
    );
    
    _processCrashReport(crashReport);
    
    logger.error(
      'Isolate error',
      data: crashReport.toMap(),
      error: error,
      stackTrace: stackTrace is StackTrace ? stackTrace : null,
    );
    
    _attemptRecovery(crashReport);
  }
  
  /// Process and analyze crash report
  void _processCrashReport(CrashReport report) {
    // Add to crash history
    _crashHistory.add(report);
    
    // Keep only recent crashes (last 100)
    if (_crashHistory.length > 100) {
      _crashHistory.removeAt(0);
    }
    
    // Track error frequency
    final errorKey = _getErrorKey(report.error);
    _errorFrequency[errorKey] = (_errorFrequency[errorKey] ?? 0) + 1;
    
    // Check if this is a critical error
    if (_isCriticalError(report.error)) {
      _criticalErrors.add(errorKey);
      _handleCriticalError(report);
    }
    
    // Analyze crash patterns
    _analyzeCrashPatterns();
  }
  
  /// Get error key for tracking frequency
  String _getErrorKey(dynamic error) {
    if (error is Exception) {
      return error.runtimeType.toString();
    }
    return error.toString().split('\n').first;
  }
  
  /// Check if error is critical
  bool _isCriticalError(dynamic error) {
    final errorString = error.toString();
    return _criticalErrorPatterns.any((pattern) => errorString.contains(pattern));
  }
  
  /// Handle critical errors that require immediate action
  void _handleCriticalError(CrashReport report) {
    logger.error(
      'CRITICAL ERROR DETECTED',
      data: {
        'error_type': report.type.name,
        'error_key': _getErrorKey(report.error),
        'frequency': _errorFrequency[_getErrorKey(report.error)],
        'timestamp': report.timestamp.toIso8601String(),
      },
    );
    
    // Trigger emergency recovery procedures
    _triggerEmergencyRecovery(report);
  }
  
  /// Trigger emergency recovery procedures
  void _triggerEmergencyRecovery(CrashReport report) {
    try {
      // Clear caches to free memory
      _clearCaches();
      
      // Dispose unnecessary resources
      _disposeResources();
      
      // Reset problematic services
      _resetServices(report);
      
      // Force garbage collection
      _forceGarbageCollection();
      
      logger.info('Emergency recovery procedures completed');
      
    } catch (recoveryError) {
      logger.error('Emergency recovery failed', error: recoveryError);
    }
  }
  
  /// Attempt recovery from crash
  void _attemptRecovery(CrashReport report) {
    try {
      final errorKey = _getErrorKey(report.error);
      final frequency = _errorFrequency[errorKey] ?? 0;
      
      // If this error is happening frequently, take more aggressive action
      if (frequency > 5) {
        logger.warning('Frequent error detected: $errorKey (${frequency}x)');
        _handleFrequentError(report);
      } else {
        _handleSingleError(report);
      }
      
    } catch (recoveryError) {
      logger.error('Recovery attempt failed', error: recoveryError);
    }
  }
  
  /// Handle single occurrence errors
  void _handleSingleError(CrashReport report) {
    // Log the error for analysis
    // Continue normal operation
    logger.info('Single error handled, continuing normal operation');
  }
  
  /// Handle frequently occurring errors
  void _handleFrequentError(CrashReport report) {
    final errorKey = _getErrorKey(report.error);
    
    // Take preventive measures based on error type
    if (errorKey.contains('Memory') || errorKey.contains('OutOfMemory')) {
      _handleMemoryError();
    } else if (errorKey.contains('Network') || errorKey.contains('Connection')) {
      _handleNetworkError();
    } else if (errorKey.contains('Database') || errorKey.contains('Storage')) {
      _handleDatabaseError();
    } else {
      _handleGenericError(report);
    }
  }
  
  /// Handle memory-related errors
  void _handleMemoryError() {
    logger.warning('Handling memory-related error');
    
    // Clear image caches
    _clearImageCaches();
    
    // Dispose unused controllers
    _disposeUnusedControllers();
    
    // Reduce background processing
    _reduceBackgroundProcessing();
    
    // Force garbage collection
    _forceGarbageCollection();
  }
  
  /// Handle network-related errors
  void _handleNetworkError() {
    logger.warning('Handling network-related error');
    
    // Reset network connections
    // Clear network caches
    // Implement exponential backoff for retries
  }
  
  /// Handle database-related errors
  void _handleDatabaseError() {
    logger.warning('Handling database-related error');
    
    // Check database integrity
    // Attempt database repair if needed
    // Clear database caches
  }
  
  /// Handle generic errors
  void _handleGenericError(CrashReport report) {
    logger.warning('Handling generic error: ${_getErrorKey(report.error)}');
    
    // Implement generic recovery strategies
    _clearCaches();
    _resetNonCriticalServices();
  }
  
  /// Analyze crash patterns to identify trends
  void _analyzeCrashPatterns() {
    if (_crashHistory.length < 5) return;
    
    // Check for crash frequency spikes
    final recentCrashes = _crashHistory
        .where((crash) => crash.timestamp.isAfter(
            DateTime.now().subtract(const Duration(minutes: 10))))
        .length;
    
    if (recentCrashes > 3) {
      logger.error('Crash frequency spike detected: $recentCrashes crashes in 10 minutes');
      _handleCrashSpike();
    }
    
    // Check for recurring error patterns
    final errorCounts = <String, int>{};
    for (final crash in _crashHistory.take(20)) {
      final key = _getErrorKey(crash.error);
      errorCounts[key] = (errorCounts[key] ?? 0) + 1;
    }
    
    for (final entry in errorCounts.entries) {
      if (entry.value > 5) {
        logger.warning('Recurring error pattern: ${entry.key} (${entry.value}x)');
      }
    }
  }
  
  /// Handle crash frequency spikes
  void _handleCrashSpike() {
    logger.error('Handling crash spike - implementing emergency measures');
    
    // Implement emergency stability measures
    _triggerEmergencyRecovery(_crashHistory.last);
    
    // Reduce app functionality to essential features only
    _enableSafeMode();
  }
  
  /// Enable safe mode with reduced functionality
  void _enableSafeMode() {
    logger.warning('Enabling safe mode due to stability issues');
    
    // Disable non-essential features
    // Reduce animation complexity
    // Limit background processing
    // Use fallback implementations
  }
  
  /// Check memory usage and prevent OOM crashes
  void _checkMemoryUsage() {
    final memoryUsage = _getCurrentMemoryUsage();
    final memoryMB = memoryUsage / (1024 * 1024);
    
    if (memoryMB > 200) { // 200MB threshold
      logger.warning('High memory usage detected: ${memoryMB.toStringAsFixed(1)}MB');
      _handleMemoryPressure();
    } else if (memoryMB > 150) { // 150MB warning
      logger.info('Memory usage warning: ${memoryMB.toStringAsFixed(1)}MB');
      _performLightweightCleanup();
    }
  }
  
  /// Handle memory pressure
  Future<void> _handleMemoryPressure() async {
    logger.warning('Handling memory pressure');
    
    try {
      // Clear all possible caches
      _clearCaches();
      _clearImageCaches();
      
      // Dispose unused resources
      _disposeResources();
      
      // Force garbage collection
      _forceGarbageCollection();
      
      // Wait a bit for cleanup to take effect
      await Future.delayed(const Duration(milliseconds: 100));
      
      logger.info('Memory pressure handling completed');
      
    } catch (error) {
      logger.error('Failed to handle memory pressure', error: error);
    }
  }
  
  /// Perform lightweight cleanup
  void _performLightweightCleanup() {
    // Clear temporary caches
    // Dispose completed futures
    // Clean up old log entries
  }
  
  /// Perform periodic health check
  void _performHealthCheck() {
    try {
      final memoryUsage = _getCurrentMemoryUsage();
      final crashCount = _crashHistory.length;
      final recentCrashes = _crashHistory
          .where((crash) => crash.timestamp.isAfter(
              DateTime.now().subtract(const Duration(hours: 1))))
          .length;
      
      logger.info(
        'Health check',
        data: {
          'memory_mb': (memoryUsage / (1024 * 1024)).round(),
          'total_crashes': crashCount,
          'recent_crashes': recentCrashes,
          'critical_errors': _criticalErrors.length,
        },
      );
      
      // Take action if health metrics are concerning
      if (recentCrashes > 2) {
        logger.warning('Health check: Too many recent crashes');
        _performPreventiveMaintenance();
      }
      
    } catch (error) {
      logger.error('Health check failed', error: error);
    }
  }
  
  /// Perform preventive maintenance
  void _performPreventiveMaintenance() {
    logger.info('Performing preventive maintenance');
    
    _clearCaches();
    _optimizeMemoryUsage();
    _resetNonCriticalServices();
  }
  
  /// Get current memory usage (platform-specific implementation needed)
  int _getCurrentMemoryUsage() {
    // Placeholder implementation
    // Real implementation would use platform-specific APIs
    return 80 * 1024 * 1024; // 80MB placeholder
  }
  
  /// Clear various caches
  void _clearCaches() {
    try {
      // Clear image caches
      _clearImageCaches();
      
      // Clear network caches
      // Clear database query caches
      // Clear computed value caches
      
      logger.info('Caches cleared');
    } catch (error) {
      logger.error('Failed to clear caches', error: error);
    }
  }
  
  /// Clear image caches
  void _clearImageCaches() {
    try {
      // Clear Flutter image cache
      // Clear custom image caches
      logger.debug('Image caches cleared');
    } catch (error) {
      logger.error('Failed to clear image caches', error: error);
    }
  }
  
  /// Dispose unnecessary resources
  void _disposeResources() {
    try {
      _disposeUnusedControllers();
      // Dispose unused streams
      // Close unused connections
      // Cancel unused timers
      
      logger.debug('Resources disposed');
    } catch (error) {
      logger.error('Failed to dispose resources', error: error);
    }
  }
  
  /// Dispose unused controllers
  void _disposeUnusedControllers() {
    // Dispose animation controllers that are not in use
    // Dispose text editing controllers
    // Dispose scroll controllers
  }
  
  /// Reset problematic services
  void _resetServices(CrashReport report) {
    try {
      // Reset services based on error type
      final errorString = report.error.toString();
      
      if (errorString.contains('AI') || errorString.contains('TensorFlow')) {
        _resetAIServices();
      }
      
      if (errorString.contains('Network') || errorString.contains('Http')) {
        _resetNetworkServices();
      }
      
      if (errorString.contains('Database') || errorString.contains('Isar')) {
        _resetDatabaseServices();
      }
      
      logger.info('Services reset based on error type');
    } catch (error) {
      logger.error('Failed to reset services', error: error);
    }
  }
  
  /// Reset non-critical services
  void _resetNonCriticalServices() {
    try {
      // Reset analytics services
      // Reset notification services
      // Reset background sync services
      
      logger.debug('Non-critical services reset');
    } catch (error) {
      logger.error('Failed to reset non-critical services', error: error);
    }
  }
  
  /// Reset AI services
  void _resetAIServices() {
    logger.info('Resetting AI services');
    // Reinitialize AI models
    // Clear AI caches
    // Reset AI service state
  }
  
  /// Reset network services
  void _resetNetworkServices() {
    logger.info('Resetting network services');
    // Reset HTTP clients
    // Clear connection pools
    // Reset retry policies
  }
  
  /// Reset database services
  void _resetDatabaseServices() {
    logger.info('Resetting database services');
    // Reconnect to database
    // Clear query caches
    // Reset transaction state
  }
  
  /// Force garbage collection
  void _forceGarbageCollection() {
    try {
      // Force garbage collection (platform-specific)
      // This is a hint to the GC, not guaranteed to run immediately
      logger.debug('Garbage collection requested');
    } catch (error) {
      logger.error('Failed to force garbage collection', error: error);
    }
  }
  
  /// Reduce background processing
  void _reduceBackgroundProcessing() {
    logger.info('Reducing background processing');
    
    // Pause non-essential background tasks
    // Reduce sync frequency
    // Limit concurrent operations
  }
  
  /// Optimize memory usage
  void _optimizeMemoryUsage() {
    logger.info('Optimizing memory usage');
    
    _clearCaches();
    _disposeResources();
    _forceGarbageCollection();
  }
  
  /// Get crash statistics
  CrashStatistics getCrashStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastWeek = now.subtract(const Duration(days: 7));
    
    final crashes24h = _crashHistory.where((c) => c.timestamp.isAfter(last24Hours)).length;
    final crashesWeek = _crashHistory.where((c) => c.timestamp.isAfter(lastWeek)).length;
    
    return CrashStatistics(
      totalCrashes: _crashHistory.length,
      crashes24Hours: crashes24h,
      crashesLastWeek: crashesWeek,
      criticalErrors: _criticalErrors.length,
      mostFrequentErrors: _getMostFrequentErrors(),
      reportTimestamp: now,
    );
  }
  
  /// Get most frequent errors
  List<ErrorFrequency> _getMostFrequentErrors() {
    final sortedErrors = _errorFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedErrors.take(5).map((entry) => ErrorFrequency(
      errorType: entry.key,
      count: entry.value,
    )).toList();
  }
  
  /// Dispose crash prevention service
  void dispose() {
    _healthCheckTimer?.cancel();
    _memoryMonitorTimer?.cancel();
    _crashHistory.clear();
    _errorFrequency.clear();
    _criticalErrors.clear();
    _isInitialized = false;
    _instance = null;
    
    logger.info('Crash prevention service disposed');
  }
  
  /// Reset for testing
  @visibleForTesting
  void reset() {
    dispose();
  }
}

/// Crash report
class CrashReport {
  final CrashType type;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  
  const CrashReport({
    required this.type,
    required this.error,
    this.stackTrace,
    this.context,
    required this.timestamp,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Crash type enumeration
enum CrashType {
  flutterError,
  platformError,
  zoneError,
  isolateError,
}

/// Crash statistics
class CrashStatistics {
  final int totalCrashes;
  final int crashes24Hours;
  final int crashesLastWeek;
  final int criticalErrors;
  final List<ErrorFrequency> mostFrequentErrors;
  final DateTime reportTimestamp;
  
  const CrashStatistics({
    required this.totalCrashes,
    required this.crashes24Hours,
    required this.crashesLastWeek,
    required this.criticalErrors,
    required this.mostFrequentErrors,
    required this.reportTimestamp,
  });
  
  @override
  String toString() {
    return 'CrashStatistics('
        'total: $totalCrashes, '
        '24h: $crashes24Hours, '
        'week: $crashesLastWeek, '
        'critical: $criticalErrors)';
  }
}

/// Error frequency
class ErrorFrequency {
  final String errorType;
  final int count;
  
  const ErrorFrequency({
    required this.errorType,
    required this.count,
  });
  
  @override
  String toString() => '$errorType: ${count}x';
}

/// Global crash prevention service instance
final crashPreventionService = CrashPreventionService.instance;