import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

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
  static IntrusionDetectionService get instance => _instance ??= IntrusionDetectionService._();
  
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
      