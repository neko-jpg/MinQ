import 'package:flutter/foundation.dart';

/// Base exception class for all MinQ application exceptions
abstract class MinqException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  const MinqException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
    this.context,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('${runtimeType}: $message');
    
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    
    if (context != null && context!.isNotEmpty) {
      buffer.write(' [context: $context]');
    }
    
    if (originalError != null) {
      buffer.write(' [original: $originalError]');
    }
    
    return buffer.toString();
  }

  /// Convert exception to a map for logging
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      if (code != null) 'code': code,
      if (context != null) 'context': context,
      if (originalError != null) 'originalError': originalError.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// AI service related exceptions
class AIServiceException extends MinqException {
  const AIServiceException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// AI model loading failed
  factory AIServiceException.modelLoadFailed(dynamic error, [StackTrace? stackTrace]) {
    return AIServiceException(
      'Failed to load AI model',
      code: 'AI_MODEL_LOAD_FAILED',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// AI inference failed
  factory AIServiceException.inferenceFailed(dynamic error, [StackTrace? stackTrace]) {
    return AIServiceException(
      'AI inference failed',
      code: 'AI_INFERENCE_FAILED',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// AI service unavailable
  factory AIServiceException.serviceUnavailable([String? reason]) {
    return AIServiceException(
      'AI service is currently unavailable${reason != null ? ': $reason' : ''}',
      code: 'AI_SERVICE_UNAVAILABLE',
    );
  }

  /// Invalid AI input
  factory AIServiceException.invalidInput(String details) {
    return AIServiceException(
      'Invalid input provided to AI service: $details',
      code: 'AI_INVALID_INPUT',
    );
  }
}

/// Database related exceptions
class DatabaseException extends MinqException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// Database connection failed
  factory DatabaseException.connectionFailed(dynamic error, [StackTrace? stackTrace]) {
    return DatabaseException(
      'Failed to connect to database',
      code: 'DB_CONNECTION_FAILED',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Database operation failed
  factory DatabaseException.operationFailed(String operation, dynamic error, [StackTrace? stackTrace]) {
    return DatabaseException(
      'Database operation failed: $operation',
      code: 'DB_OPERATION_FAILED',
      originalError: error,
      stackTrace: stackTrace,
      context: {'operation': operation},
    );
  }

  /// Data not found
  factory DatabaseException.notFound(String resource, [String? id]) {
    return DatabaseException(
      'Resource not found: $resource${id != null ? ' (id: $id)' : ''}',
      code: 'DB_NOT_FOUND',
      context: {'resource': resource, if (id != null) 'id': id},
    );
  }

  /// Data validation failed
  factory DatabaseException.validationFailed(String details) {
    return DatabaseException(
      'Data validation failed: $details',
      code: 'DB_VALIDATION_FAILED',
      context: {'details': details},
    );
  }

  /// Database schema migration failed
  factory DatabaseException.migrationFailed(int version, dynamic error, [StackTrace? stackTrace]) {
    return DatabaseException(
      'Database migration failed for version $version',
      code: 'DB_MIGRATION_FAILED',
      originalError: error,
      stackTrace: stackTrace,
      context: {'version': version},
    );
  }
}

/// Network related exceptions
class NetworkException extends MinqException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// No internet connection
  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection available',
      code: 'NETWORK_NO_CONNECTION',
    );
  }

  /// Request timeout
  factory NetworkException.timeout(Duration timeout) {
    return NetworkException(
      'Request timed out after ${timeout.inSeconds} seconds',
      code: 'NETWORK_TIMEOUT',
      context: {'timeout': timeout.inSeconds},
    );
  }

  /// Server error
  factory NetworkException.serverError(int statusCode, [String? message]) {
    return NetworkException(
      'Server error: ${message ?? 'HTTP $statusCode'}',
      code: 'NETWORK_SERVER_ERROR',
      context: {'statusCode': statusCode, if (message != null) 'message': message},
    );
  }

  /// Request failed
  factory NetworkException.requestFailed(String url, dynamic error, [StackTrace? stackTrace]) {
    return NetworkException(
      'Network request failed: $url',
      code: 'NETWORK_REQUEST_FAILED',
      originalError: error,
      stackTrace: stackTrace,
      context: {'url': url},
    );
  }

  /// Rate limit exceeded
  factory NetworkException.rateLimitExceeded([Duration? retryAfter]) {
    return NetworkException(
      'Rate limit exceeded${retryAfter != null ? ', retry after ${retryAfter.inSeconds}s' : ''}',
      code: 'NETWORK_RATE_LIMIT',
      context: {if (retryAfter != null) 'retryAfter': retryAfter.inSeconds},
    );
  }
}

/// Authentication related exceptions
class AuthException extends MinqException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// User not authenticated
  factory AuthException.notAuthenticated() {
    return const AuthException(
      'User is not authenticated',
      code: 'AUTH_NOT_AUTHENTICATED',
    );
  }

  /// Authentication failed
  factory AuthException.authenticationFailed(dynamic error, [StackTrace? stackTrace]) {
    return AuthException(
      'Authentication failed',
      code: 'AUTH_FAILED',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Insufficient permissions
  factory AuthException.insufficientPermissions(String resource) {
    return AuthException(
      'Insufficient permissions to access: $resource',
      code: 'AUTH_INSUFFICIENT_PERMISSIONS',
      context: {'resource': resource},
    );
  }

  /// Token expired
  factory AuthException.tokenExpired() {
    return const AuthException(
      'Authentication token has expired',
      code: 'AUTH_TOKEN_EXPIRED',
    );
  }
}

/// Validation related exceptions
class ValidationException extends MinqException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// Field validation failed
  factory ValidationException.fieldValidation(String field, String reason) {
    return ValidationException(
      'Validation failed for field "$field": $reason',
      code: 'VALIDATION_FIELD_FAILED',
      context: {'field': field, 'reason': reason},
    );
  }

  /// Required field missing
  factory ValidationException.requiredField(String field) {
    return ValidationException(
      'Required field is missing: $field',
      code: 'VALIDATION_REQUIRED_FIELD',
      context: {'field': field},
    );
  }

  /// Invalid format
  factory ValidationException.invalidFormat(String field, String expectedFormat) {
    return ValidationException(
      'Invalid format for field "$field", expected: $expectedFormat',
      code: 'VALIDATION_INVALID_FORMAT',
      context: {'field': field, 'expectedFormat': expectedFormat},
    );
  }
}

/// Storage related exceptions
class StorageException extends MinqException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// File not found
  factory StorageException.fileNotFound(String path) {
    return StorageException(
      'File not found: $path',
      code: 'STORAGE_FILE_NOT_FOUND',
      context: {'path': path},
    );
  }

  /// Upload failed
  factory StorageException.uploadFailed(String path, dynamic error, [StackTrace? stackTrace]) {
    return StorageException(
      'File upload failed: $path',
      code: 'STORAGE_UPLOAD_FAILED',
      originalError: error,
      stackTrace: stackTrace,
      context: {'path': path},
    );
  }

  /// Insufficient storage space
  factory StorageException.insufficientSpace(int requiredBytes, int availableBytes) {
    return StorageException(
      'Insufficient storage space. Required: ${requiredBytes}B, Available: ${availableBytes}B',
      code: 'STORAGE_INSUFFICIENT_SPACE',
      context: {'requiredBytes': requiredBytes, 'availableBytes': availableBytes},
    );
  }
}

/// Configuration related exceptions
class ConfigurationException extends MinqException {
  const ConfigurationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// Missing configuration
  factory ConfigurationException.missingConfig(String key) {
    return ConfigurationException(
      'Missing required configuration: $key',
      code: 'CONFIG_MISSING',
      context: {'key': key},
    );
  }

  /// Invalid configuration
  factory ConfigurationException.invalidConfig(String key, String reason) {
    return ConfigurationException(
      'Invalid configuration for "$key": $reason',
      code: 'CONFIG_INVALID',
      context: {'key': key, 'reason': reason},
    );
  }
}

/// Business logic related exceptions
class BusinessLogicException extends MinqException {
  const BusinessLogicException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });

  /// Operation not allowed
  factory BusinessLogicException.operationNotAllowed(String operation, String reason) {
    return BusinessLogicException(
      'Operation not allowed: $operation. Reason: $reason',
      code: 'BUSINESS_OPERATION_NOT_ALLOWED',
      context: {'operation': operation, 'reason': reason},
    );
  }

  /// Resource conflict
  factory BusinessLogicException.resourceConflict(String resource, String details) {
    return BusinessLogicException(
      'Resource conflict: $resource. Details: $details',
      code: 'BUSINESS_RESOURCE_CONFLICT',
      context: {'resource': resource, 'details': details},
    );
  }

  /// Quota exceeded
  factory BusinessLogicException.quotaExceeded(String resource, int limit, int current) {
    return BusinessLogicException(
      'Quota exceeded for $resource. Limit: $limit, Current: $current',
      code: 'BUSINESS_QUOTA_EXCEEDED',
      context: {'resource': resource, 'limit': limit, 'current': current},
    );
  }
}

/// Exception utility functions
class ExceptionUtils {
  /// Check if an exception is retryable
  static bool isRetryable(dynamic exception) {
    if (exception is NetworkException) {
      return exception.code != 'NETWORK_NO_CONNECTION';
    }
    
    if (exception is DatabaseException) {
      return exception.code == 'DB_CONNECTION_FAILED' || 
             exception.code == 'DB_OPERATION_FAILED';
    }
    
    if (exception is AIServiceException) {
      return exception.code == 'AI_SERVICE_UNAVAILABLE';
    }
    
    return false;
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic exception) {
    if (exception is MinqException) {
      switch (exception.code) {
        case 'NETWORK_NO_CONNECTION':
          return 'インターネット接続を確認してください';
        case 'NETWORK_TIMEOUT':
          return 'リクエストがタイムアウトしました。もう一度お試しください';
        case 'AUTH_NOT_AUTHENTICATED':
          return 'ログインが必要です';
        case 'DB_NOT_FOUND':
          return 'データが見つかりませんでした';
        case 'AI_SERVICE_UNAVAILABLE':
          return 'AI機能は現在利用できません';
        case 'STORAGE_INSUFFICIENT_SPACE':
          return 'ストレージ容量が不足しています';
        default:
          return 'エラーが発生しました。しばらく待ってからもう一度お試しください';
      }
    }
    
    return '予期しないエラーが発生しました';
  }

  /// Extract error code from any exception
  static String? getErrorCode(dynamic exception) {
    if (exception is MinqException) {
      return exception.code;
    }
    return null;
  }

  /// Create MinqException from any error
  static MinqException fromError(dynamic error, [StackTrace? stackTrace]) {
    if (error is MinqException) {
      return error;
    }
    
    // Try to categorize the error
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return NetworkException.requestFailed('unknown', error, stackTrace);
    }
    
    if (errorString.contains('database') || 
        errorString.contains('firestore') ||
        errorString.contains('isar')) {
      return DatabaseException.operationFailed('unknown', error, stackTrace);
    }
    
    if (errorString.contains('auth') || 
        errorString.contains('permission')) {
      return AuthException.authenticationFailed(error, stackTrace);
    }
    
    // Default to generic MinqException
    return _GenericMinqException(
      'An unexpected error occurred: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Generic MinqException for unknown errors
class _GenericMinqException extends MinqException {
  const _GenericMinqException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
    super.context,
  });
}