import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:minq/core/security/encryption_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling biometric and PIN authentication
class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinHashKey = 'pin_hash';
  static const String _authAttemptsKey = 'auth_attempts';
  static const String _lockoutTimeKey = 'lockout_time';
  static const int _maxAttempts = 5;
  static const int _lockoutDurationMinutes = 30;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final EncryptionService _encryptionService = EncryptionService.instance;

  static BiometricService? _instance;
  static BiometricService get instance => _instance ??= BiometricService._();

  BiometricService._();

  /// Check if biometric authentication is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw const AuthenticationException(
          'Biometric authentication not available',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for MinQ',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledKey, true);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
      throw const AuthenticationException(
        'Failed to enable biometric authentication',
      );
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Authenticate using biometric
  Future<bool> authenticateWithBiometric() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        throw const AuthenticationException(
          'Biometric authentication not enabled',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access MinQ',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await _resetAuthAttempts();
      }

      return authenticated;
    } catch (e) {
      debugPrint('Error authenticating with biometric: $e');
      return false;
    }
  }

  /// Set PIN for authentication
  Future<bool> setPIN(String pin) async {
    try {
      if (pin.length < 4 || pin.length > 8) {
        throw const AuthenticationException('PIN must be 4-8 digits');
      }

      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        throw const AuthenticationException('PIN must contain only digits');
      }

      final hashedPin = _encryptionService.hashData(pin);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinHashKey, hashedPin);

      return true;
    } catch (e) {
      debugPrint('Error setting PIN: $e');
      throw const AuthenticationException('Failed to set PIN');
    }
  }

  /// Check if PIN is set
  Future<bool> isPINSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinHashKey) != null;
  }

  /// Authenticate using PIN
  Future<bool> authenticateWithPIN(String pin) async {
    try {
      // Check if account is locked out
      if (await _isLockedOut()) {
        throw const AuthenticationException(
          'Account temporarily locked due to too many failed attempts',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_pinHashKey);

      if (storedHash == null) {
        throw const AuthenticationException('PIN not set');
      }

      final isValid = _encryptionService.verifyHash(pin, storedHash);

      if (isValid) {
        await _resetAuthAttempts();
        return true;
      } else {
        await _incrementAuthAttempts();
        return false;
      }
    } catch (e) {
      debugPrint('Error authenticating with PIN: $e');
      if (e is AuthenticationException) rethrow;
      throw const AuthenticationException('Authentication failed');
    }
  }

  /// Remove PIN authentication
  Future<void> removePIN() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    await _resetAuthAttempts();
  }

  /// Get remaining authentication attempts
  Future<int> getRemainingAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_authAttemptsKey) ?? 0;
    return _maxAttempts - attempts;
  }

  /// Check if account is locked out
  Future<bool> _isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTime = prefs.getInt(_lockoutTimeKey);

    if (lockoutTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockoutEnd = lockoutTime + (_lockoutDurationMinutes * 60 * 1000);

    if (now < lockoutEnd) {
      return true;
    } else {
      // Lockout period has ended, reset attempts
      await _resetAuthAttempts();
      return false;
    }
  }

  /// Get lockout end time
  Future<DateTime?> getLockoutEndTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTime = prefs.getInt(_lockoutTimeKey);

    if (lockoutTime == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(
      lockoutTime + (_lockoutDurationMinutes * 60 * 1000),
    );
  }

  /// Increment authentication attempts
  Future<void> _incrementAuthAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_authAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_authAttemptsKey, attempts);

    if (attempts >= _maxAttempts) {
      // Lock out the account
      final lockoutTime = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lockoutTimeKey, lockoutTime);
    }
  }

  /// Reset authentication attempts
  Future<void> _resetAuthAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authAttemptsKey);
    await prefs.remove(_lockoutTimeKey);
  }

  /// Authenticate using available methods (biometric or PIN)
  Future<AuthenticationResult> authenticate() async {
    try {
      // Check if account is locked out
      if (await _isLockedOut()) {
        final lockoutEnd = await getLockoutEndTime();
        return AuthenticationResult.lockedOut(lockoutEnd);
      }

      // Try biometric first if available and enabled
      final biometricEnabled = await isBiometricEnabled();
      if (biometricEnabled) {
        try {
          final success = await authenticateWithBiometric();
          if (success) {
            return AuthenticationResult.success(AuthMethod.biometric);
          }
        } catch (e) {
          debugPrint(
            'Biometric authentication failed, falling back to PIN: $e',
          );
        }
      }

      // Fall back to PIN if biometric fails or not available
      final pinSet = await isPINSet();
      if (pinSet) {
        return AuthenticationResult.pinRequired();
      }

      // No authentication method available
      return AuthenticationResult.noAuthMethod();
    } catch (e) {
      debugPrint('Authentication error: $e');
      return AuthenticationResult.error(e.toString());
    }
  }
}

/// Authentication result
class AuthenticationResult {
  final AuthStatus status;
  final AuthMethod? method;
  final String? error;
  final DateTime? lockoutEnd;

  const AuthenticationResult._({
    required this.status,
    this.method,
    this.error,
    this.lockoutEnd,
  });

  factory AuthenticationResult.success(AuthMethod method) =>
      AuthenticationResult._(status: AuthStatus.success, method: method);

  factory AuthenticationResult.pinRequired() =>
      const AuthenticationResult._(status: AuthStatus.pinRequired);

  factory AuthenticationResult.lockedOut(DateTime? lockoutEnd) =>
      AuthenticationResult._(
        status: AuthStatus.lockedOut,
        lockoutEnd: lockoutEnd,
      );

  factory AuthenticationResult.noAuthMethod() =>
      const AuthenticationResult._(status: AuthStatus.noAuthMethod);

  factory AuthenticationResult.error(String error) =>
      AuthenticationResult._(status: AuthStatus.error, error: error);

  bool get isSuccess => status == AuthStatus.success;
  bool get requiresPIN => status == AuthStatus.pinRequired;
  bool get isLockedOut => status == AuthStatus.lockedOut;
  bool get hasError => status == AuthStatus.error;
}

/// Authentication status
enum AuthStatus { success, pinRequired, lockedOut, noAuthMethod, error }

/// Authentication method
enum AuthMethod { biometric, pin }

/// Custom exception for authentication errors
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
