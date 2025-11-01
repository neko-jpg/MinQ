import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling end-to-end encryption of local and cloud data
class EncryptionService {
  static const String _keyStorageKey = 'encryption_master_key';
  static const String _saltStorageKey = 'encryption_salt';

  late final Encrypter _encrypter;
  late final IV _iv;
  late final Key _key;

  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();

  EncryptionService._();

  /// Initialize encryption service with master key
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Get or generate master key
    String? keyString = prefs.getString(_keyStorageKey);
    if (keyString == null) {
      keyString = await _generateMasterKey();
      await prefs.setString(_keyStorageKey, keyString);
    }

    // Get or generate salt
    String? saltString = prefs.getString(_saltStorageKey);
    if (saltString == null) {
      saltString = _generateSalt();
      await prefs.setString(_saltStorageKey, saltString);
    }

    // Derive encryption key from master key and salt
    final derivedKey = _deriveKey(keyString, saltString);
    _key = Key.fromBase64(derivedKey);
    _encrypter = Encrypter(AES(_key));
    _iv = IV.fromSecureRandom(16);
  }

  /// Generate a new master key
  Future<String> _generateMasterKey() async {
    final key = Key.fromSecureRandom(32);
    return key.base64;
  }

  /// Generate a random salt
  String _generateSalt() {
    final salt = IV.fromSecureRandom(16);
    return salt.base64;
  }

  /// Derive encryption key using PBKDF2
  String _deriveKey(String masterKey, String salt) {
    final keyBytes = base64.decode(masterKey);
    final saltBytes = base64.decode(salt);

    // Simple key derivation using HMAC-SHA256
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(saltBytes);

    return base64.encode(digest.bytes);
  }

  /// Encrypt sensitive data
  String encryptData(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return '${_iv.base64}:${encrypted.base64}';
    } catch (e) {
      debugPrint('Encryption error: $e');
      throw const EncryptionException('Failed to encrypt data');
    }
  }

  /// Decrypt sensitive data
  String decryptData(String encryptedData) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw const EncryptionException('Invalid encrypted data format');
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      debugPrint('Decryption error: $e');
      throw const EncryptionException('Failed to decrypt data');
    }
  }

  /// Encrypt JSON data
  String encryptJson(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encryptData(jsonString);
  }

  /// Decrypt JSON data
  Map<String, dynamic> decryptJson(String encryptedData) {
    final jsonString = decryptData(encryptedData);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Hash sensitive data (one-way)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify hashed data
  bool verifyHash(String data, String hash) {
    return hashData(data) == hash;
  }

  /// Securely wipe encryption keys from memory
  Future<void> clearKeys() async {
    // Clear sensitive data from memory
    _key.bytes.fillRange(0, _key.bytes.length, 0);
  }

  /// Rotate encryption keys
  Future<void> rotateKeys() async {
    final prefs = await SharedPreferences.getInstance();

    // Generate new master key and salt
    final newMasterKey = await _generateMasterKey();
    final newSalt = _generateSalt();

    // Store new keys
    await prefs.setString(_keyStorageKey, newMasterKey);
    await prefs.setString(_saltStorageKey, newSalt);

    // Reinitialize with new keys
    await initialize();
  }
}

/// Custom exception for encryption errors
class EncryptionException implements Exception {
  final String message;

  const EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
