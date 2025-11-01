import 'dart:developer';

import 'package:minq/domain/home/home_view_data.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/user/user.dart';

/// 動的プロンプト生成エンジン
/// ユーザーの状況に応じてパーソナライズされたプロンプトを生成
class DynamicPromptEngine {
  static DynamicPromptEngine? _instance;
  static DynamicPromptEngine get instance =>
      _instance ??= DynamicPromptEngine._();

  DynamicPromptEngine._();

  /// ユーザーの状況に基づいた動的システムプロンプトを生成
  String generateSystemPrompt(UserProgressContext context) {
    final buffer = StringBuffer();

    // 基本的なAIコーチの役割定義
    buffer.writeln(_getBaseSystemPrompt());

    // ユーザー情報の追加
    buffer.writeln(_buildUserContextSection(context));

    // 現在の状況に基づく指示
    buffer.writeln(_buildSituationalGuidance(context));

    // 応答スタイルの指定
    buffer.writeln(_getResponseStyleGuidelines(context));

    return buffer.toString();
  }

  /// ユーザーメッセージに対する文脈情報を生成
  String generateContextualPrompt(
    String userMessage,
    UserProgressContext context,
    List<String> conversationHistory,
  ) {
    final buffer = StringBuffer();

    // 現在の状況サマリー
    buffer.writeln(_buildCurrentSituationSummary(context));

    // 最近の活動履歴
    if (context.recentLogs.isNotEmpty) {
      buffer.writeln(_buildRecentActivityContext(context));
    }

    // 会話履歴（最新5件）
    if (conversationHistory.isNotEmpty) {
      buffer.writeln(_buildConversationContext(conversationHistory));
    }

    // ユーザーメッセージ
    buffer.writeln('ユーザー: $userMessage');

    return buffer.toString();
  }

  /// クイックアクション候補を生成
  List<QuickAction> generateQuickActions(UserProgressContext context) {
    final actions = <QuickAction>[];

    // 今日のクエスト作成
    if (context.completionsToday == 0) {
      actions.add(
        const QuickAction(
          id: 'create_quest',
          title: '今日のクエストを作成',
          description: '新しい習慣を始めましょう',
          icon: 'add_task',
          route: '/create-quest',
          priority: 10,
        ),
      );
    }

    // フォーカスクエストの実行
    if (context.focusQuest != null) {
      actions.add(
        QuickAction(
          id: 'start_focus_quest',
          title: '「${context.focusQuest!.title}」を開始',
          description: 'おすすめのクエストです',
          icon: 'play_arrow',
          route: '/quest-timer/${context.focusQuest!.id}',
          priority: 9,
        ),
      );
    }

    // タイマー開始
    if (context.activeQuests.isNotEmpty) {
      final quest = context.activeQuests.first;
      actions.add(
        QuickAction(
          id: 'start_timer',
          title: 'タイマーを開始',
          description: '「${quest.title}」で集中時間を作りましょう',
          icon: 'timer',
          route: '/quest-timer/${quest.id}',
          priority: 8,
        ),
      );
    }

    // 進捗確認
    if (context.streak > 0) {
      actions.add(
        QuickAction(
          id: 'view_progress',
          title: '進捗を確認',
          description: '${context.streak}日連続達成中！',
          icon: 'trending_up',
          route: '/stats',
          priority: 7,
        ),
      );
    }

    // ペア機能
    if (context.user.pairId == null) {
      actions.add(
        const QuickAction(
          id: 'find_pair',
          title: 'ペアを見つける',
          description: '一緒に頑張る仲間を探しましょう',
          icon: 'people',
          route: '/pair',
          priority: 6,
        ),
      );
    }

    // チャレンジ参加
    actions.add(
      const QuickAction(
        id: 'join_challenge',
        title: 'チャレンジに参加',
        description: '新しいチャレンジで刺激を得ましょう',
        icon: 'emoji_events',
        route: '/challenges',
        priority: 5,
      ),
    );

    // 優先度順にソートして上位3つを返す
    actions.sort((a, b) => b.priority.compareTo(a.priority));
    return actions.take(3).toList();
  }

  /// 基本的なシステムプロンプト
  String _getBaseSystemPrompt() {
    return '''
あなたはMinQアプリの専属AIコーチです。ユーザーの習慣化を支援し、継続的な成長をサポートします。

【あなたの役割】
- 親しみやすく、励ましに満ちたパーソナルコーチ
- ユーザーの状況を理解し、具体的で実行可能なアドバイスを提供
- 小さな進歩を認め、継続の重要性を伝える
- 挫折や困難な時には共感し、前向きな解決策を提案

【応答の原則】
- 日本語で自然な会話を心がける
- 120文字以内の簡潔で分かりやすい回答
- 具体的な次のアクションを含める
- ユーザーの感情に寄り添う
''';
  }

  /// ユーザー文脈セクションの構築
  String _buildUserContextSection(UserProgressContext context) {
    final buffer = StringBuffer();
    buffer.writeln('\n【ユーザー情報】');

    // 基本情報
    buffer.writeln('- 表示名: ${context.user.displayName}');
    buffer.writeln('- 現在のレベル: ${context.user.currentLevel}');
    buffer.writeln('- 総ポイント: ${context.user.totalPoints}');

    // ストリーク情報
    if (context.streak > 0) {
      buffer.writeln('- 現在のストリーク: ${context.streak}日連続');
      if (context.user.longestStreak > context.streak) {
        buffer.writeln('- 最長ストリーク: ${context.user.longestStreak}日');
      }
    } else {
      buffer.writeln('- ストリーク: まだ開始していません');
    }

    // 今日の活動
    buffer.writeln('- 今日の完了数: ${context.completionsToday}件');

    // フォーカスタグ
    if (context.user.focusTags.isNotEmpty) {
      buffer.writeln('- 関心分野: ${context.user.focusTags.join(', ')}');
    }

    // ペア情報
    if (context.user.pairId != null) {
      buffer.writeln('- ペア: 活動中');
    }

    return buffer.toString();
  }

  /// 状況に応じたガイダンスの構築
  String _buildSituationalGuidance(UserProgressContext context) {
    final buffer = StringBuffer();
    buffer.writeln('\n【現在の状況と対応指針】');

    // ストリーク状況に応じた指針
    if (context.streak == 0) {
      buffer.writeln('- 新規開始フェーズ: 小さく始めることを重視し、継続の習慣づくりを支援');
    } else if (context.streak < 7) {
      buffer.writeln('- 習慣形成初期: 継続を称賛し、モチベーション維持を重視');
    } else if (context.streak < 21) {
      buffer.writeln('- 習慣定着期: 安定した継続を評価し、質の向上を提案');
    } else {
      buffer.writeln('- 習慣マスター: 高い継続力を称賛し、新たなチャレンジを提案');
    }

    // 今日の活動状況
    if (context.completionsToday == 0) {
      buffer.writeln('- 今日未実行: 軽い気持ちで始められるよう促す');
    } else if (context.completionsToday < 3) {
      buffer.writeln('- 活動開始済み: 良いスタートを称賛し、継続を促す');
    } else {
      buffer.writeln('- 活発な活動: 素晴らしい進捗を称賛し、達成感を共有');
    }

    // 時間帯に応じた配慮
    final hour = DateTime.now().hour;
    if (hour < 10) {
      buffer.writeln('- 朝の時間帯: エネルギッシュで前向きなトーン');
    } else if (hour < 18) {
      buffer.writeln('- 日中の時間帯: 集中とリフレッシュのバランス');
    } else {
      buffer.writeln('- 夜の時間帯: リラックスした振り返りと明日への準備');
    }

    return buffer.toString();
  }

  /// 応答スタイルガイドライン
  String _getResponseStyleGuidelines(UserProgressContext context) {
    final encouragementLevel = _calculateEncouragementLevel(context);

    return '''

【応答スタイル】
- 励ましレベル: $encouragementLevel
- 語調: ${_getToneGuideline(context)}
- 焦点: ${_getFocusGuideline(context)}
- 必須要素: 具体的な次のアクション提案を含める
''';
  }

  /// 現在の状況サマリー
  String _buildCurrentSituationSummary(UserProgressContext context) {
    final buffer = StringBuffer();
    buffer.writeln('【現在の状況】');

    if (context.focusQuest != null) {
      buffer.writeln('- 推奨クエスト: 「${context.focusQuest!.title}」');
    }

    if (context.activeQuests.isNotEmpty) {
      buffer.writeln('- アクティブなクエスト: ${context.activeQuests.length}件');
      for (final quest in context.activeQuests.take(3)) {
        buffer.writeln('  - ${quest.title} (${quest.category})');
      }
    }

    return buffer.toString();
  }

  /// 最近の活動履歴
  String _buildRecentActivityContext(UserProgressContext context) {
    final buffer = StringBuffer();
    buffer.writeln('\n【最近の活動】');

    final recentLogs = context.recentLogs.take(5);
    for (final log in recentLogs) {
      final quest = context.activeQuests.firstWhere(
        (q) => q.id == log.questId,
        orElse: () => Quest()..title = '不明なクエスト',
      );
      final timeAgo = _formatTimeAgo(log.timestamp);
      buffer.writeln('- ${quest.title}: $timeAgo');
    }

    return buffer.toString();
  }

  /// 会話履歴の文脈
  String _buildConversationContext(List<String> history) {
    final buffer = StringBuffer();
    buffer.writeln('\n【最近の会話】');

    final recentHistory = history.take(5);
    for (final message in recentHistory) {
      buffer.writeln('- $message');
    }

    return buffer.toString();
  }

  /// 励ましレベルの計算
  String _calculateEncouragementLevel(UserProgressContext context) {
    var score = 0;

    // ストリークによる加点
    if (context.streak > 0) score += 2;
    if (context.streak >= 7) score += 2;
    if (context.streak >= 21) score += 2;

    // 今日の活動による加点
    score += context.completionsToday;

    // レベルによる加点
    score += (context.user.currentLevel / 5).floor();

    if (score >= 8) return '高（大いに称賛し、新たなチャレンジを提案）';
    if (score >= 5) return '中（継続を評価し、質の向上を提案）';
    if (score >= 2) return '低（小さな進歩を認め、継続を促す）';
    return '導入（優しく始めることを促し、不安を和らげる）';
  }

  /// 語調ガイドライン
  String _getToneGuideline(UserProgressContext context) {
    if (context.streak >= 21) return '尊敬と称賛を込めた丁寧語';
    if (context.streak >= 7) return '親しみやすく励ましに満ちた語調';
    if (context.streak > 0) return '温かく支援的な語調';
    return '優しく導く語調';
  }

  /// 焦点ガイドライン
  String _getFocusGuideline(UserProgressContext context) {
    if (context.completionsToday == 0) return '今日の最初の一歩';
    if (context.streak == 0) return '継続の習慣づくり';
    if (context.streak < 7) return 'モチベーション維持';
    if (context.streak < 21) return '質の向上と安定化';
    return '新たなチャレンジと成長';
  }

  /// 時間の経過を分かりやすく表現
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${(difference.inDays / 7).floor()}週間前';
    }
  }
}

/// ユーザーの進捗コンテキスト
class UserProgressContext {
  final User user;
  final int streak;
  final int completionsToday;
  final List<Quest> activeQuests;
  final List<HomeLogItem> recentLogs;
  final HomeQuestItem? focusQuest;
  final DateTime timestamp;

  const UserProgressContext({
    required this.user,
    required this.streak,
    required this.completionsToday,
    required this.activeQuests,
    required this.recentLogs,
    this.focusQuest,
    required this.timestamp,
  });

  /// 現在のモチベーションレベルを計算
  MotivationLevel get motivationLevel {
    var score = 0;

    // ストリークによる評価
    if (streak > 0) score += 2;
    if (streak >= 7) score += 2;
    if (streak >= 21) score += 3;

    // 今日の活動による評価
    score += completionsToday;

    // 最近の活動頻度
    final recentActivity =
        recentLogs
            .where(
              (log) => DateTime.now().difference(log.timestamp).inDays <= 3,
            )
            .length;
    score += (recentActivity / 3).floor();

    if (score >= 8) return MotivationLevel.high;
    if (score >= 5) return MotivationLevel.medium;
    if (score >= 2) return MotivationLevel.low;
    return MotivationLevel.starting;
  }

  /// 習慣化の段階を判定
  HabitStage get habitStage {
    if (streak == 0) return HabitStage.initial;
    if (streak < 7) return HabitStage.forming;
    if (streak < 21) return HabitStage.developing;
    if (streak < 66) return HabitStage.stabilizing;
    return HabitStage.mastered;
  }
}

/// クイックアクション
class QuickAction {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String route;
  final int priority;
  final Map<String, dynamic>? parameters;

  const QuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.priority,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'route': route,
      'priority': priority,
      'parameters': parameters,
    };
  }
}

/// モチベーションレベル
enum MotivationLevel {
  starting, // 開始段階
  low, // 低調
  medium, // 安定
  high, // 高調
}

/// 習慣化の段階
enum HabitStage {
  initial, // 初期段階
  forming, // 形成期（1-7日）
  developing, // 発展期（8-21日）
  stabilizing, // 安定期（22-66日）
  mastered, // 習慣化完了（67日以上）
}
