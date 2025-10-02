import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CrashReport {
  CrashReport({
    required this.message,
    required this.stackTrace,
    required this.recordedAt,
  });

  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      message: json['message'] as String? ?? 'Unknown Error',
      stackTrace: json['stackTrace'] as String? ?? '',
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String message;
  final String stackTrace;
  final DateTime recordedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'message': message,
      'stackTrace': stackTrace,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
    };
  }
}

class CrashRecoveryStore {
  CrashRecoveryStore(this._prefs);

  static const String _crashReportKey = 'crash_report_v1';

  final SharedPreferences _prefs;

  CrashReport? get pendingReport {
    final String? raw = _prefs.getString(_crashReportKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return CrashReport.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> recordCrash(CrashReport report) async {
    await _prefs.setString(_crashReportKey, jsonEncode(report.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_crashReportKey);
  }
}
