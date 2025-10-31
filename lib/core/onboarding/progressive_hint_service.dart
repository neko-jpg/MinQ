import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// プログレッシブヒントサービス
/// ユーザーの進捗に応じて段階的にヒントを表示し、SharedPreferencesで状態管理
class ProgressiveHintService {
  static const String _keyPrefix = 'progressive_hint_';
  
  // ヒントID定数
  static const String hintFirstQuest = 'first_quest';
  static const String hintFirstCompletion = 'first_completion';
  static const String hintStreak = 'streak_achievement';
  static const String hintWeeklyGoal = 'weekly_goal';
  static const String hintPairFeature = 'pair_feature_unlock';
  static const String hintAdvancedStats = 'advanced_stats_unlock';
  static const String hintAchievements = 'achievements_unlock';

  /// ヒントが表示済みかチェック
  static Future<bool> hasShownHint(String hintId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$hintId') ?? false;
  }

  /// ヒントを表示済みとしてマーク
  static Future<void> markHintShown(String hintId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$hintId', true);
  }

  /// ヒント表示状態をリセット（デバッグ用）
  static Future<void> resetHint(String hintId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$hintId');
  }

  /// 全てのヒントをリセット（デバッグ用）
  static Future<void> resetAllHints() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// 初回クエスト作成ヒントを表示
  static Future<void> showFirstQuestHint(BuildContext context) async {
    if (await hasShownHint(hintFirstQuest)) return;
    if (!context.mounted) return;

    await _showHintDialog(
      context: context,
      hintId: hintFirstQuest,
      title: '最初のクエストを作成しましょう！',
      message: 'クエストを作成して習慣化の第一歩を踏み出しましょう。\n小さな目標から始めることが成功の秘訣です。',
      icon: Icons.add_task,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  /// 初回完了ヒントを表示
  static Future<void> showFirstCompletionHint(BuildContext context) async {
    if (await hasShownHint(hintFirstCompletion)) return;
    if (!context.mounted) return;

    await _showHintDialog(
      context: context,
      hintId: hintFirstCompletion,
      title: '初めての完了おめでとうございます！',
      message: '継続することでストリークが増えます。\n毎日少しずつでも続けることが大切です。',
      icon: Icons.celebration,
      color: Colors.green,
    );
  }

  /// ストリーク達成ヒントを表示
  static Future<void> showStreakHint(BuildContext context, int streakDays) async {
    if (await hasShownHint(hintStreak)) return;
    if (!context.mounted) return;

    await _showHintDialog(
      context: context,
      hintId: hintStreak,
      title: '素晴らしいストリーク！',
      message: '$streakDays日連続達成です！\n引き続き習慣を続けて、さらなる成長を目指しましょう。',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    );
  }

  /// 週次目標達成ヒントを表示
  static Future<void> showWeeklyGoalHint(BuildContext context) async {
    if (await hasShownHint(hintWeeklyGoal)) return;
    if (!context.mounted) return;

    await _showHintDialog(
      context: context,
      hintId: hintWeeklyGoal,
      title: '週次目標達成！',
      message: '今週の目標を達成しました！\n統計画面で詳細な進捗を確認できます。',
      icon: Icons.emoji_events,
      color: Colors.amber,
    );
  }

  /// ペア機能解放ヒントを表示
  static Future<void> showPairFeatureUnlockHint(BuildContext context) async {
    if (await hasShownHint(hintPairFeature)) return;
    if (!context.mounted) return;

    await _showHintDialog(
      context: context,
      hintId: hintPairFeature,
      title: 'ペア機能が解放されました！',
      message: '友達と一緒に習慣化に取り組めます。\nお互いに励まし合って継続しましょう。',
      icon: Icons.people,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  /// 高度な統計解放ヒントを表示
  static Future<void> showAdvancedStatsUnlockHint(BuildContext context) async {
    if (await hasShownHint(hintAdvancedStats)) return;
    if (!context.mounted) return;

    await _showHintDialog(
      context: context,
      hintId: hintAdvancedStats,
      title: '高度な統計が解放されました！',
      message: '詳細な分析とインサイトが利用できます。\n自分の習慣パターンを深く理解しましょう。',
      icon: Icons.analytics,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }

  /// 実績機能解放ヒントを表示
  static Future<void> showAchievementsUnlockHint(BuildContext context) async {
    if (await hasShownHint(hintAchievements)) return;
    if (!context.mounted) return;

    await _showHintDialog(
      context: context,
      hintId: hintAchievements,
      title: '実績機能が解放されました！',
      message: '様々な実績を獲得して成長を実感しましょう。\n新しい目標に挑戦してみてください。',
      icon: Icons.military_tech,
      color: Colors.purple,
    );
  }

  /// ヒントダイアログを表示
  static Future<void> _showHintDialog({
    required BuildContext context,
    required String hintId,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ProgressiveHintDialog(
          title: title,
          message: message,
          icon: icon,
          color: color,
          onDismiss: () => markHintShown(hintId),
        );
      },
    );
  }

  /// スナックバー形式でヒントを表示
  static Future<void> showHintSnackBar({
    required BuildContext context,
    required String hintId,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) async {
    if (await hasShownHint(hintId)) return;

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '了解',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    await markHintShown(hintId);
  }

  /// オーバーレイ形式でヒントを表示
  static Future<void> showHintOverlay({
    required BuildContext context,
    required String hintId,
    required String message,
    required Widget targetWidget,
    Duration duration = const Duration(seconds: 3),
  }) async {
    if (await hasShownHint(hintId)) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => ProgressiveHintOverlay(
        message: message,
        targetWidget: targetWidget,
        onDismiss: () {
          overlayEntry.remove();
          markHintShown(hintId);
        },
      ),
    );

    overlay.insert(overlayEntry);

    // 自動的に削除
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        markHintShown(hintId);
      }
    });
  }
}

/// プログレッシブヒントダイアログ
class ProgressiveHintDialog extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;

  const ProgressiveHintDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.onDismiss,
  });

  @override
  State<ProgressiveHintDialog> createState() => _ProgressiveHintDialogState();
}

class _ProgressiveHintDialogState extends State<ProgressiveHintDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    widget.onDismiss?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '了解',
                    style: TextStyle(color: widget.color),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// プログレッシブヒントオーバーレイ
class ProgressiveHintOverlay extends StatefulWidget {
  final String message;
  final Widget targetWidget;
  final VoidCallback? onDismiss;

  const ProgressiveHintOverlay({
    super.key,
    required this.message,
    required this.targetWidget,
    this.onDismiss,
  });

  @override
  State<ProgressiveHintOverlay> createState() => _ProgressiveHintOverlayState();
}

class _ProgressiveHintOverlayState extends State<ProgressiveHintOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16 + _slideAnimation.value,
          left: 16,
          right: 16,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}