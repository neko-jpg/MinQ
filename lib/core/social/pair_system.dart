import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/deeplink/deeplink_handler.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/core/notifications/push_notification_handler.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair_connection.dart';
import 'package:minq/domain/pair/pair_invitation.dart';
import 'package:minq/domain/pair/pair_message.dart';
import 'package:minq/domain/pair/progress_share.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Provider for the pair system
final pairSystemProvider = Provider<PairSystem>((ref) {
  return PairSystem(
    firestore: FirebaseFirestore.instance,
    notificationHandler: ref.watch(pushNotificationHandlerProvider),
  );
});

/// 包括的なペアシステム
/// 
/// 友人との習慣化を支援する機能を提供:
/// - フレンド招待（QRコード・ディープリンク）
/// - リアルタイムチャット
/// - 進捗共有と通知
/// - ペア統計・比較ダッシュボード
class PairSystem {
  final FirebaseFirestore _firestore;
  final PushNotificationHandler _notificationHandler;
  final Random _random = Random();

  PairSystem({
    required FirebaseFirestore firestore,
    required PushNotificationHandler notificationHandler,
  }) : _firestore = firestore,
       _notificationHandler = notificationHandler;

  // ==================== 招待機能 ====================

  /// ペア招待を作成（QRコード・ディープリンク付き）
  Future<PairInvitation> createInvitation({
    required String userId,
    required String category,
    String? customMessage,
  }) async {
    try {
      final inviteCode = _generateInviteCode();
      final deepLink = DeepLinkHandler.generateUrl(
        type: DeepLinkType.pairMatching,
        parameters: {'code': inviteCode},
      );
      final webLink = DeepLinkHandler.generateWebUrl(
        type: DeepLinkType.pairMatching,
        parameters: {'code': inviteCode},
      );

      final invitation = PairInvitation(
        id: _generateId(),
        inviterId: userId,
        inviteCode: inviteCode,
        category: category,
        deepLink: deepLink,
        webLink: webLink,
        qrCodeData: await _generateQRCodeData(deepLink),
        customMessage: customMessage,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('pair_invitations')
          .doc(invitation.id)
          .set(invitation.toFirestore());

      logger.info('Created pair invitation: ${invitation.inviteCode}');
      return invitation;
    } catch (e) {
      logger.error('Failed to create pair invitation: $e');
      rethrow;
    }
  }

  /// 招待コードでペアに参加
  Future<PairConnection?> acceptInvitation({
    required String inviteCode,
    required String userId,
  }) async {
    try {
      final invitation = await _getInvitationByCode(inviteCode);
      
      if (invitation == null) {
        logger.warn('Invalid invitation code: $inviteCode');
        return null;
      }

      if (invitation.isExpired) {
        logger.warn('Expired invitation code: $inviteCode');
        await _deactivateInvitation(invitation.id);
        return null;
      }

      if (invitation.inviterId == userId) {
        logger.warn('User trying to accept own invitation: $userId');
        return null;
      }

      // 既存のペア接続をチェック
      final existingConnection = await _getActiveConnection(userId);
      if (existingConnection != null) {
        logger.warn('User already has active pair connection: $userId');
        return null;
      }

      // ペア接続を作成
      final connection = PairConnection(
        id: _generateId(),
        user1Id: invitation.inviterId,
        user2Id: userId,
        status: PairStatus.active,
        category: invitation.category,
        createdAt: DateTime.now(),
        settings: PairSettings.defaultSettings(),
        statistics: PairStatistics.empty(),
      );

      await _firestore
          .collection('pair_connections')
          .doc(connection.id)
          .set(connection.toFirestore());

      // 招待を無効化
      await _deactivateInvitation(invitation.id);

      // 招待者に通知
      await _notificationHandler.sendPairAcceptedNotification(
        invitation.inviterId,
        userId,
      );

      logger.info('Pair connection created: ${connection.id}');
      return connection;
    } catch (e) {
      logger.error('Failed to accept invitation: $e');
      rethrow;
    }
  }

  // ==================== 進捗共有機能 ====================

  /// 進捗を共有
  Future<void> shareProgress({
    required String pairId,
    required ProgressShare share,
  }) async {
    try {
      final connection = await _getConnection(pairId);
      if (connection == null || !connection.isActive) {
        throw const PairException('Invalid or inactive pair connection');
      }

      // 進捗共有を保存
      await _firestore
          .collection('pair_connections')
          .doc(pairId)
          .collection('progress_shares')
          .add(share.toFirestore());

      // パートナーに通知
      final partnerId = connection.getPartnerId(share.userId);
      if (connection.settings.progressNotifications) {
        await _notificationHandler.sendProgressNotification(partnerId, share);
      }

      // 統計を更新
      await _updatePairStatistics(pairId, share);

      logger.info('Progress shared in pair: $pairId');
    } catch (e) {
      logger.error('Failed to share progress: $e');
      rethrow;
    }
  }

  /// 進捗共有履歴を取得
  Stream<List<ProgressShare>> getProgressSharesStream(String pairId) {
    return _firestore
        .collection('pair_connections')
        .doc(pairId)
        .collection('progress_shares')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProgressShare.fromFirestore(doc))
            .toList());
  }

  // ==================== チャット機能 ====================

  /// メッセージを送信
  Future<void> sendMessage({
    required String pairId,
    required PairMessage message,
  }) async {
    try {
      final connection = await _getConnection(pairId);
      if (connection == null || !connection.isActive) {
        throw const PairException('Invalid or inactive pair connection');
      }

      await _firestore
          .collection('pair_connections')
          .doc(pairId)
          .collection('messages')
          .add(message.toFirestore());

      // パートナーに通知
      final partnerId = connection.getPartnerId(message.senderId);
      if (connection.settings.chatNotifications) {
        await _notificationHandler.sendChatNotification(partnerId, message);
      }

      logger.info('Message sent in pair: $pairId');
    } catch (e) {
      logger.error('Failed to send message: $e');
      rethrow;
    }
  }

  /// メッセージ履歴を取得
  Stream<List<PairMessage>> getMessagesStream(String pairId) {
    return _firestore
        .collection('pair_connections')
        .doc(pairId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PairMessage.fromFirestore(doc))
            .toList());
  }

  /// メッセージにリアクションを追加
  Future<void> addReaction({
    required String pairId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    try {
      final messageRef = _firestore
          .collection('pair_connections')
          .doc(pairId)
          .collection('messages')
          .doc(messageId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(messageRef);
        if (!snapshot.exists) {
          throw const PairException('Message not found');
        }

        final message = PairMessage.fromFirestore(snapshot);
        final updatedReactions = Map<String, List<String>>.from(message.reactions);
        
        if (updatedReactions.containsKey(emoji)) {
          if (updatedReactions[emoji]!.contains(userId)) {
            updatedReactions[emoji]!.remove(userId);
            if (updatedReactions[emoji]!.isEmpty) {
              updatedReactions.remove(emoji);
            }
          } else {
            updatedReactions[emoji]!.add(userId);
          }
        } else {
          updatedReactions[emoji] = [userId];
        }

        transaction.update(messageRef, {'reactions': updatedReactions});
      });

      logger.info('Reaction added to message: $messageId');
    } catch (e) {
      logger.error('Failed to add reaction: $e');
      rethrow;
    }
  }

  // ==================== 統計・比較機能 ====================

  /// ペア統計を取得
  Future<PairStatistics> getPairStatistics(String pairId) async {
    try {
      final doc = await _firestore
          .collection('pair_connections')
          .doc(pairId)
          .get();

      if (!doc.exists) {
        throw const PairException('Pair connection not found');
      }

      final connection = PairConnection.fromFirestore(doc);
      return connection.statistics;
    } catch (e) {
      logger.error('Failed to get pair statistics: $e');
      rethrow;
    }
  }

  /// ユーザー比較データを取得
  Future<UserComparisonData> getUserComparison({
    required String pairId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final progressShares = await _firestore
          .collection('pair_connections')
          .doc(pairId)
          .collection('progress_shares')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .get();

      final userShares = progressShares.docs
          .map((doc) => ProgressShare.fromFirestore(doc))
          .where((share) => share.userId == userId)
          .toList();

      final partnerShares = progressShares.docs
          .map((doc) => ProgressShare.fromFirestore(doc))
          .where((share) => share.userId != userId)
          .toList();

      return UserComparisonData(
        userId: userId,
        userProgress: _calculateProgressMetrics(userShares),
        partnerProgress: _calculateProgressMetrics(partnerShares),
        comparisonPeriod: DateRange(startDate, endDate),
      );
    } catch (e) {
      logger.error('Failed to get user comparison: $e');
      rethrow;
    }
  }

  // ==================== ペア管理機能 ====================

  /// ペア接続を取得
  Future<PairConnection?> getConnection(String pairId) async {
    return await _getConnection(pairId);
  }

  /// ユーザーのアクティブなペア接続を取得
  Future<PairConnection?> getActiveConnectionForUser(String userId) async {
    return await _getActiveConnection(userId);
  }

  /// ペア接続を終了
  Future<void> endConnection({
    required String pairId,
    required String userId,
    required String reason,
  }) async {
    try {
      final connection = await _getConnection(pairId);
      if (connection == null) {
        throw const PairException('Pair connection not found');
      }

      final updatedConnection = connection.copyWith(
        status: PairStatus.ended,
        endedAt: DateTime.now(),
        endReason: reason,
      );

      await _firestore
          .collection('pair_connections')
          .doc(pairId)
          .update(updatedConnection.toFirestore());

      // パートナーに通知
      final partnerId = connection.getPartnerId(userId);
      await _notificationHandler.sendPairEndedNotification(partnerId, reason);

      logger.info('Pair connection ended: $pairId');
    } catch (e) {
      logger.error('Failed to end pair connection: $e');
      rethrow;
    }
  }

  /// ペア設定を更新
  Future<void> updatePairSettings({
    required String pairId,
    required PairSettings settings,
  }) async {
    try {
      await _firestore
          .collection('pair_connections')
          .doc(pairId)
          .update({'settings': settings.toFirestore()});

      logger.info('Pair settings updated: $pairId');
    } catch (e) {
      logger.error('Failed to update pair settings: $e');
      rethrow;
    }
  }

  // ==================== プライベートメソッド ====================

  Future<PairInvitation?> _getInvitationByCode(String code) async {
    final query = await _firestore
        .collection('pair_invitations')
        .where('inviteCode', isEqualTo: code)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return PairInvitation.fromFirestore(query.docs.first);
  }

  Future<void> _deactivateInvitation(String invitationId) async {
    await _firestore
        .collection('pair_invitations')
        .doc(invitationId)
        .update({'isActive': false});
  }

  Future<PairConnection?> _getConnection(String pairId) async {
    final doc = await _firestore
        .collection('pair_connections')
        .doc(pairId)
        .get();

    if (!doc.exists) return null;
    return PairConnection.fromFirestore(doc);
  }

  Future<PairConnection?> _getActiveConnection(String userId) async {
    final query = await _firestore
        .collection('pair_connections')
        .where('status', isEqualTo: 'active')
        .where('members', arrayContains: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return PairConnection.fromFirestore(query.docs.first);
  }

  Future<void> _updatePairStatistics(String pairId, ProgressShare share) async {
    // 統計更新のロジックを実装
    // 例: 共有回数、達成率、ストリーク等の更新
  }

  ProgressMetrics _calculateProgressMetrics(List<ProgressShare> shares) {
    if (shares.isEmpty) {
      return ProgressMetrics.empty();
    }

    final completedQuests = shares.where((s) => s.type == ProgressShareType.questCompleted).length;
    final totalShares = shares.length;
    final streakDays = _calculateStreakDays(shares);
    final averageScore = shares.map((s) => s.score ?? 0).reduce((a, b) => a + b) / shares.length;

    return ProgressMetrics(
      completedQuests: completedQuests,
      totalShares: totalShares,
      streakDays: streakDays,
      averageScore: averageScore,
      lastActivityAt: shares.first.timestamp,
    );
  }

  int _calculateStreakDays(List<ProgressShare> shares) {
    if (shares.isEmpty) return 0;

    shares.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int streak = 0;
    DateTime? lastDate;

    for (final share in shares) {
      final shareDate = DateTime(
        share.timestamp.year,
        share.timestamp.month,
        share.timestamp.day,
      );

      if (lastDate == null) {
        streak = 1;
        lastDate = shareDate;
      } else {
        final daysDiff = lastDate.difference(shareDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = shareDate;
        } else if (daysDiff > 1) {
          break;
        }
      }
    }

    return streak;
  }

  Future<Uint8List> _generateQRCodeData(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: const Color(0xFF000000),
        gapless: false,
      );

      final picData = await painter.toImageData(200);
      return picData!.buffer.asUint8List();
    }

    throw Exception('Failed to generate QR code');
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  String _generateId() {
    return _firestore.collection('temp').doc().id;
  }
}

// ==================== 例外クラス ====================

class PairException implements Exception {
  final String message;
  const PairException(this.message);

  @override
  String toString() => 'PairException: $message';
}

// ==================== データクラス ====================

class UserComparisonData {
  final String userId;
  final ProgressMetrics userProgress;
  final ProgressMetrics partnerProgress;
  final DateRange comparisonPeriod;

  const UserComparisonData({
    required this.userId,
    required this.userProgress,
    required this.partnerProgress,
    required this.comparisonPeriod,
  });
}

class ProgressMetrics {
  final int completedQuests;
  final int totalShares;
  final int streakDays;
  final double averageScore;
  final DateTime lastActivityAt;

  const ProgressMetrics({
    required this.completedQuests,
    required this.totalShares,
    required this.streakDays,
    required this.averageScore,
    required this.lastActivityAt,
  });

  factory ProgressMetrics.empty() {
    return ProgressMetrics(
      completedQuests: 0,
      totalShares: 0,
      streakDays: 0,
      averageScore: 0.0,
      lastActivityAt: DateTime.now(),
    );
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);
}