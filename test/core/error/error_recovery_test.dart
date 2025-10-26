import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/error/error_recovery.dart';
import 'package:minq/core/error/exceptions.dart';

/// Test exception class for testing
class _TestMinqException extends MinqException {
  const _TestMinqException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });
}

void main() {
  group('ErrorRecoveryManager', () {
    late ErrorRecoveryManager errorRecovery;

    setUp(() {
      errorRecovery = ErrorRecoveryManager();
      errorRecovery.initializeDefaultStrategies();
    });

    test('should execute operation successfully on first attempt', () async {
      var callCount = 0;
      
      final result = await errorRecovery.executeWithRecovery<String>(
        operation: () async {
          callCount++;
          return 'success';
        },
        operationName: 'test_operation',
        logErrors: false,
      );

      expect(result.success, isTrue);
      expect(result.data, equals('success'));
      expect(result.strategyUsed, equals(RecoveryStrategy.retry));
      expect(callCount, equals(1));
    });

    test('should retry operation on retryable error', () async {
      var callCount = 0;
      
      final result = await errorRecovery.executeWithRecovery<String>(
        operation: () async {
          callCount++;
          if (callCount < 3) {
            throw NetworkException.timeout(const Duration(seconds: 30));
          }
          return 'success after retry';
        },
        operationName: 'test_retry_operation',
        retryConfig: const RetryConfig(maxAttempts: 3, initialDelay: Duration(milliseconds: 10)),
        logErrors: false,
      );

      expect(result.success, isTrue);
      expect(result.data, equals('success after retry'));
      expect(result.strategyUsed, equals(RecoveryStrategy.retry));
      expect(callCount, equals(3));
    });

    test('should use fallback operation when retries fail', () async {
      var mainCallCount = 0;
      var fallbackCallCount = 0;
      
      final result = await errorRecovery.executeWithRecovery<String>(
        operation: () async {
          mainCallCount++;
          throw NetworkException.serverError(500);
        },
        operationName: 'test_fallback_operation',
        retryConfig: const RetryConfig(maxAttempts: 2, initialDelay: Duration(milliseconds: 10)),
        fallbackOperation: () async {
          fallbackCallCount++;
          return 'fallback success';
        },
        logErrors: false,
      );

      expect(result.success, isTrue);
      expect(result.data, equals('fallback success'));
      expect(result.strategyUsed, equals(RecoveryStrategy.fallback));
      expect(mainCallCount, equals(2));
      expect(fallbackCallCount, equals(1));
    });

    test('should not retry non-retryable errors', () async {
      var callCount = 0;
      
      final result = await errorRecovery.executeWithRecovery<String>(
        operation: () async {
          callCount++;
          throw NetworkException.noConnection();
        },
        operationName: 'test_non_retryable',
        retryConfig: const RetryConfig(maxAttempts: 3, initialDelay: Duration(milliseconds: 10)),
        logErrors: false,
      );

      expect(result.success, isFalse);
      expect(result.error, isA<NetworkException>());
      expect(result.strategyUsed, equals(RecoveryStrategy.failGracefully));
      expect(callCount, equals(1)); // Should not retry
    });

    test('should register and use custom recovery strategy', () async {
      const customErrorCode = 'CUSTOM_ERROR';
      
      errorRecovery.registerRecoveryStrategy(
        customErrorCode,
        (error) => RecoveryStrategy.ignore,
      );

      final result = await errorRecovery.executeWithRecovery<String>(
        operation: () async {
          throw _TestMinqException('Custom error', code: customErrorCode);
        },
        operationName: 'test_custom_strategy',
        logErrors: false,
      );

      expect(result.success, isFalse);
      expect(result.strategyUsed, equals(RecoveryStrategy.ignore));
    });

    test('should register and use fallback action', () async {
      const errorCode = 'FALLBACK_ERROR';
      
      errorRecovery.registerRecoveryStrategy(
        errorCode,
        (error) => RecoveryStrategy.fallback,
      );
      
      errorRecovery.registerFallbackAction(
        errorCode,
        () async => 'registered fallback result',
      );

      final result = await errorRecovery.executeWithRecovery<String>(
        operation: () async {
          throw _TestMinqException('Fallback error', code: errorCode);
        },
        operationName: 'test_registered_fallback',
        logErrors: false,
      );

      expect(result.success, isTrue);
      expect(result.data, equals('registered fallback result'));
      expect(result.strategyUsed, equals(RecoveryStrategy.fallback));
    });
  });

  group('RetryConfig', () {
    test('should calculate exponential backoff delay', () async {
      const config = RetryConfig(
        maxAttempts: 3,
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
        jitterFactor: 0.0, // No jitter for predictable testing
      );

      var attempt = 0;
      final delays = <Duration>[];
      
      try {
        await ErrorRecoveryManager().executeWithRecovery<void>(
          operation: () async {
            attempt++;
            final start = DateTime.now();
            throw NetworkException.timeout(const Duration(seconds: 30));
          },
          operationName: 'test_backoff',
          retryConfig: config,
          logErrors: false,
        );
      } catch (e) {
        // Expected to fail after retries
      }

      expect(attempt, equals(3));
    });

    test('should respect max delay', () async {
      const config = RetryConfig(
        maxAttempts: 5,
        initialDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 2),
        backoffMultiplier: 10.0, // Would normally create very long delays
        jitterFactor: 0.0,
      );

      var attempt = 0;
      final start = DateTime.now();
      
      try {
        await ErrorRecoveryManager().executeWithRecovery<void>(
          operation: () async {
            attempt++;
            throw NetworkException.timeout(const Duration(seconds: 30));
          },
          operationName: 'test_max_delay',
          retryConfig: config,
          logErrors: false,
        );
      } catch (e) {
        // Expected to fail
      }

      final elapsed = DateTime.now().difference(start);
      // Should not take too long due to max delay constraint
      expect(elapsed.inSeconds, lessThan(15)); // Conservative upper bound
      expect(attempt, equals(5));
    });
  });

  group('CircuitBreaker', () {
    test('should open circuit after failure threshold', () async {
      final circuitBreaker = CircuitBreaker(
        name: 'test_circuit',
        failureThreshold: 3,
        timeout: const Duration(milliseconds: 100),
        resetTimeout: const Duration(seconds: 1),
      );

      // Cause failures to open the circuit
      for (int i = 0; i < 3; i++) {
        try {
          await circuitBreaker.execute(() async {
            throw Exception('Test failure');
          });
        } catch (e) {
          // Expected failures
        }
      }

      // Circuit should now be open
      expect(() async {
        await circuitBreaker.execute(() async => 'success');
      }, throwsA(isA<MinqException>()));

      final state = circuitBreaker.getState();
      expect(state['isOpen'], isTrue);
      expect(state['failureCount'], equals(3));
    });

    test('should reset circuit after timeout', () async {
      final circuitBreaker = CircuitBreaker(
        name: 'test_reset_circuit',
        failureThreshold: 2,
        timeout: const Duration(milliseconds: 50),
        resetTimeout: const Duration(milliseconds: 100),
      );

      // Cause failures to open the circuit
      for (int i = 0; i < 2; i++) {
        try {
          await circuitBreaker.execute(() async {
            throw Exception('Test failure');
          });
        } catch (e) {
          // Expected failures
        }
      }

      // Wait for reset timeout
      await Future.delayed(const Duration(milliseconds: 150));

      // Circuit should allow execution again
      final result = await circuitBreaker.execute(() async => 'success after reset');
      expect(result, equals('success after reset'));

      final state = circuitBreaker.getState();
      expect(state['isOpen'], isFalse);
      expect(state['failureCount'], equals(0));
    });

    test('should handle timeout in circuit breaker', () async {
      final circuitBreaker = CircuitBreaker(
        name: 'test_timeout_circuit',
        failureThreshold: 5,
        timeout: const Duration(milliseconds: 50),
      );

      expect(() async {
        await circuitBreaker.execute(() async {
          await Future.delayed(const Duration(milliseconds: 100)); // Longer than timeout
          return 'should not complete';
        });
      }, throwsA(anything));
    });
  });

  group('RecoveryResult', () {
    test('should create success result', () {
      final result = RecoveryResult.success('data', RecoveryStrategy.retry, 'Success message');

      expect(result.success, isTrue);
      expect(result.data, equals('data'));
      expect(result.strategyUsed, equals(RecoveryStrategy.retry));
      expect(result.message, equals('Success message'));
      expect(result.error, isNull);
    });

    test('should create failure result', () {
      final error = NetworkException.noConnection();
      final result = RecoveryResult.failure(error, RecoveryStrategy.failGracefully, 'Failure message');

      expect(result.success, isFalse);
      expect(result.error, equals(error));
      expect(result.strategyUsed, equals(RecoveryStrategy.failGracefully));
      expect(result.message, equals('Failure message'));
      expect(result.data, isNull);
    });
  });

  group('executeWithRecovery convenience function', () {
    test('should work as a convenience wrapper', () async {
      final result = await executeWithRecovery<String>(
        operation: () async => 'convenience success',
        operationName: 'convenience_test',
        logErrors: false,
      );

      expect(result.success, isTrue);
      expect(result.data, equals('convenience success'));
    });
  });
}