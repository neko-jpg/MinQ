import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/error/exceptions.dart';

void main() {
  group('MinqException', () {
    test('should create exception with message and code', () {
      const exception = AIServiceException('Test message', code: 'TEST_CODE');

      expect(exception.message, equals('Test message'));
      expect(exception.code, equals('TEST_CODE'));
      expect(
        exception.toString(),
        contains('AIServiceException: Test message'),
      );
      expect(exception.toString(), contains('(code: TEST_CODE)'));
    });

    test('should create exception with context', () {
      const exception = DatabaseException(
        'Database error',
        code: 'DB_ERROR',
        context: {'table': 'users', 'operation': 'insert'},
      );

      expect(exception.context, isNotNull);
      expect(exception.context!['table'], equals('users'));
      expect(exception.context!['operation'], equals('insert'));
    });

    test('should convert to map for logging', () {
      final exception = NetworkException(
        'Network error',
        code: 'NETWORK_ERROR',
        context: {'url': 'https://api.example.com'},
        originalError: 'Connection timeout',
      );

      final map = exception.toMap();

      expect(map['type'], equals('NetworkException'));
      expect(map['message'], equals('Network error'));
      expect(map['code'], equals('NETWORK_ERROR'));
      expect(map['context'], equals({'url': 'https://api.example.com'}));
      expect(map['originalError'], equals('Connection timeout'));
      expect(map['timestamp'], isNotNull);
    });
  });

  group('AIServiceException factory methods', () {
    test('should create model load failed exception', () {
      final exception = AIServiceException.modelLoadFailed('Model not found');

      expect(exception.message, equals('Failed to load AI model'));
      expect(exception.code, equals('AI_MODEL_LOAD_FAILED'));
      expect(exception.originalError, equals('Model not found'));
    });

    test('should create inference failed exception', () {
      final exception = AIServiceException.inferenceFailed('Invalid input');

      expect(exception.message, equals('AI inference failed'));
      expect(exception.code, equals('AI_INFERENCE_FAILED'));
      expect(exception.originalError, equals('Invalid input'));
    });

    test('should create service unavailable exception', () {
      final exception = AIServiceException.serviceUnavailable('Maintenance');

      expect(
        exception.message,
        equals('AI service is currently unavailable: Maintenance'),
      );
      expect(exception.code, equals('AI_SERVICE_UNAVAILABLE'));
    });

    test('should create invalid input exception', () {
      final exception = AIServiceException.invalidInput('Empty prompt');

      expect(
        exception.message,
        equals('Invalid input provided to AI service: Empty prompt'),
      );
      expect(exception.code, equals('AI_INVALID_INPUT'));
    });
  });

  group('DatabaseException factory methods', () {
    test('should create connection failed exception', () {
      final exception = DatabaseException.connectionFailed('Timeout');

      expect(exception.message, equals('Failed to connect to database'));
      expect(exception.code, equals('DB_CONNECTION_FAILED'));
      expect(exception.originalError, equals('Timeout'));
    });

    test('should create operation failed exception', () {
      final exception = DatabaseException.operationFailed(
        'INSERT',
        'Constraint violation',
      );

      expect(exception.message, equals('Database operation failed: INSERT'));
      expect(exception.code, equals('DB_OPERATION_FAILED'));
      expect(exception.originalError, equals('Constraint violation'));
      expect(exception.context!['operation'], equals('INSERT'));
    });

    test('should create not found exception', () {
      final exception = DatabaseException.notFound('User', 'user123');

      expect(
        exception.message,
        equals('Resource not found: User (id: user123)'),
      );
      expect(exception.code, equals('DB_NOT_FOUND'));
      expect(exception.context!['resource'], equals('User'));
      expect(exception.context!['id'], equals('user123'));
    });

    test('should create validation failed exception', () {
      final exception = DatabaseException.validationFailed(
        'Email format invalid',
      );

      expect(
        exception.message,
        equals('Data validation failed: Email format invalid'),
      );
      expect(exception.code, equals('DB_VALIDATION_FAILED'));
      expect(exception.context!['details'], equals('Email format invalid'));
    });
  });

  group('NetworkException factory methods', () {
    test('should create no connection exception', () {
      final exception = NetworkException.noConnection();

      expect(exception.message, equals('No internet connection available'));
      expect(exception.code, equals('NETWORK_NO_CONNECTION'));
    });

    test('should create timeout exception', () {
      final exception = NetworkException.timeout(const Duration(seconds: 30));

      expect(exception.message, equals('Request timed out after 30 seconds'));
      expect(exception.code, equals('NETWORK_TIMEOUT'));
      expect(exception.context!['timeout'], equals(30));
    });

    test('should create server error exception', () {
      final exception = NetworkException.serverError(
        500,
        'Internal Server Error',
      );

      expect(exception.message, equals('Server error: Internal Server Error'));
      expect(exception.code, equals('NETWORK_SERVER_ERROR'));
      expect(exception.context!['statusCode'], equals(500));
      expect(exception.context!['message'], equals('Internal Server Error'));
    });

    test('should create request failed exception', () {
      final exception = NetworkException.requestFailed(
        'https://api.example.com',
        'Connection refused',
      );

      expect(
        exception.message,
        equals('Network request failed: https://api.example.com'),
      );
      expect(exception.code, equals('NETWORK_REQUEST_FAILED'));
      expect(exception.originalError, equals('Connection refused'));
      expect(exception.context!['url'], equals('https://api.example.com'));
    });
  });

  group('ExceptionUtils', () {
    test('should identify retryable exceptions', () {
      expect(
        ExceptionUtils.isRetryable(
          NetworkException.timeout(const Duration(seconds: 30)),
        ),
        isTrue,
      );
      expect(
        ExceptionUtils.isRetryable(NetworkException.serverError(500)),
        isTrue,
      );
      expect(
        ExceptionUtils.isRetryable(NetworkException.noConnection()),
        isFalse,
      );
      expect(
        ExceptionUtils.isRetryable(
          DatabaseException.connectionFailed('timeout'),
        ),
        isTrue,
      );
      expect(
        ExceptionUtils.isRetryable(
          DatabaseException.validationFailed('invalid'),
        ),
        isFalse,
      );
      expect(
        ExceptionUtils.isRetryable(AIServiceException.serviceUnavailable()),
        isTrue,
      );
      expect(
        ExceptionUtils.isRetryable(AIServiceException.invalidInput('empty')),
        isFalse,
      );
    });

    test('should get user-friendly messages', () {
      expect(
        ExceptionUtils.getUserFriendlyMessage(NetworkException.noConnection()),
        equals('インターネット接続を確認してください'),
      );
      expect(
        ExceptionUtils.getUserFriendlyMessage(
          NetworkException.timeout(const Duration(seconds: 30)),
        ),
        equals('リクエストがタイムアウトしました。もう一度お試しください'),
      );
      expect(
        ExceptionUtils.getUserFriendlyMessage(AuthException.notAuthenticated()),
        equals('ログインが必要です'),
      );
      expect(
        ExceptionUtils.getUserFriendlyMessage(
          DatabaseException.notFound('User'),
        ),
        equals('データが見つかりませんでした'),
      );
    });

    test('should extract error codes', () {
      expect(
        ExceptionUtils.getErrorCode(NetworkException.noConnection()),
        equals('NETWORK_NO_CONNECTION'),
      );
      expect(
        ExceptionUtils.getErrorCode(DatabaseException.notFound('User')),
        equals('DB_NOT_FOUND'),
      );
      expect(ExceptionUtils.getErrorCode(Exception('Generic error')), isNull);
    });

    test('should create MinqException from any error', () {
      final networkError = Exception('Network connection failed');
      final minqException = ExceptionUtils.fromError(networkError);

      expect(minqException, isA<NetworkException>());
      expect(minqException.message, equals('Network request failed: unknown'));
      expect(minqException.originalError, equals(networkError));

      final databaseError = Exception('Firestore operation failed');
      final dbException = ExceptionUtils.fromError(databaseError);

      expect(dbException, isA<DatabaseException>());
      expect(dbException.message, equals('Database operation failed: unknown'));

      final authError = Exception('Authentication required');
      final authException = ExceptionUtils.fromError(authError);

      expect(authException, isA<AuthException>());
      expect(authException.message, equals('Authentication failed'));

      final genericError = Exception('Unknown error');
      final genericException = ExceptionUtils.fromError(genericError);

      expect(genericException.code, equals('UNKNOWN_ERROR'));
      expect(genericException.message, contains('Unknown error'));
    });
  });

  group('ValidationException', () {
    test('should create field validation exception', () {
      final exception = ValidationException.fieldValidation(
        'email',
        'Invalid format',
      );

      expect(
        exception.message,
        equals('Validation failed for field "email": Invalid format'),
      );
      expect(exception.code, equals('VALIDATION_FIELD_FAILED'));
      expect(exception.context!['field'], equals('email'));
      expect(exception.context!['reason'], equals('Invalid format'));
    });

    test('should create required field exception', () {
      final exception = ValidationException.requiredField('password');

      expect(exception.message, equals('Required field is missing: password'));
      expect(exception.code, equals('VALIDATION_REQUIRED_FIELD'));
      expect(exception.context!['field'], equals('password'));
    });

    test('should create invalid format exception', () {
      final exception = ValidationException.invalidFormat(
        'phone',
        'E.164 format',
      );

      expect(
        exception.message,
        equals('Invalid format for field "phone", expected: E.164 format'),
      );
      expect(exception.code, equals('VALIDATION_INVALID_FORMAT'));
      expect(exception.context!['field'], equals('phone'));
      expect(exception.context!['expectedFormat'], equals('E.164 format'));
    });
  });

  group('BusinessLogicException', () {
    test('should create operation not allowed exception', () {
      final exception = BusinessLogicException.operationNotAllowed(
        'delete',
        'User has active subscriptions',
      );

      expect(
        exception.message,
        equals(
          'Operation not allowed: delete. Reason: User has active subscriptions',
        ),
      );
      expect(exception.code, equals('BUSINESS_OPERATION_NOT_ALLOWED'));
      expect(exception.context!['operation'], equals('delete'));
      expect(
        exception.context!['reason'],
        equals('User has active subscriptions'),
      );
    });

    test('should create quota exceeded exception', () {
      final exception = BusinessLogicException.quotaExceeded(
        'API calls',
        1000,
        1500,
      );

      expect(
        exception.message,
        equals('Quota exceeded for API calls. Limit: 1000, Current: 1500'),
      );
      expect(exception.code, equals('BUSINESS_QUOTA_EXCEEDED'));
      expect(exception.context!['resource'], equals('API calls'));
      expect(exception.context!['limit'], equals(1000));
      expect(exception.context!['current'], equals(1500));
    });
  });
}
