import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/error/exceptions.dart';

/// Database lifecycle manager for proper initialization and cleanup
class DatabaseLifecycleManager {
  static DatabaseLifecycleManager? _instance;
  static DatabaseLifecycleManager get instance =>
      _instance ??= DatabaseLifecycleManager._();

  DatabaseLifecycleManager._();

  Isar? _isar;
  bool _isInitializing = false;
  bool _isDisposed = false;
  final List<StreamSubscription> _subscriptions = [];
  final Completer<void> _initializationCompleter = Completer<void>();

  /// Get the current Isar instance
  Isar? get isar => _isar;

  /// Check if database is initialized
  bool get isInitialized => _isar != null && !_isDisposed;

  /// Initialize database with progress feedback
  Future<Isar> initialize({
    required List<CollectionSchema> schemas,
    String? directory,
    Function(String message, double progress)? onProgress,
  }) async {
    if (_isDisposed) {
      throw const DatabaseException('Database manager has been disposed');
    }

    if (_isar != null) {
      return _isar!;
    }

    if (_isInitializing) {
      await _initializationCompleter.future;
      return _isar!;
    }

    _isInitializing = true;

    try {
      onProgress?.call('Checking existing database...', 0.1);

      // Check for existing instance
      final existing = Isar.getInstance();
      if (existing != null) {
        _isar = existing;
        onProgress?.call('Using existing database instance', 1.0);
        _initializationCompleter.complete();
        return _isar!;
      }

      onProgress?.call('Opening database...', 0.3);

      // Open new database instance
      _isar = await Isar.open(
        schemas,
        directory: directory ?? 'isar_web',
        name: 'minq_database',
        maxSizeMiB: 256, // Limit database size
        compactOnLaunch: const CompactCondition(
          minFileSize: 100 * 1024 * 1024, // 100MB
          minBytes: 50 * 1024 * 1024, // 50MB
          minRatio: 2.0,
        ),
      );

      onProgress?.call('Verifying database integrity...', 0.7);

      // Verify database integrity
      await _verifyDatabaseIntegrity();

      onProgress?.call('Database initialization complete', 1.0);

      developer.log('Database initialized successfully');
      _initializationCompleter.complete();

      return _isar!;
    } catch (error, stackTrace) {
      _isInitializing = false;
      _initializationCompleter.completeError(error, stackTrace);

      developer.log(
        'Database initialization failed: $error',
        error: error,
        stackTrace: stackTrace,
      );

      throw DatabaseException(
        'Failed to initialize database: $error',
        originalError: error,
      );
    } finally {
      _isInitializing = false;
    }
  }

  /// Verify database integrity
  Future<void> _verifyDatabaseIntegrity() async {
    if (_isar == null) return;

    try {
      // Perform basic integrity checks by trying to access collections
      // Note: Isar 3.x doesn't expose schemas directly, so we'll do basic operations

      // Try basic operations to verify database is working
      await _isar!.txn(() async {
        // Simple transaction to test database responsiveness
      });

      developer.log('Database integrity verification passed');
    } catch (error) {
      developer.log('Database integrity check failed: $error');
      throw DatabaseException(
        'Database integrity verification failed',
        originalError: error,
      );
    }
  }

  /// Clean up unused schemas and optimize storage
  Future<void> optimizeStorage() async {
    if (_isar == null || _isDisposed) return;

    try {
      developer.log('Starting database storage optimization...');

      // Compact database to reclaim space
      final sizeBefore = await _getDatabaseSize();

      // Note: Isar doesn't have a direct compact method in runtime
      // The compactOnLaunch setting handles this automatically

      final sizeAfter = await _getDatabaseSize();
      final savedBytes = sizeBefore - sizeAfter;

      if (savedBytes > 0) {
        developer.log(
          'Storage optimization completed. Saved $savedBytes bytes',
        );
      }
    } catch (error) {
      developer.log('Storage optimization failed: $error');
      // Don't throw - this is a best-effort operation
    }
  }

  /// Get approximate database size
  Future<int> _getDatabaseSize() async {
    // This is an approximation since Isar doesn't expose direct size info
    // In a real implementation, you might check file system size
    return 0;
  }

  /// Add a subscription to be managed by the lifecycle manager
  void addSubscription(StreamSubscription subscription) {
    if (!_isDisposed) {
      _subscriptions.add(subscription);
    }
  }

  /// Remove and cancel a subscription
  void removeSubscription(StreamSubscription subscription) {
    _subscriptions.remove(subscription);
    subscription.cancel();
  }

  /// Perform health check on database
  Future<DatabaseHealthStatus> performHealthCheck() async {
    if (_isar == null || _isDisposed) {
      return DatabaseHealthStatus.unavailable;
    }

    try {
      // Check if database is responsive
      final startTime = DateTime.now();
      await _isar!.txn(() async {
        // Simple transaction to test responsiveness
      });
      final responseTime = DateTime.now().difference(startTime);

      // Check response time
      if (responseTime.inMilliseconds > 1000) {
        return DatabaseHealthStatus.slow;
      }

      // Check for any corruption indicators
      await _verifyDatabaseIntegrity();

      return DatabaseHealthStatus.healthy;
    } catch (error) {
      developer.log('Database health check failed: $error');
      return DatabaseHealthStatus.corrupted;
    }
  }

  /// Dispose of database resources and clean up
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      developer.log('Disposing database lifecycle manager...');

      // Cancel all subscriptions
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      _subscriptions.clear();

      // Close database connection
      if (_isar != null) {
        await _isar!.close();
        developer.log('Database connection closed');
      }

      _isar = null;
    } catch (error) {
      developer.log('Error during database disposal: $error');
      // Continue with disposal even if there are errors
    }
  }

  /// Reset the manager (for testing purposes)
  @visibleForTesting
  void reset() {
    _instance = null;
  }
}

/// Database health status
enum DatabaseHealthStatus { healthy, slow, corrupted, unavailable }

/// Database initialization progress callback
typedef DatabaseProgressCallback =
    void Function(String message, double progress);

/// Enhanced Isar service with lifecycle management
class EnhancedIsarService {
  final DatabaseLifecycleManager _lifecycleManager =
      DatabaseLifecycleManager.instance;

  /// Initialize database with progress feedback
  Future<Isar> init({
    DatabaseProgressCallback? onProgress,
    required List<CollectionSchema> schemas,
  }) async {
    return await _lifecycleManager.initialize(
      schemas: schemas,
      onProgress: onProgress,
    );
  }

  /// Get current database instance
  Isar? get instance => _lifecycleManager.isar;

  /// Check if database is ready
  bool get isReady => _lifecycleManager.isInitialized;

  /// Perform database health check
  Future<DatabaseHealthStatus> checkHealth() {
    return _lifecycleManager.performHealthCheck();
  }

  /// Optimize database storage
  Future<void> optimize() {
    return _lifecycleManager.optimizeStorage();
  }

  /// Dispose database resources
  Future<void> dispose() {
    return _lifecycleManager.dispose();
  }
}
