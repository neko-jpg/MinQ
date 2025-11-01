import 'dart:async';
import 'dart:math';
import 'package:minq/core/error/exceptions.dart';
import 'package:minq/core/logging/app_logger.dart';

/// Generic MinqException for error recovery
class _GenericMinqException extends MinqException {
  const _GenericMinqException(super.message, {super.code});
}

/// Error recovery strategy
enum RecoveryStrategy {
  /// Retry the operation
  retry,

  /// Use fallback/alternative approach
  fallback,

  /// Fail gracefully with user notification
  failGracefully,

  /// Ignore the error and continue
  ignore,

  /// Escalate to higher level handler
  escalate,
}

/// Recovery action result
class RecoveryResult<T> {
  final bool success;
  final T? data;
  final MinqException? error;
  final RecoveryStrategy strategyUsed;
  final String? message;

  const RecoveryResult({
    required this.success,
    this.data,
    this.error,
    required this.strategyUsed,
    this.message,
  });

  factory RecoveryResult.success(
    T data,
    RecoveryStrategy strategy, [
    String? message,
  ]) {
    return RecoveryResult(
      success: true,
      data: data,
      strategyUsed: strategy,
      message: message,
    );
  }

  factory RecoveryResult.failure(
    MinqException error,
    RecoveryStrategy strategy, [
    String? message,
  ]) {
    return RecoveryResult(
      success: false,
      error: error,
      strategyUsed: strategy,
      message: message,
    );
  }
}

/// Retry configuration with exponential backoff
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final double jitterFactor;
  final bool Function(dynamic error)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.jitterFactor = 0.1,
    this.shouldRetry,
  });

  /// Default retry configuration
  static const defaultConfig = RetryConfig();

  /// Network operations retry configuration
  static const networkConfig = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(minutes: 1),
    backoffMultiplier: 2.0,
    jitterFactor: 0.2,
  );

  /// Database operations retry configuration
  static const databaseConfig = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 10),
    backoffMultiplier: 1.5,
    jitterFactor: 0.1,
  );

  /// AI service retry configuration
  static const aiServiceConfig = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 15),
    backoffMultiplier: 2.0,
    jitterFactor: 0.15,
  );
}

/// Error recovery manager
class ErrorRecoveryManager {
  static final ErrorRecoveryManager _instance =
      ErrorRecoveryManager._internal();
  factory ErrorRecoveryManager() => _instance;
  ErrorRecoveryManager._internal();

  final Map<String, RecoveryStrategy Function(MinqException)>
  _recoveryStrategies = {};
  final Map<String, Future<dynamic> Function()> _fallbackActions = {};

  /// Register a recovery strategy for a specific error code
  void registerRecoveryStrategy(
    String errorCode,
    RecoveryStrategy Function(MinqException) strategyProvider,
  ) {
    _recoveryStrategies[errorCode] = strategyProvider;
  }

  /// Register a fallback action for a specific error code
  void registerFallbackAction(
    String errorCode,
    Future<dynamic> Function() fallbackAction,
  ) {
    _fallbackActions[errorCode] = fallbackAction;
  }

  /// Execute operation with error recovery
  Future<RecoveryResult<T>> executeWithRecovery<T>({
    required Future<T> Function() operation,
    required String operationName,
    RetryConfig? retryConfig,
    Future<T> Function()? fallbackOperation,
    bool logErrors = true,
  }) async {
    final config = retryConfig ?? RetryConfig.defaultConfig;
    int attempt = 0;
    MinqException? lastError;

    while (attempt < config.maxAttempts) {
      attempt++;

      try {
        if (logErrors && attempt > 1) {
          logger.info(
            'Retrying operation: $operationName (attempt $attempt/${config.maxAttempts})',
          );
        }

        final result = await operation();

        if (logErrors && attempt > 1) {
          logger.info(
            'Operation succeeded after $attempt attempts: $operationName',
          );
        }

        return RecoveryResult.success(
          result,
          RecoveryStrategy.retry,
          attempt > 1 ? 'Succeeded after $attempt attempts' : null,
        );
      } catch (error, stackTrace) {
        final minqError = ExceptionUtils.fromError(error, stackTrace);
        lastError = minqError;

        if (logErrors) {
          logger.error(
            'Operation failed: $operationName (attempt $attempt/${config.maxAttempts})',
            data: minqError.toMap(),
            error: error,
            stackTrace: stackTrace,
          );
        }

        // Check if we should retry
        if (attempt >= config.maxAttempts || !_shouldRetry(minqError, config)) {
          break;
        }

        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(attempt, config);

        if (logErrors) {
          logger.debug('Waiting ${delay.inMilliseconds}ms before retry');
        }

        await Future.delayed(delay);
      }
    }

    // All retries failed, try recovery strategies
    if (lastError != null) {
      return await _attemptRecovery<T>(
        lastError,
        operationName,
        fallbackOperation,
        logErrors,
      );
    }

    return RecoveryResult.failure(
      _GenericMinqException(
        'Operation failed without specific error: $operationName',
      ),
      RecoveryStrategy.failGracefully,
    );
  }

  /// Attempt error recovery using registered strategies
  Future<RecoveryResult<T>> _attemptRecovery<T>(
    MinqException error,
    String operationName,
    Future<T> Function()? fallbackOperation,
    bool logErrors,
  ) async {
    final errorCode = error.code;

    if (errorCode != null && _recoveryStrategies.containsKey(errorCode)) {
      final strategy = _recoveryStrategies[errorCode]!(error);

      if (logErrors) {
        logger.info(
          'Attempting recovery strategy: $strategy for error: $errorCode',
        );
      }

      switch (strategy) {
        case RecoveryStrategy.fallback:
          return await _executeFallback<T>(
            errorCode,
            fallbackOperation,
            logErrors,
          );

        case RecoveryStrategy.failGracefully:
          return RecoveryResult.failure(
            error,
            RecoveryStrategy.failGracefully,
            'Operation failed gracefully: $operationName',
          );

        case RecoveryStrategy.ignore:
          if (logErrors) {
            logger.warning(
              'Ignoring error as per recovery strategy: $errorCode',
            );
          }
          return RecoveryResult.failure(
            error,
            RecoveryStrategy.ignore,
            'Error ignored as per recovery strategy',
          );

        case RecoveryStrategy.escalate:
          if (logErrors) {
            logger.error('Escalating error: $errorCode', data: error.toMap());
          }
          return RecoveryResult.failure(
            error,
            RecoveryStrategy.escalate,
            'Error escalated to higher level handler',
          );

        default:
          break;
      }
    }

    // Default fallback if no specific strategy is registered
    if (fallbackOperation != null) {
      return await _executeFallback<T>(errorCode, fallbackOperation, logErrors);
    }

    return RecoveryResult.failure(
      error,
      RecoveryStrategy.failGracefully,
      'No recovery strategy available for: $operationName',
    );
  }

  /// Execute fallback operation
  Future<RecoveryResult<T>> _executeFallback<T>(
    String? errorCode,
    Future<T> Function()? fallbackOperation,
    bool logErrors,
  ) async {
    try {
      // Try registered fallback action first
      if (errorCode != null && _fallbackActions.containsKey(errorCode)) {
        if (logErrors) {
          logger.info('Executing registered fallback action for: $errorCode');
        }

        final result = await _fallbackActions[errorCode]!() as T;
        return RecoveryResult.success(
          result,
          RecoveryStrategy.fallback,
          'Recovered using registered fallback action',
        );
      }

      // Try provided fallback operation
      if (fallbackOperation != null) {
        if (logErrors) {
          logger.info('Executing provided fallback operation');
        }

        final result = await fallbackOperation();
        return RecoveryResult.success(
          result,
          RecoveryStrategy.fallback,
          'Recovered using fallback operation',
        );
      }

      return RecoveryResult.failure(
        const _GenericMinqException('No fallback operation available'),
        RecoveryStrategy.failGracefully,
      );
    } catch (fallbackError, stackTrace) {
      final minqError = ExceptionUtils.fromError(fallbackError, stackTrace);

      if (logErrors) {
        logger.error(
          'Fallback operation failed',
          data: minqError.toMap(),
          error: fallbackError,
          stackTrace: stackTrace,
        );
      }

      return RecoveryResult.failure(
        minqError,
        RecoveryStrategy.failGracefully,
        'Fallback operation also failed',
      );
    }
  }

  /// Check if error should be retried
  bool _shouldRetry(MinqException error, RetryConfig config) {
    // Use custom retry logic if provided
    if (config.shouldRetry != null) {
      return config.shouldRetry!(error);
    }

    // Default retry logic
    return ExceptionUtils.isRetryable(error);
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(int attempt, RetryConfig config) {
    final baseDelay = config.initialDelay.inMilliseconds;
    final exponentialDelay =
        baseDelay * pow(config.backoffMultiplier, attempt - 1);

    // Add jitter to prevent thundering herd
    final jitter = Random().nextDouble() * config.jitterFactor;
    final delayWithJitter = exponentialDelay * (1 + jitter);

    final finalDelay = Duration(milliseconds: delayWithJitter.round());

    // Ensure delay doesn't exceed maximum
    return finalDelay > config.maxDelay ? config.maxDelay : finalDelay;
  }

  /// Initialize default recovery strategies
  void initializeDefaultStrategies() {
    // Network error strategies
    registerRecoveryStrategy(
      'NETWORK_NO_CONNECTION',
      (error) => RecoveryStrategy.failGracefully,
    );
    registerRecoveryStrategy(
      'NETWORK_TIMEOUT',
      (error) => RecoveryStrategy.retry,
    );
    registerRecoveryStrategy(
      'NETWORK_SERVER_ERROR',
      (error) => RecoveryStrategy.retry,
    );
    registerRecoveryStrategy(
      'NETWORK_RATE_LIMIT',
      (error) => RecoveryStrategy.retry,
    );

    // Database error strategies
    registerRecoveryStrategy(
      'DB_CONNECTION_FAILED',
      (error) => RecoveryStrategy.retry,
    );
    registerRecoveryStrategy(
      'DB_OPERATION_FAILED',
      (error) => RecoveryStrategy.retry,
    );
    registerRecoveryStrategy(
      'DB_NOT_FOUND',
      (error) => RecoveryStrategy.fallback,
    );
    registerRecoveryStrategy(
      'DB_VALIDATION_FAILED',
      (error) => RecoveryStrategy.failGracefully,
    );

    // AI service error strategies
    registerRecoveryStrategy(
      'AI_SERVICE_UNAVAILABLE',
      (error) => RecoveryStrategy.fallback,
    );
    registerRecoveryStrategy(
      'AI_MODEL_LOAD_FAILED',
      (error) => RecoveryStrategy.retry,
    );
    registerRecoveryStrategy(
      'AI_INFERENCE_FAILED',
      (error) => RecoveryStrategy.fallback,
    );
    registerRecoveryStrategy(
      'AI_INVALID_INPUT',
      (error) => RecoveryStrategy.failGracefully,
    );

    // Auth error strategies
    registerRecoveryStrategy(
      'AUTH_NOT_AUTHENTICATED',
      (error) => RecoveryStrategy.escalate,
    );
    registerRecoveryStrategy(
      'AUTH_TOKEN_EXPIRED',
      (error) => RecoveryStrategy.retry,
    );
    registerRecoveryStrategy(
      'AUTH_INSUFFICIENT_PERMISSIONS',
      (error) => RecoveryStrategy.failGracefully,
    );

    // Storage error strategies
    registerRecoveryStrategy(
      'STORAGE_FILE_NOT_FOUND',
      (error) => RecoveryStrategy.fallback,
    );
    registerRecoveryStrategy(
      'STORAGE_UPLOAD_FAILED',
      (error) => RecoveryStrategy.retry,
    );
    registerRecoveryStrategy(
      'STORAGE_INSUFFICIENT_SPACE',
      (error) => RecoveryStrategy.failGracefully,
    );
  }
}

/// Global error recovery manager instance
final errorRecovery = ErrorRecoveryManager();

/// Convenience function for executing operations with recovery
Future<RecoveryResult<T>> executeWithRecovery<T>({
  required Future<T> Function() operation,
  required String operationName,
  RetryConfig? retryConfig,
  Future<T> Function()? fallbackOperation,
  bool logErrors = true,
}) {
  return errorRecovery.executeWithRecovery<T>(
    operation: operation,
    operationName: operationName,
    retryConfig: retryConfig,
    fallbackOperation: fallbackOperation,
    logErrors: logErrors,
  );
}

/// Circuit breaker for preventing cascading failures
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  int _failureCount = 0;
  DateTime? _lastFailureTime;
  bool _isOpen = false;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 30),
    this.resetTimeout = const Duration(minutes: 1),
  });

  /// Execute operation through circuit breaker
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_isOpen) {
      if (_shouldAttemptReset()) {
        logger.info('Circuit breaker attempting reset: $name');
        _isOpen = false;
        _failureCount = 0;
      } else {
        throw _GenericMinqException(
          'Circuit breaker is open for: $name',
          code: 'CIRCUIT_BREAKER_OPEN',
        );
      }
    }

    try {
      final result = await operation().timeout(timeout);
      _onSuccess();
      return result;
    } catch (error) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _lastFailureTime = null;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _isOpen = true;
      logger.warning(
        'Circuit breaker opened due to failures: $name (failures: $_failureCount)',
      );
    }
  }

  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return true;
    return DateTime.now().difference(_lastFailureTime!) > resetTimeout;
  }

  /// Get current state
  Map<String, dynamic> getState() {
    return {
      'name': name,
      'isOpen': _isOpen,
      'failureCount': _failureCount,
      'lastFailureTime': _lastFailureTime?.toIso8601String(),
    };
  }
}
