import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight storage wrapper that can operate on shared preferences or
/// fall back to an in-memory map when preferences are unavailable.
class LocalStorageService {
  LocalStorageService({SharedPreferences? prefs})
      : _prefs = prefs,
        _memory = <String, Object?>{};

  final SharedPreferences? _prefs;
  final Map<String, Object?> _memory;

  bool get _usingMemory => _prefs == null;

  static const String _sessionStorageKey = '__uba_session_cache__';
  static const String _analyticsStorageKey = '__uba_analytics_cache__';
  static const int _maxStoredSessions = 200;

  Future<void> setString(String key, String value) async {
    if (_usingMemory) {
      _memory[key] = value;
    } else {
      await _prefs!.setString(key, value);
    }
  }

  Future<String?> getString(String key) async {
    if (_usingMemory) {
      final value = _memory[key];
      return value is String ? value : null;
    }
    return _prefs!.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    if (_usingMemory) {
      _memory[key] = value;
    } else {
      await _prefs!.setBool(key, value);
    }
  }

  Future<bool?> getBool(String key) async {
    if (_usingMemory) {
      final value = _memory[key];
      return value is bool ? value : null;
    }
    return _prefs!.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    if (_usingMemory) {
      _memory[key] = value;
    } else {
      await _prefs!.setInt(key, value);
    }
  }

  Future<int?> getInt(String key) async {
    if (_usingMemory) {
      final value = _memory[key];
      return value is int ? value : null;
    }
    return _prefs!.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    if (_usingMemory) {
      _memory[key] = value;
    } else {
      await _prefs!.setDouble(key, value);
    }
  }

  Future<double?> getDouble(String key) async {
    if (_usingMemory) {
      final value = _memory[key];
      return value is double ? value : null;
    }
    return _prefs!.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    if (_usingMemory) {
      _memory[key] = List<String>.from(value);
    } else {
      await _prefs!.setStringList(key, value);
    }
  }

  Future<List<String>?> getStringList(String key) async {
    if (_usingMemory) {
      final value = _memory[key];
      return value is List<String> ? List<String>.from(value) : null;
    }
    final list = _prefs!.getStringList(key);
    return list == null ? null : List<String>.from(list);
  }

  Future<void> remove(String key) async {
    if (_usingMemory) {
      _memory.remove(key);
    } else {
      await _prefs!.remove(key);
    }
  }

  Future<void> clear() async {
    if (_usingMemory) {
      _memory.clear();
    } else {
      await _prefs!.clear();
    }
  }

  bool containsKey(String key) {
    return _usingMemory ? _memory.containsKey(key) : _prefs!.containsKey(key);
  }

  Set<String> getKeys() {
    return _usingMemory ? _memory.keys.toSet() : _prefs!.getKeys();
  }

  Future<void> storeSessionData(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final sessions = await getSessionData();
    sessions.removeWhere(
      (session) => session['session_id'] == sessionId,
    );
    final enriched = Map<String, dynamic>.from(data)
      ..['session_id'] = sessionId;
    sessions.add(enriched);
    if (sessions.length > _maxStoredSessions) {
      sessions.removeRange(0, sessions.length - _maxStoredSessions);
    }
    await setString(_sessionStorageKey, jsonEncode(sessions));
  }

  Future<List<Map<String, dynamic>>> getSessionData() async {
    final raw = await getString(_sessionStorageKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((value) => Map<String, dynamic>.from(value))
            .toList();
      }
    } catch (_) {
      // Ignore corrupted payload and fall back to empty list.
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> storeAnalyticsData(Map<String, dynamic> data) async {
    await setString(_analyticsStorageKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getAnalyticsData() async {
    final raw = await getString(_analyticsStorageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      await remove(_analyticsStorageKey);
    }
    return null;
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be overridden');
});
