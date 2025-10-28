import 'dart:async';
import 'dart:developer' as developer;

import 'package:minq/core/database/database_lifecycle_manager.dart';
import 'package:minq/data/repositories/enhanced_quest_log_repository.dart';
import 'package:minq/data/repositories/enhanced_quest_repository.dart';

/// Database maintenance service for periodic cleanup and optimization
class DatabaseMaintenanceService {
  static DatabaseMaintenanceService? _instance;
  static DatabaseMaintenanceService get instance => _instance ??= DatabaseMaintenanceService._();

  DatabaseMaintenanceService._();

  Timer? _maintenanceTimer;
  bool _isRunning = false;

  /// Start periodic maintenance
  void startPeriodicMaintenance({
    Duration interval = const Duration(hours: 24),
  }) {
    if (_maintenanceTimer != null) return;

    _maintenanceTimer = Timer.periodic(interval, (_) {
      if (!_isRunning) {
        performMaintenance();
      }
    });

    developer.log('Database maintenance service started (interval: ${interval.inHours}h)');
  }

  /// Stop periodic maintenance
  void stopPeriodicMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = null;
    developer.log('Database maintenance service stopped');
  }

  /// Perform maintenance tasks
  Future<MaintenanceReport> performMaintenance({
    bool cleanupOldLogs = true,
    bool cleanupUnusedQuests = true,
    bool optimizeStorage = true,
    bool performHealthCheck = true,
  }) async {
    if (_isRunning) {
      throw StateError('Maintenance is already running');
    }

    _isRunning = true;
    final stopwatch = Stopwatch()..start();

    try {
      developer.log('Starting database maintenance...');

      final report = MaintenanceReport();

      // Health check
      if (performHealthCheck) {
        await _performHealthCheck(report);
      }

      // Cleanup old logs
      if (cleanupOldLogs) {
        await _cleanupOldLogs(report);
      }

      // Cleanup unused quests
      if (cleanupUnusedQuests) {
        await _cleanupUnusedQuests(report);
      }

      // Optimize storage
      if (optimizeStorage) {
        await _optimizeStorage(report);
      }

      stopwatch.stop();
      report.totalDuration = stopwatch.elapsed;

      developer.log('Database maintenance completed in ${stopwatch.elapsedMilliseconds}ms');
      developer.log('Maintenance report: ${report.getSummary()}');

      return report;

    } catch (error, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Database maintenance failed: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isRunning = false;
    }
  }

  /// Perform database health check
  Future<void> _performHealthCheck(MaintenanceReport report) async {
    try {
      final healthStatus = await DatabaseLifecycleManager.instance.performHealthCheck();
      report.healthStatus = healthStatus;

      if (healthStatus != DatabaseHealthStatus.healthy) {
        developer.log('Database health check warning: $healthStatus');
      }

    } catch (error) {
      developer.log('Health check failed: $error');
      report.errors.add('Health check failed: $error');
    }
  }

  /// Clean up old quest logs
  Future<void> _cleanupOldLogs(MaintenanceReport report) async {
    try {
      // This would need to be injected or accessed through a service locator
      // For now, we'll skip the actual cleanup and just log
      developer.log('Quest log cleanup would be performed here');
      report.logsDeleted = 0; // Placeholder

    } catch (error) {
      developer.log('Log cleanup failed: $error');
      report.errors.add('Log cleanup failed: $error');
    }
  }

  /// Clean up unused quests
  Future<void> _cleanupUnusedQuests(MaintenanceReport report) async {
    try {
      // This would need to be injected or accessed through a service locator
      // For now, we'll skip the actual cleanup and just log
      developer.log('Quest cleanup would be performed here');
      report.questsDeleted = 0; // Placeholder

    } catch (error) {
      developer.log('Quest cleanup failed: $error');
      report.errors.add('Quest cleanup failed: $error');
    }
  }

  /// Optimize database storage
  Future<void> _optimizeStorage(MaintenanceReport report) async {
    try {
      await DatabaseLifecycleManager.instance.optimizeStorage();
      report.storageOptimized = true;

    } catch (error) {
      developer.log('Storage optimization failed: $error');
      report.errors.add('Storage optimization failed: $error');
    }
  }

  /// Get maintenance status
  bool get isRunning => _isRunning;

  /// Dispose maintenance service
  void dispose() {
    stopPeriodicMaintenance();
    _instance = null;
  }
}

/// Maintenance report
class MaintenanceReport {
  DatabaseHealthStatus? healthStatus;
  int logsDeleted = 0;
  int questsDeleted = 0;
  bool storageOptimized = false;
  Duration? totalDuration;
  final List<String> errors = [];

  /// Get summary of maintenance activities
  String getSummary() {
    final buffer = StringBuffer();

    if (healthStatus != null) {
      buffer.writeln('Health Status: ${healthStatus!.name}');
    }

    if (logsDeleted > 0) {
      buffer.writeln('Logs Deleted: $logsDeleted');
    }

    if (questsDeleted > 0) {
      buffer.writeln('Quests Deleted: $questsDeleted');
    }

    if (storageOptimized) {
      buffer.writeln('Storage Optimized: Yes');
    }

    if (totalDuration != null) {
      buffer.writeln('Duration: ${totalDuration!.inMilliseconds}ms');
    }

    if (errors.isNotEmpty) {
      buffer.writeln('Errors: ${errors.length}');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }

    return buffer.toString().trim();
  }

  /// Check if maintenance was successful
  bool get isSuccessful => errors.isEmpty;
}

/// Maintenance service with dependency injection
class DatabaseMaintenanceServiceWithDI {
  final EnhancedQuestRepository? questRepository;
  final EnhancedQuestLogRepository? questLogRepository;

  DatabaseMaintenanceServiceWithDI({
    this.questRepository,
    this.questLogRepository,
  });

  /// Perform maintenance with actual repository operations
  Future<MaintenanceReport> performMaintenance({
    bool cleanupOldLogs = true,
    bool cleanupUnusedQuests = true,
    bool optimizeStorage = true,
    bool performHealthCheck = true,
    Duration logRetention = const Duration(days: 365),
    Duration questRetention = const Duration(days: 365),
  }) async {
    final stopwatch = Stopwatch()..start();
    final report = MaintenanceReport();

    try {
      developer.log('Starting database maintenance with repositories...');

      // Health check
      if (performHealthCheck) {
        final healthStatus = await DatabaseLifecycleManager.instance.performHealthCheck();
        report.healthStatus = healthStatus;
      }

      // Cleanup old logs
      if (cleanupOldLogs && questLogRepository != null) {
        // We would need a way to get all user IDs or perform global cleanup
        // For now, this is a placeholder
        developer.log('Would cleanup logs older than ${logRetention.inDays} days');
        report.logsDeleted = 0;
      }

      // Cleanup unused quests
      if (cleanupUnusedQuests && questRepository != null) {
        final deleted = await questRepository!.cleanupUnusedQuests(
          olderThan: questRetention,
        );
        report.questsDeleted = deleted;
        developer.log('Deleted $deleted unused quests');
      }

      // Optimize storage
      if (optimizeStorage) {
        await DatabaseLifecycleManager.instance.optimizeStorage();
        report.storageOptimized = true;
      }

      stopwatch.stop();
      report.totalDuration = stopwatch.elapsed;

      developer.log('Database maintenance completed successfully');

      return report;

    } catch (error, stackTrace) {
      stopwatch.stop();
      report.totalDuration = stopwatch.elapsed;
      report.errors.add(error.toString());

      developer.log(
        'Database maintenance failed: $error',
        error: error,
        stackTrace: stackTrace,
      );

      return report;
    }
  }
}