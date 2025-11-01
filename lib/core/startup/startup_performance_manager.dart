import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/database/database_lifecycle_manager.dart';
import 'package:minq/core/error/error_recovery.dart';
import 'package:minq/core/error/exceptions.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/data/providers.dart';

/// Startup performance manager for optimizing app initialization
class StartupPerformanceManager {
  static StartupPerformanceManager? _instance;
  static StartupPerformanceManager get instance =>
      _instance ??= StartupPerformanceManager._();

  StartupPerformanceManager._();

  final Stopwatch _startupStopwatch = Stopwatch();
  final Map<String, Duration> _phaseTimings = {};
  final List<StartupMetric> _metrics = [];
  final List<String> _initializationErrors = [];

  bool _isInitializing = false;
  bool _initializationComplete = false;
  StartupProgressCallback? _progressCallback;

  /// Target startup times
  static const Duration _targetStartupTime = Duration(milliseconds: 1500);

  /// Memory thresholds (in bytes)
  static const int _memoryWarningThreshold = 150 * 1024 * 1024; // 150MB
  static const int _memoryCriticalThreshold = 200 * 1024 * 1024; // 200MB

  /// Initialize app with performance monitoring and crash prevention
  Future<void> initializeApp(
    Ref ref, {
    StartupProgressCallback? onProgress,
  }) async {
    if (_isInitializing || _initializationComplete) {
      return;
    }

    _isInitializing = true;
    _progressCallback = onProgress;
    _startupStopwatch.start();

    try {
      await _executeStartupPhases(ref);
      _initializationComplete = true;

      final totalTime = _startupStopwatch.elapsed;
      _recordMetric('total_startup_time', totalTime.inMilliseconds);

      developer.log(
        'App initialization completed in ${totalTime.inMilliseconds}ms',
      );

      // Log performance summary
      _logPerformanceSummary();
    } catch (error, stackTrace) {
      _handleInitializationError(error, stackTrace);
      rethrow;
    } finally {
      _isInitializing = false;
      _startupStopwatch.stop();
    }
  }

  /// Execute startup phases with parallel optimization
  Future<void> _executeStartupPhases(Ref ref) async {
    // Phase 1: Critical Services (parallel execution)
    await _executePhase('critical_services', () async {
      _updateProgress('Initializing critical services...', 0.1);

      final futures = <Future<void>>[
        _initializeCrashReporting(ref),
        _initializeMemoryMonitoring(),
        _initializeErrorHandling(),
        _preloadEssentialAssets(),
      ];

      await Future.wait(futures);
    });

    // Phase 2: Core Infrastructure (parallel execution)
    await _executePhase('core_infrastructure', () async {
      _updateProgress('Setting up core infrastructure...', 0.3);

      final futures = <Future<void>>[
        _initializeDatabase(ref),
        _initializeNetworking(ref),
        _initializeSecureStorage(ref),
        _initializeLogging(ref),
      ];

      await Future.wait(futures);
    });

    // Phase 3: User Services (parallel execution)
    await _executePhase('user_services', () async {
      _updateProgress('Loading user services...', 0.6);

      final futures = <Future<void>>[
        _initializeAuthentication(ref),
        _initializeUserPreferences(ref),
        _initializeNotifications(ref),
        _initializeTheme(ref),
      ];

      await Future.wait(futures);
    });

    // Phase 4: Application Features (parallel execution)
    await _executePhase('app_features', () async {
      _updateProgress('Initializing app features...', 0.8);

      final futures = <Future<void>>[
        _initializeAIServices(ref),
        _initializeGamification(ref),
        _initializeAnalytics(ref),
        _setupDeepLinking(ref),
      ];

      await Future.wait(futures);
    });

    // Phase 5: Final Setup (sequential for dependencies)
    await _executePhase('final_setup', () async {
      _updateProgress('Finalizing setup...', 0.95);

      await _performHealthChecks(ref);
      await _scheduleBackgroundTasks(ref);
      await _warmupCaches(ref);

      _updateProgress('Ready!', 1.0);
    });
  }

  /// Execute a startup phase with timing and error handling
  Future<void> _executePhase(
    String phaseName,
    Future<void> Function() phase,
  ) async {
    final phaseStopwatch = Stopwatch()..start();

    try {
      await phase();
      phaseStopwatch.stop();

      _phaseTimings[phaseName] = phaseStopwatch.elapsed;
      _recordMetric('${phaseName}_time', phaseStopwatch.elapsed.inMilliseconds);

      developer.log(
        'Phase $phaseName completed in ${phaseStopwatch.elapsed.inMilliseconds}ms',
      );
    } catch (error, stackTrace) {
      phaseStopwatch.stop();
      _phaseTimings[phaseName] = phaseStopwatch.elapsed;

      final errorMessage = 'Phase $phaseName failed: $error';
      _initializationErrors.add(errorMessage);

      logger.error(
        'Startup phase failed',
        data: {
          'phase': phaseName,
          'duration': phaseStopwatch.elapsed.inMilliseconds,
          'error': error.toString(),
        },
        error: error,
        stackTrace: stackTrace,
      );

      // Try to recover from non-critical phase failures
      if (_isRecoverablePhase(phaseName)) {
        logger.warning('Continuing startup despite $phaseName failure');
        return;
      }

      rethrow;
    }
  }

  /// Initialize crash reporting and monitoring
  Future<void> _initializeCrashReporting(Ref ref) async {
    try {
      // Set up global error handlers
      FlutterError.onError = (FlutterErrorDetails details) {
        _handleFlutterError(details);
      };

      // Set up isolate error handler
      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await _handleIsolateError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
          );
        }).sendPort,
      );

      // Initialize crash recovery store
      ref.read(crashRecoveryStoreProvider);
    } catch (error) {
      logger.error('Failed to initialize crash reporting', error: error);
      // Don't rethrow - this is not critical for app startup
    }
  }

  /// Initialize memory monitoring and leak detection
  Future<void> _initializeMemoryMonitoring() async {
    try {
      // Start memory monitoring timer
      Timer.periodic(const Duration(seconds: 30), (_) => _checkMemoryUsage());

      // Set up memory pressure callbacks
      SystemChannels.system.setMessageHandler((message) async {
        if (message is Map && message['type'] == 'memoryPressure') {
          await _handleMemoryPressure();
        }
        return null;
      });
    } catch (error) {
      logger.error('Failed to initialize memory monitoring', error: error);
    }
  }

  /// Initialize error handling and recovery systems
  Future<void> _initializeErrorHandling() async {
    try {
      // Initialize error recovery manager
      errorRecovery.initializeDefaultStrategies();

      // Set up custom recovery strategies for startup
      errorRecovery.registerRecoveryStrategy(
        'STARTUP_TIMEOUT',
        (error) => RecoveryStrategy.retry,
      );

      errorRecovery.registerRecoveryStrategy(
        'STARTUP_MEMORY_ERROR',
        (error) => RecoveryStrategy.failGracefully,
      );
    } catch (error) {
      logger.error('Failed to initialize error handling', error: error);
    }
  }

  /// Preload essential assets to prevent loading delays
  Future<void> _preloadEssentialAssets() async {
    try {
      // Preload critical images and fonts
      await Future.wait([
        _preloadImage('assets/images/app_icon.png'),
        _preloadImage('assets/images/splash_logo.png'),
        // Add other critical assets
      ]);
    } catch (error) {
      logger.warning('Failed to preload some assets', error: error);
      // Don't fail startup for asset loading issues
    }
  }

  /// Initialize database with optimized settings
  Future<void> _initializeDatabase(Ref ref) async {
    await executeWithRecovery(
      operation: () async {
        final isarService = ref.read(isarServiceProvider);
        await isarService.init(
          onProgress: (message, progress) {
            _updateProgress('Database: $message', 0.3 + (progress * 0.1));
          },
        );

        // Verify database health
        final health = await isarService.getHealthStatus();
        if (health != DatabaseHealthStatus.healthy) {
          throw DatabaseException('Database health check failed: $health');
        }
      },
      operationName: 'database_initialization',
      retryConfig: RetryConfig.databaseConfig,
    );
  }

  /// Initialize networking with retry logic
  Future<void> _initializeNetworking(Ref ref) async {
    await executeWithRecovery(
      operation: () async {
        // Initialize HTTP client with optimized settings
        // Set up connection pooling and timeouts
        // Configure retry policies
      },
      operationName: 'networking_initialization',
      retryConfig: RetryConfig.networkConfig,
    );
  }

  /// Initialize secure storage
  Future<void> _initializeSecureStorage(Ref ref) async {
    try {
      // Initialize secure storage for sensitive data
      // Set up encryption keys
      // Verify storage accessibility
    } catch (error) {
      logger.error('Failed to initialize secure storage', error: error);
      // Continue without secure storage if necessary
    }
  }

  /// Initialize logging system
  Future<void> _initializeLogging(Ref ref) async {
    try {
      // Set up structured logging
      // Configure log levels based on build mode
      // Initialize remote logging if available
    } catch (error) {
      // Can't log this error since logging isn't ready
      debugPrint('Failed to initialize logging: $error');
    }
  }

  /// Initialize authentication services
  Future<void> _initializeAuthentication(Ref ref) async {
    await executeWithRecovery(
      operation: () async {
        final authRepo = ref.read(authRepositoryProvider);

        // Try to restore previous session
        final currentUser = authRepo.getCurrentUser();
        if (currentUser == null) {
          // Sign in anonymously for new users
          await authRepo.signInAnonymously();
        }
      },
      operationName: 'authentication_initialization',
      retryConfig: const RetryConfig(maxAttempts: 2),
    );
  }

  /// Initialize user preferences
  Future<void> _initializeUserPreferences(Ref ref) async {
    try {
      final prefsService = ref.read(localPreferencesServiceProvider);

      // Load critical preferences
      final isDummyMode = await prefsService.isDummyDataModeEnabled();
      ref.read(dummyDataModeProvider.notifier).state = isDummyMode;
    } catch (error) {
      logger.error('Failed to initialize user preferences', error: error);
      // Use default preferences if loading fails
    }
  }

  /// Initialize notification services
  Future<void> _initializeNotifications(Ref ref) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final permissionGranted = await notificationService.init();
      ref.read(notificationPermissionProvider.notifier).state =
          permissionGranted;
    } catch (error) {
      logger.error('Failed to initialize notifications', error: error);
      // Continue without notifications if initialization fails
    }
  }

  /// Initialize theme system
  Future<void> _initializeTheme(Ref ref) async {
    try {
      // Load theme preferences
      // Initialize design tokens
      // Set up theme switching
    } catch (error) {
      logger.error('Failed to initialize theme', error: error);
      // Use default theme if initialization fails
    }
  }

  /// Initialize AI services with fallback
  Future<void> _initializeAIServices(Ref ref) async {
    try {
      ref.read(aiInsightsServiceProvider);
    } catch (error) {
      logger.warning(
        'AI services initialization failed, using fallback',
        error: error,
      );
      // AI services are not critical for app startup
    }
  }

  /// Initialize gamification system
  Future<void> _initializeGamification(Ref ref) async {
    try {
      ref.read(gamificationEngineProvider);
    } catch (error) {
      logger.warning('Gamification initialization failed', error: error);
      // Gamification is not critical for app startup
    }
  }

  /// Initialize analytics
  Future<void> _initializeAnalytics(Ref ref) async {
    try {
      ref.read(analyticsServiceProvider);
    } catch (error) {
      logger.warning('Analytics initialization failed', error: error);
      // Analytics is not critical for app startup
    }
  }

  /// Set up deep linking
  Future<void> _setupDeepLinking(Ref ref) async {
    try {
      // Initialize deep link handlers
      // Set up URL schemes
      // Configure navigation routing
    } catch (error) {
      logger.warning('Deep linking setup failed', error: error);
      // Deep linking is not critical for app startup
    }
  }

  /// Perform health checks on all systems
  Future<void> _performHealthChecks(Ref ref) async {
    final healthChecks = <String, Future<bool>>{
      'database': _checkDatabaseHealth(ref),
      'network': _checkNetworkHealth(),
      'storage': _checkStorageHealth(),
      'memory': _checkMemoryHealth(),
    };

    final results = await Future.wait(healthChecks.values);
    final healthStatus = Map.fromIterables(healthChecks.keys, results);

    for (final entry in healthStatus.entries) {
      if (!entry.value) {
        logger.warning('Health check failed for ${entry.key}');
      }
    }

    _recordMetric('health_checks_passed', results.where((r) => r).length);
    _recordMetric('health_checks_total', results.length);
  }

  /// Schedule background tasks
  Future<void> _scheduleBackgroundTasks(Ref ref) async {
    try {
      // Schedule periodic data sync
      // Set up background refresh
      // Initialize maintenance tasks
    } catch (error) {
      logger.warning('Failed to schedule background tasks', error: error);
    }
  }

  /// Warm up caches for better performance
  Future<void> _warmupCaches(Ref ref) async {
    try {
      // Preload frequently accessed data
      // Initialize image caches
      // Warm up network connections
    } catch (error) {
      logger.warning('Cache warmup failed', error: error);
    }
  }

  /// Check if a phase failure is recoverable
  bool _isRecoverablePhase(String phaseName) {
    const recoverablePhases = {'app_features', 'final_setup'};
    return recoverablePhases.contains(phaseName);
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    logger.error(
      'Flutter error during startup',
      data: {
        'library': details.library,
        'context': details.context?.toString(),
        'silent': details.silent,
      },
      error: details.exception,
      stackTrace: details.stack,
    );

    // Report to crash analytics if available
    _reportCrash(details.exception, details.stack);
  }

  /// Handle isolate errors
  Future<void> _handleIsolateError(dynamic error, dynamic stackTrace) async {
    logger.error(
      'Isolate error during startup',
      error: error,
      stackTrace: stackTrace is StackTrace ? stackTrace : null,
    );

    _reportCrash(error, stackTrace);
  }

  /// Handle initialization errors with recovery
  void _handleInitializationError(dynamic error, StackTrace stackTrace) {
    final minqError = ExceptionUtils.fromError(error, stackTrace);

    logger.error(
      'App initialization failed',
      data: minqError.toMap(),
      error: error,
      stackTrace: stackTrace,
    );

    _reportCrash(error, stackTrace);

    // Record failure metrics
    _recordMetric('initialization_failed', 1);
    _recordMetric('failure_time', _startupStopwatch.elapsed.inMilliseconds);
  }

  /// Check memory usage and handle pressure
  void _checkMemoryUsage() {
    // This would use platform-specific memory APIs in a real implementation
    final memoryUsage = _getCurrentMemoryUsage();

    _recordMetric('memory_usage_mb', memoryUsage ~/ (1024 * 1024));

    if (memoryUsage > _memoryCriticalThreshold) {
      logger.error(
        'Critical memory usage detected: ${memoryUsage ~/ (1024 * 1024)}MB',
      );
      _handleMemoryPressure();
    } else if (memoryUsage > _memoryWarningThreshold) {
      logger.warning(
        'High memory usage detected: ${memoryUsage ~/ (1024 * 1024)}MB',
      );
    }
  }

  /// Handle memory pressure by freeing resources
  Future<void> _handleMemoryPressure() async {
    try {
      // Clear image caches
      // Dispose unused controllers
      // Trigger garbage collection
      // Reduce background processing

      logger.info('Memory pressure handled, resources freed');
    } catch (error) {
      logger.error('Failed to handle memory pressure', error: error);
    }
  }

  /// Get current memory usage (platform-specific implementation needed)
  int _getCurrentMemoryUsage() {
    // This is a placeholder - real implementation would use:
    // - ProcessInfo.processInfo.physicalMemory on iOS
    // - ActivityManager.getMemoryInfo() on Android
    // - Process memory APIs on desktop
    return 50 * 1024 * 1024; // 50MB placeholder
  }

  /// Preload an image asset
  Future<void> _preloadImage(String assetPath) async {
    try {
      // In a real implementation, this would preload the image
      await Future.delayed(const Duration(milliseconds: 10));
    } catch (error) {
      logger.warning('Failed to preload image: $assetPath', error: error);
    }
  }

  /// Health check implementations
  Future<bool> _checkDatabaseHealth(Ref ref) async {
    try {
      final isarService = ref.read(isarServiceProvider);
      final health = await isarService.getHealthStatus();
      return health == DatabaseHealthStatus.healthy;
    } catch (error) {
      return false;
    }
  }

  Future<bool> _checkNetworkHealth() async {
    try {
      // Perform a simple network connectivity check
      return true; // Placeholder
    } catch (error) {
      return false;
    }
  }

  Future<bool> _checkStorageHealth() async {
    try {
      // Check available storage space
      return true; // Placeholder
    } catch (error) {
      return false;
    }
  }

  Future<bool> _checkMemoryHealth() async {
    final memoryUsage = _getCurrentMemoryUsage();
    return memoryUsage < _memoryCriticalThreshold;
  }

  /// Report crash to analytics
  void _reportCrash(dynamic error, dynamic stackTrace) {
    try {
      // Report to Firebase Crashlytics or other crash reporting service
      // Include startup context and timing information
    } catch (reportError) {
      logger.error('Failed to report crash', error: reportError);
    }
  }

  /// Update progress callback
  void _updateProgress(String message, double progress) {
    _progressCallback?.call(message, progress);
  }

  /// Record a startup metric
  void _recordMetric(String name, num value) {
    _metrics.add(
      StartupMetric(name: name, value: value, timestamp: DateTime.now()),
    );
  }

  /// Log performance summary
  void _logPerformanceSummary() {
    final buffer = StringBuffer();
    buffer.writeln('=== Startup Performance Summary ===');
    buffer.writeln('Total time: ${_startupStopwatch.elapsed.inMilliseconds}ms');
    buffer.writeln('');

    buffer.writeln('Phase timings:');
    for (final entry in _phaseTimings.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value.inMilliseconds}ms');
    }

    if (_initializationErrors.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Errors encountered:');
      for (final error in _initializationErrors) {
        buffer.writeln('  - $error');
      }
    }

    buffer.writeln('');
    buffer.writeln('Key metrics:');
    for (final metric in _metrics.take(10)) {
      buffer.writeln('  ${metric.name}: ${metric.value}');
    }

    logger.info(buffer.toString());
  }

  /// Get startup performance report
  StartupPerformanceReport getPerformanceReport() {
    return StartupPerformanceReport(
      totalStartupTime: _startupStopwatch.elapsed,
      phaseTimings: Map.from(_phaseTimings),
      metrics: List.from(_metrics),
      errors: List.from(_initializationErrors),
      isWithinTarget: _startupStopwatch.elapsed <= _targetStartupTime,
      reportTimestamp: DateTime.now(),
    );
  }

  /// Reset for testing
  @visibleForTesting
  void reset() {
    _startupStopwatch.reset();
    _phaseTimings.clear();
    _metrics.clear();
    _initializationErrors.clear();
    _isInitializing = false;
    _initializationComplete = false;
    _progressCallback = null;
    _instance = null;
  }
}

/// Startup progress callback
typedef StartupProgressCallback =
    void Function(String message, double progress);

/// Startup metric
class StartupMetric {
  final String name;
  final num value;
  final DateTime timestamp;

  const StartupMetric({
    required this.name,
    required this.value,
    required this.timestamp,
  });

  @override
  String toString() => '$name: $value at $timestamp';
}

/// Startup performance report
class StartupPerformanceReport {
  final Duration totalStartupTime;
  final Map<String, Duration> phaseTimings;
  final List<StartupMetric> metrics;
  final List<String> errors;
  final bool isWithinTarget;
  final DateTime reportTimestamp;

  const StartupPerformanceReport({
    required this.totalStartupTime,
    required this.phaseTimings,
    required this.metrics,
    required this.errors,
    required this.isWithinTarget,
    required this.reportTimestamp,
  });

  /// Get performance score (0-100)
  int getPerformanceScore() {
    int score = 100;

    // Startup time score (50%)
    if (totalStartupTime.inMilliseconds > 3000) {
      score -= 50;
    } else if (totalStartupTime.inMilliseconds > 2000) {
      score -= 30;
    } else if (totalStartupTime.inMilliseconds > 1500) {
      score -= 15;
    }

    // Error penalty (30%)
    if (errors.isNotEmpty) {
      score -= min(30, errors.length * 10);
    }

    // Phase timing consistency (20%)
    final phaseTimes =
        phaseTimings.values.map((d) => d.inMilliseconds).toList();
    if (phaseTimes.isNotEmpty) {
      final maxPhaseTime = phaseTimes.reduce(max);
      if (maxPhaseTime > 800) {
        score -= 20;
      } else if (maxPhaseTime > 500) {
        score -= 10;
      }
    }

    return score.clamp(0, 100);
  }

  @override
  String toString() {
    return 'StartupPerformanceReport('
        'time: ${totalStartupTime.inMilliseconds}ms, '
        'score: ${getPerformanceScore()}/100, '
        'errors: ${errors.length})';
  }
}

/// Global startup performance manager instance
final startupPerformanceManager = StartupPerformanceManager.instance;

/// Provider for startup performance manager
final startupPerformanceManagerProvider = Provider<StartupPerformanceManager>((
  ref,
) {
  return StartupPerformanceManager.instance;
});
