import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// バグ報告サービス
class BugReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// バグレポートを送信
  Future<String> submitBugReport({
    required String title,
    required String description,
    required BugCategory category,
    File? screenshot,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // デバイス情報を収集
      final deviceInfo = await _collectDeviceInfo();

      // アプリ情報を収集
      final appInfo = await _collectAppInfo();

      // ログを収集
      final logs = await _collectLogs();

      // スクリーンショットをアップロード
      String? screenshotUrl;
      if (screenshot != null) {
        screenshotUrl = await _uploadScreenshot(screenshot);
      }

      // Firestoreに保存
      final docRef = await _firestore.collection('bugReports').add({
        'title': title,
        'description': description,
        'category': category.name,
        'deviceInfo': deviceInfo,
        'appInfo': appInfo,
        'logs': logs,
        'screenshotUrl': screenshotUrl,
        'additionalData': additionalData,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      logger.info('Bug report submitted', data: {'reportId': docRef.id});
      return docRef.id;
    } catch (e, s) {
      logger.error('Failed to submit bug report',
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// デバイス情報を収集
  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'osVersion': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'iOS',
        'model': iosInfo.model,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
      };
    }

    return {'platform': 'Unknown'};
  }

  /// アプリ情報を収集
  Future<Map<String, dynamic>> _collectAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }

  /// ログを収集
  Future<List<String>> _collectLogs() async {
    // TODO: 実際のログ収集ロジックを実装
    // アプリ内で保存しているログを取得
    logger.info('Log collection is not implemented yet.');
    return [];
  }

  /// スクリーンショットをアップロード
  Future<String> _uploadScreenshot(File screenshot) async {
    final fileName = 'bug_reports/${DateTime.now().millisecondsSinceEpoch}.png';
    final ref = _storage.ref().child(fileName);

    await ref.putFile(screenshot);
    final url = await ref.getDownloadURL();

    return url;
  }

  /// バグレポートの一覧を取得
  Future<List<BugReport>> getBugReports({
    required String userId,
    int limit = 20,
  }) async {
    final snapshot =
        await _firestore
            .collection('bugReports')
            .where('userId', '==', userId)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();

    return snapshot.docs.map((doc) => BugReport.fromFirestore(doc)).toList();
  }

  /// バグレポートの詳細を取得
  Future<BugReport?> getBugReport(String reportId) async {
    final doc = await _firestore.collection('bugReports').doc(reportId).get();

    if (!doc.exists) return null;

    return BugReport.fromFirestore(doc);
  }

  /// バグレポートにコメントを追加
  Future<void> addComment({
    required String reportId,
    required String comment,
    required String userId,
  }) async {
    await _firestore
        .collection('bugReports')
        .doc(reportId)
        .collection('comments')
        .add({
          'comment': comment,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

    await _firestore.collection('bugReports').doc(reportId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });

    logger.info('Comment added to bug report', data: {'reportId': reportId});
  }

  /// バグレポートのステータスを更新
  Future<void> updateStatus({
    required String reportId,
    required BugStatus status,
  }) async {
    await _firestore.collection('bugReports').doc(reportId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    logger.info('Bug report status updated',
        data: {'reportId': reportId, 'newStatus': status.name});
  }

  /// フィードバックを送信（バグではない一般的なフィードバック）
  Future<String> submitFeedback({
    required String title,
    required String description,
    required FeedbackType type,
  }) async {
    final docRef = await _firestore.collection('feedback').add({
      'title': title,
      'description': description,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    logger.info('Feedback submitted', data: {'feedbackId': docRef.id});
    return docRef.id;
  }
}

/// バグレポート
class BugReport {
  final String id;
  final String title;
  final String description;
  final BugCategory category;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> appInfo;
  final List<String> logs;
  final String? screenshotUrl;
  final BugStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BugReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.deviceInfo,
    required this.appInfo,
    required this.logs,
    this.screenshotUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BugReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BugReport(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: BugCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => BugCategory.other,
      ),
      deviceInfo: data['deviceInfo'] ?? {},
      appInfo: data['appInfo'] ?? {},
      logs: List<String>.from(data['logs'] ?? []),
      screenshotUrl: data['screenshotUrl'],
      status: BugStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BugStatus.open,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

/// バグカテゴリー
enum BugCategory {
  crash,
  ui,
  performance,
  data,
  authentication,
  notification,
  other,
}

/// バグステータス
enum BugStatus { open, inProgress, resolved, closed, wontFix }

/// フィードバックタイプ
enum FeedbackType { feature, improvement, question, other }