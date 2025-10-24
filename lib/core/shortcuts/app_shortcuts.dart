import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

/// アプリショートカットの種類
enum AppShortcutType {
  /// クエスト作成
  createQuest,

  /// 今日のクエスト
  todayQuests,

  /// 統計
  stats,

  /// ペアチャット
  pairChat,
}

/// アプリショートカットサービス
class AppShortcutsService {
  final QuickActions _quickActions = const QuickActions();
  final void Function(AppShortcutType) _onShortcutTapped;

  AppShortcutsService({
    required void Function(AppShortcutType) onShortcutTapped,
  }) : _onShortcutTapped = onShortcutTapped;

  /// 初期化
  Future<void> initialize() async {
    // ショートカットを設定
    await _setupShortcuts();

    // ショートカットタップを監視
    _quickActions.initialize((type) {
      final shortcutType = _parseShortcutType(type);
      if (shortcutType != null) {
        _onShortcutTapped(shortcutType);
      }
    });
  }

  /// ショートカットを設定
  Future<void> _setupShortcuts() async {
    await _quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'create_quest',
        localizedTitle: 'クエスト作成',
        icon: 'ic_shortcut_add',
      ),
      const ShortcutItem(
        type: 'today_quests',
        localizedTitle: '今日のクエスト',
        icon: 'ic_shortcut_today',
      ),
      const ShortcutItem(
        type: 'stats',
        localizedTitle: '統計',
        icon: 'ic_shortcut_stats',
      ),
      const ShortcutItem(
        type: 'pair_chat',
        localizedTitle: 'ペアチャット',
        icon: 'ic_shortcut_chat',
      ),
    ]);
  }

  /// ショートカットタイプをパース
  AppShortcutType? _parseShortcutType(String type) {
    switch (type) {
      case 'create_quest':
        return AppShortcutType.createQuest;
      case 'today_quests':
        return AppShortcutType.todayQuests;
      case 'stats':
        return AppShortcutType.stats;
      case 'pair_chat':
        return AppShortcutType.pairChat;
      default:
        return null;
    }
  }

  /// ショートカットをクリア
  Future<void> clearShortcuts() async {
    await _quickActions.clearShortcutItems();
  }
}

/// 動的ショートカットマネージャー
class DynamicShortcutsManager {
  final QuickActions _quickActions = const QuickActions();

  /// ユーザーの使用状況に基づいてショートカットを更新
  Future<void> updateShortcuts({
    required bool hasPair,
    required int todayQuestsCount,
    required int completedQuestsCount,
  }) async {
    final shortcuts = <ShortcutItem>[];

    // 常に表示: クエスト作成
    shortcuts.add(
      const ShortcutItem(
        type: 'create_quest',
        localizedTitle: 'クエスト作成',
        icon: 'ic_shortcut_add',
      ),
    );

    // 今日のクエストがある場合
    if (todayQuestsCount > 0) {
      shortcuts.add(
        ShortcutItem(
          type: 'today_quests',
          localizedTitle: '今日のクエスト ($todayQuestsCount)',
          icon: 'ic_shortcut_today',
        ),
      );
    }

    // 統計（完了クエストがある場合）
    if (completedQuestsCount > 0) {
      shortcuts.add(
        const ShortcutItem(
          type: 'stats',
          localizedTitle: '統計',
          icon: 'ic_shortcut_stats',
        ),
      );
    }

    // ペアがいる場合
    if (hasPair) {
      shortcuts.add(
        const ShortcutItem(
          type: 'pair_chat',
          localizedTitle: 'ペアチャット',
          icon: 'ic_shortcut_chat',
        ),
      );
    }

    await _quickActions.setShortcutItems(shortcuts);
  }
}

/// ショートカットアイコン設定（Android）
class AndroidShortcutIcons {
  const AndroidShortcutIcons._();

  /// アイコンリソース名
  static const String add = 'ic_shortcut_add';
  static const String today = 'ic_shortcut_today';
  static const String stats = 'ic_shortcut_stats';
  static const String chat = 'ic_shortcut_chat';
  static const String settings = 'ic_shortcut_settings';
}

/// ショートカット統計
class ShortcutStats {
  final Map<AppShortcutType, int> _usageCount = {};

  /// 使用回数を記録
  void recordUsage(AppShortcutType type) {
    _usageCount[type] = (_usageCount[type] ?? 0) + 1;
  }

  /// 使用回数を取得
  int getUsageCount(AppShortcutType type) {
    return _usageCount[type] ?? 0;
  }

  /// 最も使用されているショートカット
  AppShortcutType? getMostUsed() {
    if (_usageCount.isEmpty) return null;

    return _usageCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 統計をリセット
  void reset() {
    _usageCount.clear();
  }

  /// 統計を取得
  Map<String, int> getStats() {
    return _usageCount.map((key, value) => MapEntry(key.name, value));
  }
}

/// ショートカットルーター
class ShortcutRouter {
  final BuildContext context;

  ShortcutRouter(this.context);

  /// ショートカットに応じて画面遷移
  void route(AppShortcutType type) {
    switch (type) {
      case AppShortcutType.createQuest:
        _navigateToCreateQuest();
        break;
      case AppShortcutType.todayQuests:
        _navigateToTodayQuests();
        break;
      case AppShortcutType.stats:
        _navigateToStats();
        break;
      case AppShortcutType.pairChat:
        _navigateToPairChat();
        break;
    }
  }

  void _navigateToCreateQuest() {
    Navigator.of(context).pushNamed('/quests/create');
  }

  void _navigateToTodayQuests() {
    Navigator.of(context).pushNamed('/');
  }

  void _navigateToStats() {
    Navigator.of(context).pushNamed('/stats');
  }

  void _navigateToPairChat() {
    Navigator.of(context).pushNamed('/pair');
  }
}

/// ショートカット設定
class ShortcutConfig {
  final String type;
  final String localizedTitle;
  final String? icon;
  final bool enabled;

  const ShortcutConfig({
    required this.type,
    required this.localizedTitle,
    this.icon,
    this.enabled = true,
  });

  /// ShortcutItemに変換
  ShortcutItem toShortcutItem() {
    return ShortcutItem(type: type, localizedTitle: localizedTitle, icon: icon);
  }
}

/// ショートカットプリセット
class ShortcutPresets {
  const ShortcutPresets._();

  /// デフォルトショートカット
  static const List<ShortcutConfig> defaultShortcuts = [
    ShortcutConfig(
      type: 'create_quest',
      localizedTitle: 'クエスト作成',
      icon: AndroidShortcutIcons.add,
    ),
    ShortcutConfig(
      type: 'today_quests',
      localizedTitle: '今日のクエスト',
      icon: AndroidShortcutIcons.today,
    ),
    ShortcutConfig(
      type: 'stats',
      localizedTitle: '統計',
      icon: AndroidShortcutIcons.stats,
    ),
  ];

  /// ペア機能有効時のショートカット
  static const List<ShortcutConfig> withPairShortcuts = [
    ShortcutConfig(
      type: 'create_quest',
      localizedTitle: 'クエスト作成',
      icon: AndroidShortcutIcons.add,
    ),
    ShortcutConfig(
      type: 'today_quests',
      localizedTitle: '今日のクエスト',
      icon: AndroidShortcutIcons.today,
    ),
    ShortcutConfig(
      type: 'pair_chat',
      localizedTitle: 'ペアチャット',
      icon: AndroidShortcutIcons.chat,
    ),
    ShortcutConfig(
      type: 'stats',
      localizedTitle: '統計',
      icon: AndroidShortcutIcons.stats,
    ),
  ];
}

/// ショートカットローカライゼーション
class ShortcutLocalizations {
  final String locale;

  const ShortcutLocalizations(this.locale);

  /// ローカライズされたタイトルを取得
  String getLocalizedTitle(AppShortcutType type) {
    if (locale == 'ja') {
      return _getJapaneseTitle(type);
    } else {
      return _getEnglishTitle(type);
    }
  }

  String _getJapaneseTitle(AppShortcutType type) {
    switch (type) {
      case AppShortcutType.createQuest:
        return 'クエスト作成';
      case AppShortcutType.todayQuests:
        return '今日のクエスト';
      case AppShortcutType.stats:
        return '統計';
      case AppShortcutType.pairChat:
        return 'ペアチャット';
    }
  }

  String _getEnglishTitle(AppShortcutType type) {
    switch (type) {
      case AppShortcutType.createQuest:
        return 'Create Quest';
      case AppShortcutType.todayQuests:
        return 'Today\'s Quests';
      case AppShortcutType.stats:
        return 'Statistics';
      case AppShortcutType.pairChat:
        return 'Pair Chat';
    }
  }
}

/// ショートカットアクセシビリティ
class ShortcutAccessibility {
  const ShortcutAccessibility._();

  /// アクセシビリティラベルを取得
  static String getAccessibilityLabel(AppShortcutType type) {
    switch (type) {
      case AppShortcutType.createQuest:
        return '新しいクエストを作成します';
      case AppShortcutType.todayQuests:
        return '今日のクエスト一覧を表示します';
      case AppShortcutType.stats:
        return '統計情報を表示します';
      case AppShortcutType.pairChat:
        return 'ペアとのチャットを開きます';
    }
  }
}
