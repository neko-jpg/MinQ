import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// ペア招待
class PairInvitation {
  final String id;
  final String inviterId;
  final String inviteCode;
  final String category;
  final String deepLink;
  final String webLink;
  final Uint8List qrCodeData;
  final String? customMessage;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isActive;

  const PairInvitation({
    required this.id,
    required this.inviterId,
    required this.inviteCode,
    required this.category,
    required this.deepLink,
    required this.webLink,
    required this.qrCodeData,
    this.customMessage,
    required this.expiresAt,
    required this.createdAt,
    required this.isActive,
  });

  /// 期限切れかどうか
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 有効かどうか
  bool get isValid => isActive && !isExpired;

  /// Firestoreから作成
  factory PairInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PairInvitation(
      id: doc.id,
      inviterId: data['inviterId'] as String,
      inviteCode: data['inviteCode'] as String,
      category: data['category'] as String? ?? 'general',
      deepLink: data['deepLink'] as String,
      webLink: data['webLink'] as String,
      qrCodeData: Uint8List.fromList(List<int>.from(data['qrCodeData'] as List)),
      customMessage: data['customMessage'] as String?,
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Firestoreに保存
  Map<String, dynamic> toFirestore() {
    return {
      'inviterId': inviterId,
      'inviteCode': inviteCode,
      'category': category,
      'deepLink': deepLink,
      'webLink': webLink,
      'qrCodeData': qrCodeData.toList(),
      'customMessage': customMessage,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  /// コピーを作成
  PairInvitation copyWith({
    String? id,
    String? inviterId,
    String? inviteCode,
    String? category,
    String? deepLink,
    String? webLink,
    Uint8List? qrCodeData,
    String? customMessage,
    DateTime? expiresAt,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return PairInvitation(
      id: id ?? this.id,
      inviterId: inviterId ?? this.inviterId,
      inviteCode: inviteCode ?? this.inviteCode,
      category: category ?? this.category,
      deepLink: deepLink ?? this.deepLink,
      webLink: webLink ?? this.webLink,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      customMessage: customMessage ?? this.customMessage,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}