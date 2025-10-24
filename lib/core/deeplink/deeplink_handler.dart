import 'dart:async';

import 'package:go_router/go_router.dart';

/// ディープリンクの種類
enum DeepLinkType {
  /// クエスト詳細
  questDetail,

  /// クエスト記録
  questRecord,

  /// ペアチャット
  pairChat,

  /// ペアマッチング
  pairMatching,

  /// プロフィール
  profile,

  /// 設定
  settings,

  /// 通知設定
  notificationSettings,

  /// 統計
  stats,

  /// ホーム
  home,

  /// 不明
  unknown,
}

/// ディープリンクデータ
class DeepLinkData {
  final DeepLinkType type;
  final Map<String, String> parameters;
  final String? rawUrl;

  const DeepLinkData({
    required this.type,
    this.parameters = const {},
    this.rawUrl,
  });

  /// questIdを取得
  String? get questId => parameters['questId'];

  /// pairIdを取得
  String? get pairId => parameters['pairId'];

  /// buddyIdを取得
  String? get buddyId => parameters['buddyId'];

  /// codeを取得
  String? get code => parameters['code'];
}

/// ディープリンクハンドラー
class DeepLinkHandler {
  final GoRouter _router;
  final StreamController<DeepLinkData> _deepLinkController =
      StreamController<DeepLinkData>.broadcast();

  DeepLinkHandler(this._router);

  /// ディープリンクストリーム
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  /// URLからディープリンクを処理
  Future<bool> handleUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final deepLink = _parseUri(uri);

      if (deepLink.type == DeepLinkType.unknown) {
        print('⚠️ Unknown deep link: $url');
        return false;
      }

      print('✅ Handling deep link: ${deepLink.type} - $url');

      // ディープリンクイベントを発行
      _deepLinkController.add(deepLink);

      // ルーティング
      await _navigate(deepLink);

      return true;
    } catch (e) {
      print('❌ Failed to handle deep link: $url - $e');
      return false;
    }
  }

  /// URIをパース
  DeepLinkData _parseUri(Uri uri) {
    // スキーム: minq://
    // ホスト: quest, pair, profile, settings, etc.
    // パス: /detail/:id, /record/:id, etc.

    final host = uri.host;
    final pathSegments = uri.pathSegments;
    final queryParameters = uri.queryParameters;

    DeepLinkType type;
    Map<String, String> parameters = {};

    switch (host) {
      case 'quest':
        if (pathSegments.isNotEmpty) {
          if (pathSegments[0] == 'detail' && pathSegments.length > 1) {
            type = DeepLinkType.questDetail;
            parameters['questId'] = pathSegments[1];
          } else if (pathSegments[0] == 'record' && pathSegments.length > 1) {
            type = DeepLinkType.questRecord;
            parameters['questId'] = pathSegments[1];
          } else {
            type = DeepLinkType.unknown;
          }
        } else {
          type = DeepLinkType.unknown;
        }
        break;

      case 'pair':
        if (pathSegments.isNotEmpty) {
          if (pathSegments[0] == 'chat' && pathSegments.length > 1) {
            type = DeepLinkType.pairChat;
            parameters['pairId'] = pathSegments[1];
          } else if (pathSegments[0] == 'matching') {
            type = DeepLinkType.pairMatching;
            if (queryParameters.containsKey('code')) {
              parameters['code'] = queryParameters['code']!;
            }
          } else {
            type = DeepLinkType.unknown;
          }
        } else {
          type = DeepLinkType.unknown;
        }
        break;

      case 'profile':
        type = DeepLinkType.profile;
        break;

      case 'settings':
        if (pathSegments.isNotEmpty && pathSegments[0] == 'notifications') {
          type = DeepLinkType.notificationSettings;
        } else {
          type = DeepLinkType.settings;
        }
        break;

      case 'stats':
        type = DeepLinkType.stats;
        break;

      case 'home':
        type = DeepLinkType.home;
        break;

      default:
        type = DeepLinkType.unknown;
    }

    return DeepLinkData(
      type: type,
      parameters: parameters,
      rawUrl: uri.toString(),
    );
  }

  /// ナビゲーション
  Future<void> _navigate(DeepLinkData deepLink) async {
    switch (deepLink.type) {
      case DeepLinkType.questDetail:
        final questId = deepLink.questId;
        if (questId != null) {
          _router.go('/quest/$questId');
        }
        break;

      case DeepLinkType.questRecord:
        final questId = deepLink.questId;
        if (questId != null) {
          _router.go('/record/$questId');
        }
        break;

      case DeepLinkType.pairChat:
        final pairId = deepLink.pairId;
        if (pairId != null) {
          _router.go('/pair/chat/$pairId');
        }
        break;

      case DeepLinkType.pairMatching:
        final code = deepLink.code;
        if (code != null) {
          _router.go('/pair/matching?code=$code');
        } else {
          _router.go('/pair/matching');
        }
        break;

      case DeepLinkType.profile:
        _router.go('/profile');
        break;

      case DeepLinkType.settings:
        _router.go('/settings');
        break;

      case DeepLinkType.notificationSettings:
        _router.go('/settings/notifications');
        break;

      case DeepLinkType.stats:
        _router.go('/stats');
        break;

      case DeepLinkType.home:
        _router.go('/');
        break;

      case DeepLinkType.unknown:
        // 不明なディープリンクはホームに遷移
        _router.go('/');
        break;
    }
  }

  /// ディープリンクURLを生成
  static String generateUrl({
    required DeepLinkType type,
    Map<String, String>? parameters,
  }) {
    final buffer = StringBuffer('minq://');

    switch (type) {
      case DeepLinkType.questDetail:
        final questId = parameters?['questId'] ?? '';
        buffer.write('quest/detail/$questId');
        break;

      case DeepLinkType.questRecord:
        final questId = parameters?['questId'] ?? '';
        buffer.write('quest/record/$questId');
        break;

      case DeepLinkType.pairChat:
        final pairId = parameters?['pairId'] ?? '';
        buffer.write('pair/chat/$pairId');
        break;

      case DeepLinkType.pairMatching:
        buffer.write('pair/matching');
        if (parameters?.containsKey('code') == true) {
          buffer.write('?code=${parameters!['code']}');
        }
        break;

      case DeepLinkType.profile:
        buffer.write('profile');
        break;

      case DeepLinkType.settings:
        buffer.write('settings');
        break;

      case DeepLinkType.notificationSettings:
        buffer.write('settings/notifications');
        break;

      case DeepLinkType.stats:
        buffer.write('stats');
        break;

      case DeepLinkType.home:
        buffer.write('home');
        break;

      case DeepLinkType.unknown:
        buffer.write('home');
        break;
    }

    return buffer.toString();
  }

  /// Web用のディープリンクURLを生成
  static String generateWebUrl({
    required DeepLinkType type,
    Map<String, String>? parameters,
  }) {
    final buffer = StringBuffer('https://minq.app/');

    switch (type) {
      case DeepLinkType.questDetail:
        final questId = parameters?['questId'] ?? '';
        buffer.write('quest/$questId');
        break;

      case DeepLinkType.questRecord:
        final questId = parameters?['questId'] ?? '';
        buffer.write('record/$questId');
        break;

      case DeepLinkType.pairChat:
        final pairId = parameters?['pairId'] ?? '';
        buffer.write('pair/chat/$pairId');
        break;

      case DeepLinkType.pairMatching:
        buffer.write('pair/matching');
        if (parameters?.containsKey('code') == true) {
          buffer.write('?code=${parameters!['code']}');
        }
        break;

      case DeepLinkType.profile:
        buffer.write('profile');
        break;

      case DeepLinkType.settings:
        buffer.write('settings');
        break;

      case DeepLinkType.notificationSettings:
        buffer.write('settings/notifications');
        break;

      case DeepLinkType.stats:
        buffer.write('stats');
        break;

      case DeepLinkType.home:
        buffer.write('');
        break;

      case DeepLinkType.unknown:
        buffer.write('');
        break;
    }

    return buffer.toString();
  }

  /// クリーンアップ
  void dispose() {
    _deepLinkController.close();
  }
}

/// ディープリンクバリデーター
class DeepLinkValidator {
  const DeepLinkValidator._();

  /// URLが有効かどうかを検証
  static bool isValid(String url) {
    try {
      final uri = Uri.parse(url);

      // スキームチェック
      if (uri.scheme != 'minq' && uri.scheme != 'https') {
        return false;
      }

      // ホストチェック（https の場合）
      if (uri.scheme == 'https' && uri.host != 'minq.app') {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// パラメータをサニタイズ
  static Map<String, String> sanitizeParameters(Map<String, String> parameters) {
    final sanitized = <String, String>{};

    for (final entry in parameters.entries) {
      // XSS対策: HTMLタグを除去
      final sanitizedValue = entry.value
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'[^\w\s\-_]'), '');

      sanitized[entry.key] = sanitizedValue;
    }

    return sanitized;
  }

  /// questIdが有効かどうかを検証
  static bool isValidQuestId(String? questId) {
    if (questId == null || questId.isEmpty) {
      return false;
    }

    // 数値のみを許可
    return RegExp(r'^\d+$').hasMatch(questId);
  }

  /// pairIdが有効かどうかを検証
  static bool isValidPairId(String? pairId) {
    if (pairId == null || pairId.isEmpty) {
      return false;
    }

    // 英数字とハイフンのみを許可
    return RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(pairId);
  }

  /// codeが有効かどうかを検証
  static bool isValidCode(String? code) {
    if (code == null || code.isEmpty) {
      return false;
    }

    // 6桁の英数字のみを許可
    return RegExp(r'^[A-Z0-9]{6}$').hasMatch(code);
  }
}

/// ディープリンク分析
class DeepLinkAnalytics {
  final Map<DeepLinkType, int> _clickCounts = {};

  /// クリックを記録
  void recordClick(DeepLinkType type) {
    _clickCounts[type] = (_clickCounts[type] ?? 0) + 1;
  }

  /// クリック数を取得
  int getClickCount(DeepLinkType type) {
    return _clickCounts[type] ?? 0;
  }

  /// 全クリック数を取得
  int getTotalClicks() {
    return _clickCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// 統計をリセット
  void reset() {
    _clickCounts.clear();
  }

  /// 統計を取得
  Map<DeepLinkType, int> getStats() {
    return Map.unmodifiable(_clickCounts);
  }
}
