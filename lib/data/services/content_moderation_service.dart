import 'package:flutter/foundation.dart';

class ContentModerationService {
  static const List<String> _ngWords = [
    // 基本的な不適切な言葉（日本語）
    'バカ', 'ばか', 'アホ', 'あほ', 'クソ', 'くそ', 'クズ', 'くず',
    '死ね', 'しね', '殺す', 'ころす', 'うざい', 'ウザい', 'きもい', 'キモい',
    'ブス', 'ぶす', 'デブ', 'でぶ', 'チビ', 'ちび',
    
    // 基本的な不適切な言葉（英語）
    'stupid', 'idiot', 'moron', 'dumb', 'hate', 'kill', 'die',
    'ugly', 'fat', 'loser', 'shut up',
    
    // 差別的な言葉は含めない（誤検知を避けるため）
    // 実際の運用では、より包括的なリストを使用し、
    // 機械学習ベースのモデレーションも併用することを推奨
  ];

  static const List<String> _suspiciousPatterns = [
    // 個人情報の可能性があるパターン
    r'\d{3}-\d{4}-\d{4}', // 電話番号
    r'\d{4}-\d{4}-\d{4}-\d{4}', // クレジットカード番号のようなパターン
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', // メールアドレス
  ];

  /// テキストに不適切な内容が含まれているかチェック
  static ContentModerationResult moderateText(String text) {
    if (text.trim().isEmpty) {
      return ContentModerationResult.clean();
    }

    final normalizedText = text.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    
    // NGワードチェック
    for (final ngWord in _ngWords) {
      if (normalizedText.contains(ngWord.toLowerCase())) {
        return ContentModerationResult.blocked(
          reason: 'inappropriate_language',
          details: 'テキストに不適切な言葉が含まれています',
        );
      }
    }

    // 個人情報パターンチェック
    for (final pattern in _suspiciousPatterns) {
      if (RegExp(pattern).hasMatch(text)) {
        return ContentModerationResult.flagged(
          reason: 'potential_personal_info',
          details: '個人情報の可能性があるパターンが検出されました',
        );
      }
    }

    // 連続する同じ文字のチェック（スパム対策）
    if (RegExp(r'(.)\1{4,}').hasMatch(text)) {
      return ContentModerationResult.flagged(
        reason: 'spam_pattern',
        details: 'スパムの可能性があるパターンが検出されました',
      );
    }

    // 過度に長いテキストのチェック
    if (text.length > 1000) {
      return ContentModerationResult.flagged(
        reason: 'excessive_length',
        details: 'テキストが長すぎます',
      );
    }

    return ContentModerationResult.clean();
  }

  /// ユーザー名の適切性をチェック
  static ContentModerationResult moderateUsername(String username) {
    if (username.trim().isEmpty) {
      return ContentModerationResult.blocked(
        reason: 'empty_username',
        details: 'ユーザー名が空です',
      );
    }

    if (username.length < 2) {
      return ContentModerationResult.blocked(
        reason: 'username_too_short',
        details: 'ユーザー名が短すぎます',
      );
    }

    if (username.length > 20) {
      return ContentModerationResult.blocked(
        reason: 'username_too_long',
        details: 'ユーザー名が長すぎます',
      );
    }

    // 基本的なNGワードチェック
    final textResult = moderateText(username);
    if (!textResult.isClean) {
      return ContentModerationResult.blocked(
        reason: 'inappropriate_username',
        details: 'ユーザー名に不適切な内容が含まれています',
      );
    }

    // 特殊文字の過度な使用チェック
    final specialCharCount = RegExp(r'[^\w\s]').allMatches(username).length;
    if (specialCharCount > username.length * 0.3) {
      return ContentModerationResult.flagged(
        reason: 'excessive_special_chars',
        details: '特殊文字が多すぎます',
      );
    }

    return ContentModerationResult.clean();
  }

  /// 匿名性を保つためのユーザー名生成
  static String generateAnonymousUsername() {
    final adjectives = [
      '元気な', '優しい', '頑張る', '明るい', '静かな', '真面目な', '楽しい', '穏やかな',
      'がんばり屋の', 'ポジティブな', '前向きな', '笑顔の', '親切な', '丁寧な',
    ];
    
    final nouns = [
      'ユーザー', '仲間', 'パートナー', '友達', 'サポーター', 'チャレンジャー',
      'ランナー', 'ウォーカー', 'リーダー', 'ヘルパー', 'ドリーマー', 'ファイター',
    ];

    final random = DateTime.now().millisecondsSinceEpoch;
    final adjective = adjectives[random % adjectives.length];
    final noun = nouns[(random ~/ adjectives.length) % nouns.length];
    final number = (random % 9999) + 1;

    return '$adjective$noun$number';
  }
}

enum ContentModerationStatus { clean, flagged, blocked }

class ContentModerationResult {
  const ContentModerationResult({
    required this.status,
    this.reason,
    this.details,
  });

  factory ContentModerationResult.clean() {
    return const ContentModerationResult(status: ContentModerationStatus.clean);
  }

  factory ContentModerationResult.flagged({
    required String reason,
    String? details,
  }) {
    return ContentModerationResult(
      status: ContentModerationStatus.flagged,
      reason: reason,
      details: details,
    );
  }

  factory ContentModerationResult.blocked({
    required String reason,
    String? details,
  }) {
    return ContentModerationResult(
      status: ContentModerationStatus.blocked,
      reason: reason,
      details: details,
    );
  }

  final ContentModerationStatus status;
  final String? reason;
  final String? details;

  bool get isClean => status == ContentModerationStatus.clean;
  bool get isFlagged => status == ContentModerationStatus.flagged;
  bool get isBlocked => status == ContentModerationStatus.blocked;

  @override
  String toString() {
    return 'ContentModerationResult(status: $status, reason: $reason, details: $details)';
  }
}