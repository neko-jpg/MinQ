import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:minq/core/security/encryption_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for detecting and preventing unauthorized access
class IntrusionDetectionService {
  static const String _deviceFingerprintKey = 'device_fingerprint';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _suspiciousActivityKey = 'suspicious_activity';
  static const String _trustedDevicesKey = 'trusted_devices';
  static const String _securityEventsKey = 'security_events';

  static const int _maxLoginAttempts = 5;
  static const int _suspiciousThreshold = 3;

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final EncryptionService _encryptionService = EncryptionService.instance;

  static IntrusionDetectionService? _instance;
  static IntrusionDetectionService get instance =>
      _instance ??= IntrusionDetectionService._();

  IntrusionDetectionService._();

  /// Initialize intrusion detection
  Future<void> initialize() async {
    await _generateDeviceFingerprint();
    await _cleanupOldEvents();
  }

  /// Generate unique device fingerprint
  Future<String> _generateDeviceFingerprint() async {
    try {
      final deviceData = <String, dynamic>{};

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData.addAll({
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'hardware': androidInfo.hardware,
          'androidId': androidInfo.id,
        });
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData.addAll({
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        });
      }

      final fingerprintData = jsonEncode(deviceData);
      final fingerprint = _encryptionService.hashData(fingerprintData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceFingerprintKey, fingerprint);

      return fingerprint;
    } catch (e) {
      debugPrint('Error generating device fingerprint: $e');
      return 'unknown_device';
    }
  }

  /// Check if device is trusted
  Future<bool> isDeviceTrusted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedFingerprint = prefs.getString(_deviceFingerprintKey);
      final currentFingerprint = await _generateDeviceFingerprint();

      if (storedFingerprint == null) {
        await _addTrustedDevice(currentFingerprint);
        return true;
      }

      final trustedDevices = await _getTrustedDevices();
      return trustedDevices.contains(currentFingerprint);
    } catch (e) {
      debugPrint('Error checking device trust: $e');
      return false;
    }
  }

  /// Record login attempt
  Future<bool> recordLoginAttempt(String userId, bool success) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attemptsKey = '${_loginAttemptsKey}_$userId';
      final attempts = prefs.getInt(attemptsKey) ?? 0;

      if (success) {
        await prefs.remove(attemptsKey);
        await _logSecurityEvent('login_success', userId);
        return true;
      } else {
        final newAttempts = attempts + 1;
        await prefs.setInt(attemptsKey, newAttempts);
        await _logSecurityEvent('login_failed', userId, {
          'attempts': newAttempts,
        });

        if (newAttempts >= _maxLoginAttempts) {
          await _lockAccount(userId);
          return false;
        }

        return newAttempts < _maxLoginAttempts;
      }
    } catch (e) {
      debugPrint('Error recording login attempt: $e');
      return false;
    }
  }

  /// Check if account is locked
  Future<bool> isAccountLocked(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attemptsKey = '${_loginAttemptsKey}_$userId';
      final attempts = prefs.getInt(attemptsKey) ?? 0;
      return attempts >= _maxLoginAttempts;
    } catch (e) {
      debugPrint('Error checking account lock: $e');
      return false;
    }
  }

  /// Detect suspicious activity
  Future<bool> detectSuspiciousActivity(String userId, String activity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suspiciousKey = '${_suspiciousActivityKey}_$userId';
      final suspiciousCount = prefs.getInt(suspiciousKey) ?? 0;

      final newCount = suspiciousCount + 1;
      await prefs.setInt(suspiciousKey, newCount);

      await _logSecurityEvent('suspicious_activity', userId, {
        'activity': activity,
        'count': newCount,
      });

      if (newCount >= _suspiciousThreshold) {
        await _triggerSecurityAlert(userId, activity);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error detecting suspicious activity: $e');
      return false;
    }
  }

  /// Get trusted devices
  Future<List<String>> _getTrustedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getString(_trustedDevicesKey);
      if (devicesJson == null) return [];

      final devicesList = jsonDecode(devicesJson) as List;
      return devicesList.cast<String>();
    } catch (e) {
      debugPrint('Error getting trusted devices: $e');
      return [];
    }
  }

  /// Add trusted device
  Future<void> _addTrustedDevice(String fingerprint) async {
    try {
      final trustedDevices = await _getTrustedDevices();
      if (!trustedDevices.contains(fingerprint)) {
        trustedDevices.add(fingerprint);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_trustedDevicesKey, jsonEncode(trustedDevices));
      }
    } catch (e) {
      debugPrint('Error adding trusted device: $e');
    }
  }

  /// Lock account
  Future<void> _lockAccount(String userId) async {
    try {
      await _logSecurityEvent('account_locked', userId);
      await _triggerSecurityAlert(userId, 'account_locked');
    } catch (e) {
      debugPrint('Error locking account: $e');
    }
  }

  /// Log security event
  Future<void> _logSecurityEvent(
    String eventType,
    String userId, [
    Map<String, dynamic>? metadata,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_securityEventsKey) ?? '[]';
      final events = jsonDecode(eventsJson) as List;

      final event = {
        'type': eventType,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      };

      events.add(event);

      // Keep only last 100 events
      if (events.length > 100) {
        events.removeRange(0, events.length - 100);
      }

      await prefs.setString(_securityEventsKey, jsonEncode(events));
    } catch (e) {
      debugPrint('Error logging security event: $e');
    }
  }

  /// Trigger security alert
  Future<void> _triggerSecurityAlert(String userId, String reason) async {
    try {
      await _logSecurityEvent('security_alert', userId, {'reason': reason});
      // Here you could send notifications, emails, etc.
      debugPrint('Security alert triggered for user $userId: $reason');
    } catch (e) {
      debugPrint('Error triggering security alert: $e');
    }
  }

  /// Clean up old events
  Future<void> _cleanupOldEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_securityEventsKey) ?? '[]';
      final events = jsonDecode(eventsJson) as List;

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      events.removeWhere((event) {
        final timestamp = DateTime.parse(event['timestamp']);
        return timestamp.isBefore(cutoffDate);
      });

      await prefs.setString(_securityEventsKey, jsonEncode(events));
    } catch (e) {
      debugPrint('Error cleaning up old events: $e');
    }
  }

  /// Reset security data for user
  Future<void> resetSecurityData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_loginAttemptsKey}_$userId');
      await prefs.remove('${_suspiciousActivityKey}_$userId');
      await _logSecurityEvent('security_reset', userId);
    } catch (e) {
      debugPrint('Error resetting security data: $e');
    }
  }

  /// Get security events for user
  Future<List<Map<String, dynamic>>> getSecurityEvents(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_securityEventsKey) ?? '[]';
      final allEvents = jsonDecode(eventsJson) as List;

      return allEvents
          .cast<Map<String, dynamic>>()
          .where((event) => event['userId'] == userId)
          .toList();
    } catch (e) {
      debugPrint('Error getting security events: $e');
      return [];
    }
  }
}
