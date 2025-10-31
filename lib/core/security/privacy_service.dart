import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:minq/core/security/encryption_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing privacy settings and data protection
class PrivacyService {
  static const String _privacySettingsKey = 'privacy_settings';
  static const String _dataUsageConsentKey = 'data_usage_consent';
  static const String _anonymizationLevelKey = 'anonymization_level';
  
  final EncryptionService _encryptionService = EncryptionService.instance;
  
  static PrivacyService? _instance;
  static PrivacyService get instance => _instance ??= PrivacyService._();
  
  PrivacyService._();
  
  /// Get current privacy settings
  Future<PrivacySettings> getPrivacySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_privacySettingsKey);
      
      if (settingsJson != null) {
        final decryptedJson = _encryptionService.decryptData(settingsJson);
        final settingsMap = jsonDecode(decryptedJson) as Map<String, dynamic>;
        return PrivacySettings.fromJson(settingsMap);
      }
      
      return PrivacySettings.defaultSettings();
    } catch (e) {
      debugPrint('Error getting privacy settings: $e');
      return PrivacySettings.defaultSettings();
    }
  }
  
  /// Update privacy settings
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      final encryptedSettings = _encryptionService.encryptData(settingsJson);
      await prefs.setString(_privacySettingsKey, encryptedSettings);
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      throw const PrivacyException('Failed to update privacy settings');
    }
  }
  
  /// Set data usage consent
  Future<void> setDataUsageConsent(DataUsageConsent consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentJson = jsonEncode(consent.toJson());
      final encryptedConsent = _encryptionService.encryptData(consentJson);
      await prefs.setString(_dataUsageConsentKey, encryptedConsent);
    } catch (e) {
      debugPrint('Error setting data usage consent: $e');
      throw const PrivacyException('Failed to set data usage consent');
    }
  }
  
  /// Get data usage consent
  Future<DataUsageConsent?> getDataUsageConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentJson = prefs.getString(_dataUsageConsentKey);
      
      if (consentJson != null) {
        final decryptedJson = _encryptionService.decryptData(consentJson);
        final consentMap = jsonDecode(decryptedJson) as Map<String, dynamic>;
        return DataUsageConsent.fromJson(consentMap);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting data usage consent: $e');
      return null;
    }
  }
  
  /// Set anonymization level
  Future<void> setAnonymizationLevel(AnonymizationLevel level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_anonymizationLevelKey, level.name);
    } catch (e) {
      debugPrint('Error setting anonymization level: $e');
      throw const PrivacyException('Failed to set anonymization level');
    }
  }
  
  /// Get anonymization level
  Future<AnonymizationLevel> getAnonymizationLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelName = prefs.getString(_anonymizationLevelKey);
      
      if (levelName != null) {
        return AnonymizationLevel.values.firstWhere(
          (level) => level.name == levelName,
          orElse: () => AnonymizationLevel.standard,
        );
      }
      
      return AnonymizationLevel.standard;
    } catch (e) {
      debugPrint('Error getting anonymization level: $e');
      return AnonymizationLevel.standard;
    }
  }
  
  /// Export user data
  Future<String> exportUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exportData = <String, dynamic>{};
      
      // Get all user data keys
      final keys = prefs.getKeys().where((key) => 
        !key.startsWith('encryption_') && 
        !key.startsWith('auth_') &&
        !key.startsWith('biometric_')
      );
      
      for (final key in keys) {
        final value = prefs.get(key);
        if (value != null) {
          exportData[key] = value;
        }
      }
      
      // Add metadata
      exportData['export_timestamp'] = DateTime.now().toIso8601String();
      exportData['export_version'] = '1.0';
      
      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('Error exporting user data: $e');
      throw const PrivacyException('Failed to export user data');
    }
  }
  
  /// Delete all user data
  Future<void> deleteAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all keys except system keys
      final keysToDelete = prefs.getKeys().where((key) => 
        !key.startsWith('flutter.') && 
        !key.startsWith('system_')
      ).toList();
      
      // Delete all user data
      for (final key in keysToDelete) {
        await prefs.remove(key);
      }
      
      // Clear app data directory
      await _clearAppDataDirectory();
      
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      throw const PrivacyException('Failed to delete user data');
    }
  }
  
  /// Clear app data directory
  Future<void> _clearAppDataDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
      }
      
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing app data directory: $e');
    }
  }
  
  /// Anonymize data based on current settings
  Map<String, dynamic> anonymizeData(Map<String, dynamic> data) {
    final anonymizedData = Map<String, dynamic>.from(data);
    final level = getAnonymizationLevel();
    
    return level.then((level) {
      switch (level) {
        case AnonymizationLevel.none:
          return anonymizedData;
        
        case AnonymizationLevel.standard:
          // Remove personally identifiable information
          anonymizedData.remove('email');
          anonymizedData.remove('displayName');
          anonymizedData.remove('phoneNumber');
          
          // Hash user ID
          if (anonymizedData.containsKey('userId')) {
            anonymizedData['userId'] = _encryptionService.hashData(
              anonymizedData['userId'].toString()
            );
          }
          
          return anonymizedData;
        
        case AnonymizationLevel.high:
          // Remove all identifiable information
          final allowedKeys = {
            'questCount',
            'completionRate',
            'streakDays',
            'xpTotal',
            'level',
            'createdAt',
          };
          
          return Map<String, dynamic>.fromEntries(
            anonymizedData.entries.where((entry) => 
              allowedKeys.contains(entry.key)
            ),
          );
      }
    }) as Map<String, dynamic>;
  }
  
  /// Get data usage summary
  Future<DataUsageSummary> getDataUsageSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      var totalDataSize = 0;
      var encryptedDataCount = 0;
      var personalDataCount = 0;
      
      for (final key in keys) {
        final value = prefs.get(key);
        if (value != null) {
          totalDataSize += value.toString().length;
          
          if (key.contains('encrypted') || value.toString().contains(':')) {
            encryptedDataCount++;
          }
          
          if (_isPersonalData(key)) {
            personalDataCount++;
          }
        }
      }
      
      return DataUsageSummary(
        totalDataSize: totalDataSize,
        encryptedDataCount: encryptedDataCount,
        personalDataCount: personalDataCount,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting data usage summary: $e');
      throw const PrivacyException('Failed to get data usage summary');
    }
  }
  
  /// Check if data key contains personal information
  bool _isPersonalData(String key) {
    final personalDataKeys = {
      'email',
      'displayName',
      'phoneNumber',
      'address',
      'profile',
      'user',
    };
    
    return personalDataKeys.any((personalKey) => 
      key.toLowerCase().contains(personalKey)
    );
  }
}

/// Privacy settings model
class PrivacySettings {
  final bool shareAnalytics;
  final bool shareUsageData;
  final bool personalizedAds;
  final bool dataCollection;
  final bool crashReporting;
  final bool performanceMonitoring;
  final AnonymizationLevel anonymizationLevel;
  
  const PrivacySettings({
    required this.shareAnalytics,
    required this.shareUsageData,
    required this.personalizedAds,
    required this.dataCollection,
    required this.crashReporting,
    required this.performanceMonitoring,
    required this.anonymizationLevel,
  });
  
  factory PrivacySettings.defaultSettings() => const PrivacySettings(
    shareAnalytics: false,
    shareUsageData: false,
    personalizedAds: false,
    dataCollection: true,
    crashReporting: true,
    performanceMonitoring: true,
    anonymizationLevel: AnonymizationLevel.standard,
  );
  
  factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
    shareAnalytics: json['shareAnalytics'] as bool? ?? false,
    shareUsageData: json['shareUsageData'] as bool? ?? false,
    personalizedAds: json['personalizedAds'] as bool? ?? false,
    dataCollection: json['dataCollection'] as bool? ?? true,
    crashReporting: json['crashReporting'] as bool? ?? true,
    performanceMonitoring: json['performanceMonitoring'] as bool? ?? true,
    anonymizationLevel: AnonymizationLevel.values.firstWhere(
      (level) => level.name == json['anonymizationLevel'],
      orElse: () => AnonymizationLevel.standard,
    ),
  );
  
  Map<String, dynamic> toJson() => {
    'shareAnalytics': shareAnalytics,
    'shareUsageData': shareUsageData,
    'personalizedAds': personalizedAds,
    'dataCollection': dataCollection,
    'crashReporting': crashReporting,
    'performanceMonitoring': performanceMonitoring,
    'anonymizationLevel': anonymizationLevel.name,
  };
  
  PrivacySettings copyWith({
    bool? shareAnalytics,
    bool? shareUsageData,
    bool? personalizedAds,
    bool? dataCollection,
    bool? crashReporting,
    bool? performanceMonitoring,
    AnonymizationLevel? anonymizationLevel,
  }) => PrivacySettings(
    shareAnalytics: shareAnalytics ?? this.shareAnalytics,
    shareUsageData: shareUsageData ?? this.shareUsageData,
    personalizedAds: personalizedAds ?? this.personalizedAds,
    dataCollection: dataCollection ?? this.dataCollection,
    crashReporting: crashReporting ?? this.crashReporting,
    performanceMonitoring: performanceMonitoring ?? this.performanceMonitoring,
    anonymizationLevel: anonymizationLevel ?? this.anonymizationLevel,
  );
}

/// Data usage consent model
class DataUsageConsent {
  final bool analyticsConsent;
  final bool marketingConsent;
  final bool researchConsent;
  final DateTime consentDate;
  final String consentVersion;
  
  const DataUsageConsent({
    required this.analyticsConsent,
    required this.marketingConsent,
    required this.researchConsent,
    required this.consentDate,
    required this.consentVersion,
  });
  
  factory DataUsageConsent.fromJson(Map<String, dynamic> json) => DataUsageConsent(
    analyticsConsent: json['analyticsConsent'] as bool,
    marketingConsent: json['marketingConsent'] as bool,
    researchConsent: json['researchConsent'] as bool,
    consentDate: DateTime.parse(json['consentDate'] as String),
    consentVersion: json['consentVersion'] as String,
  );
  
  Map<String, dynamic> toJson() => {
    'analyticsConsent': analyticsConsent,
    'marketingConsent': marketingConsent,
    'researchConsent': researchConsent,
    'consentDate': consentDate.toIso8601String(),
    'consentVersion': consentVersion,
  };
}

/// Data usage summary model
class DataUsageSummary {
  final int totalDataSize;
  final int encryptedDataCount;
  final int personalDataCount;
  final DateTime lastUpdated;
  
  const DataUsageSummary({
    required this.totalDataSize,
    required this.encryptedDataCount,
    required this.personalDataCount,
    required this.lastUpdated,
  });
}

/// Anonymization levels
enum AnonymizationLevel {
  none,
  standard,
  high,
}

/// Custom exception for privacy errors
class PrivacyException implements Exception {
  final String message;
  
  const PrivacyException(this.message);
  
  @override
  String toString() => 'PrivacyException: $message';
}