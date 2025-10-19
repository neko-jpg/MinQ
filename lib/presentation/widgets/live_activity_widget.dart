import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/social_proof_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class LiveActivityWidget extends ConsumerStatefulWidget {
  const LiveActivityWidget({
    super.key,
    this.category,
    this.showEncouragement = true,
    this.compact = false,
  });

  final String? category;
  final bool showEncouragement;
  final bool compact;

  @override
  ConsumerState<LiveActivityWidget> createState() => _LiveActivityWidgetState();
}

class _LiveActivityWidgetState extends ConsumerState<LiveActivityWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  StreamSubscription<LiveActivityUpdate>? _activitySubscription;
  StreamSubscription<SocialStats>? _statsSubscription;
  
  CurrentActivityStats? _currentStats;
  List<ActivityEvent> _recentActivities = [];
  SocialStats? _socialStats;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _startListening();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _activitySubscription?.cancel();
    _statsSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    _activitySubscription = SocialProofService.instance.activityStream.listen(
      _handleActivityUpdate,
    );
    
    _statsSubscription = SocialProofService.instance.statsStream.listen(
      _handleStatsUpdate,
    );
  }

  void _loadInitialData() async {
    try {
      final stats = await SocialProofService.instance.getCurrentStats();
      if (mounted) {
        setState(() {
          _currentStats = stats;
        });
      }
    } catch (e) {
      // エラーハンドリング
    }
  }

  void _handleActivityUpdate(LiveActivityUpdate update) {
    if (!mounted) return;

    setState(() {
      switch (update.type) {
        case ActivityUpdateType.newActivity:
          if (update.activity != null) {
            _recentActivities.insert(0, update.activity!);
            if (_recentActivities.length > 10) {
              _recentActivities = _recentActivities.take(10).toList();
            }
          }
          break;
        case ActivityUpdateType.completion:
          if (update.activity != null) {
            _recentActivities.insert(0, update.activity!);
            _triggerCelebrationAnimation();
          }
          break;
        case ActivityUpdateType.celebration:
          _triggerCelebrationAnimation();
          break;
        case ActivityUpdateType.statsUpdate:
          // 統計更新は別途処理
          break;
        case ActivityUpdateType.encouragement:
          _showEncouragementEffect();
          break;
      }
    });

    // 新しいアクティビティがあった場合のアニメーション
    if (update.type == ActivityUpdateType.newActivity ||
        update.type == ActivityUpdateType.completion) {
      _slideController.forward().then((_) {
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            _slideController.reverse();
          }
        });
      });
    }
  }

  void _handleStatsUpdate(SocialStats stats) {
    if (mounted) {
      setState(() {
        _socialStats = stats;
      });
    }
  }

  void _triggerCelebrationAnimation() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  void _showEncouragementEffect() {
    // 励ましエフェクトの表示
    _pulseController.repeat(reverse: true);
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _currentStats == null) {
      return const SizedBox.shrink();
    }

    return widget.compact ? _buildCompactWidget() : _buildFullWidget();
  }

  Widget _buildCompactWidget() {
    final tokens = context.tokens;
    final stats = _currentStats!;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing(3),
              vertical: tokens.spacing(2),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tokens.brandPrimary.withOpacity(0.8),
                  tokens.brandPrimary.withOpacity(0.6),
                ],
              ),
              borderRadius: tokens.cornerMedium(),
              boxShadow: tokens.shadowSoft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPulsingDot(),
                SizedBox(width: tokens.spacing(2)),
                Text(
                  '${stats.totalActiveUsers}人が実行中',
                  style: tokens.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stats.mostPopularCategory != null) ...[
                  SizedBox(width: tokens.spacing(2)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing(1),
                      vertical: tokens.spacing(0.5),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: tokens.cornerSmall(),
                    ),
                    child: Text(
                      _getCategoryEmoji(stats.mostPopularCategory!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullWidget() {
    final tokens = context.tokens;
    final stats = _currentStats!;

    return Column(
      children: [
        // メインステータス
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(tokens.spacing(4)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tokens.brandPrimary,
                      tokens.brandPrimary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: tokens.cornerLarge(),
                  boxShadow: tokens.shadowSoft,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildPulsingDot(size: 12),
                        SizedBox(width: tokens.spacing(2)),
                        Text(
                          'ライブアクティビティ',
                          style: tokens.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const Spacer(),
                        _buildToggleButton(),
                      ],
                    ),
                    SizedBox(height: tokens.spacing(3)),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            '${stats.totalActiveUsers}人',
                            'オンライン',
                            Icons.people,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            '${stats.totalActiveUsers}人',
                            '実行中',
                            Icons.play_circle,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            '${stats.recentCompletions}個',
                            '完了',
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // カテゴリ別統計
        if (stats.categoryStats.isNotEmpty) ...[
          SizedBox(height: tokens.spacing(3)),
          _buildCategoryStats(stats),
        ],

        // 最近のアクティビティ
        if (_recentActivities.isNotEmpty) ...[
          SizedBox(height: tokens.spacing(3)),
          SlideTransition(
            position: _slideAnimation,
            child: _buildRecentActivities(),
          ),
        ],

        // 励ましメッセージ
        if (_socialStats?.encouragementMessages.isNotEmpty == true) ...[
          SizedBox(height: tokens.spacing(3)),
          _buildEncouragementMessages(),
        ],
      ],
    );
  }

  Widget _buildPulsingDot({double size = 8}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8 + 0.2 * _pulseController.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    final tokens = context.tokens;

    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(height: tokens.spacing(1)),
        Text(
          value,
          style: tokens.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: tokens.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isVisible = !_isVisible;
        });
      },
      icon: Icon(
        _isVisible ? Icons.visibility : Icons.visibility_off,
        color: Colors.white.withOpacity(0.8),
        size: 20,
      ),
    );
  }

  Widget _buildCategoryStats(CurrentActivityStats stats) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'カテゴリ別アクティビティ',
            style: tokens.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacing(2)),
          Wrap(
            spacing: tokens.spacing(2),
            runSpacing: tokens.spacing(2),
            children: stats.categoryStats.entries.map((entry) {
              return _buildCategoryChip(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, int count) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(2),
        vertical: tokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withOpacity(0.1),
        borderRadius: tokens.cornerSmall(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getCategoryEmoji(category),
            style: const TextStyle(fontSize: 16),
          ),
          SizedBox(width: tokens.spacing(1)),
          Text(
            '$count人',
            style: tokens.bodySmall.copyWith(
              color: tokens.brandPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerMedium(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: tokens.brandPrimary,
                size: 16,
              ),
              SizedBox(width: tokens.spacing(1)),
              Text(
                '最近のアクティビティ',
                style: tokens.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(2)),
          ...._recentActivities.take(3).map((activity) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing(1)),
              child: _buildActivityItem(activity),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityEvent activity) {
    final tokens = context.tokens;
    final timeAgo = _formatTimeAgo(activity.timestamp);

    return Row(
      children: [
        Text(
          activity.avatar,
          style: const TextStyle(fontSize: 16),
        ),
        SizedBox(width: tokens.spacing(2)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: tokens.bodySmall.copyWith(color: tokens.textPrimary),
              children: [
                TextSpan(
                  text: activity.nickname,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: activity.type == ActivityType.completion ? 'が' : 'が',
                ),
                TextSpan(
                  text: activity.habitTitle,
                  style: TextStyle(color: tokens.brandPrimary),
                ),
                TextSpan(
                  text: activity.type == ActivityType.completion ? 'を完了' : 'を開始',
                ),
              ],
            ),
          ),
        ),
        Text(
          timeAgo,
          style: tokens.bodySmall.copyWith(
            color: tokens.textMuted,
          ),
        ),
        if (widget.showEncouragement && activity.type == ActivityType.start) ...[
          SizedBox(width: tokens.spacing(2)),
          _buildEncouragementButton(activity),
        ],
      ],
    );
  }

  Widget _buildEncouragementButton(ActivityEvent activity) {
    final tokens = context.tokens;

    return GestureDetector(
      onTap: () => _sendEncouragement(activity.userId),
      child: Container(
        padding: EdgeInsets.all(tokens.spacing(1)),
        decoration: BoxDecoration(
          color: tokens.encouragement.withOpacity(0.1),
          borderRadius: tokens.cornerSmall(),
        ),
        child: Icon(
          Icons.favorite,
          size: 12,
          color: tokens.encouragement,
        ),
      ),
    );
  }

  Widget _buildEncouragementMessages() {
    final tokens = context.tokens;
    final messages = _socialStats!.encouragementMessages;

    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        color: tokens.encouragement.withOpacity(0.1),
        borderRadius: tokens.cornerMedium(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.campaign,
                color: tokens.encouragement,
                size: 16,
              ),
              SizedBox(width: tokens.spacing(1)),
              Text(
                '励ましメッセージ',
                style: tokens.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.encouragement,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(2)),
          ...messages.map((message) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing(1)),
              child: Text(
                message,
                style: tokens.bodySmall.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'fitness':
      case 'exercise':
        return '💪';
      case 'mindfulness':
      case 'meditation':
        return '🧘';
      case 'learning':
      case 'study':
        return '📚';
      case 'health':
        return '🏥';
      case 'creativity':
        return '🎨';
      case 'productivity':
        return '⚡';
      default:
        return '⭐';
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }

  void _sendEncouragement(String targetUserId) async {
    try {
      await SocialProofService.instance.sendEncouragementStamp(
        targetUserId: targetUserId,
        stampType: EncouragementType.heart,
      );
    } catch (e) {
      // エラーハンドリング
    }
  }
}

/// ライブアクティビティ設定画面
class LiveActivitySettingsScreen extends ConsumerStatefulWidget {
  const LiveActivitySettingsScreen({super.key});

  @override
  ConsumerState<LiveActivitySettingsScreen> createState() => _LiveActivitySettingsScreenState();
}

class _LiveActivitySettingsScreenState extends ConsumerState<LiveActivitySettingsScreen> {
  late SocialSettings _settings;

  @override
  void initState() {
    super.initState();
    // TODO: 保存された設定を読み込み
    _settings = const SocialSettings();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ライブアクティビティ設定',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プライバシー設定
            _buildSettingsSection(
              'プライバシー設定',
              [
                SwitchListTile(
                  title: const Text('アクティビティを表示'),
                  subtitle: const Text('他のユーザーにあなたの活動を表示します'),
                  value: _settings.showActivity,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(showActivity: value);
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('交流を許可'),
                  subtitle: const Text('他のユーザーからの励ましを受け取ります'),
                  value: _settings.allowInteraction,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(allowInteraction: value);
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: tokens.spacing(6)),

            // 通知設定
            _buildSettingsSection(
              '通知設定',
              [
                SwitchListTile(
                  title: const Text('触覚フィードバック'),
                  subtitle: const Text('アクティビティ時に振動でお知らせします'),
                  value: _settings.enableHaptics,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(enableHaptics: value);
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('祝福エフェクト'),
                  subtitle: const Text('完了時に祝福エフェクトを表示します'),
                  value: _settings.enableCelebration,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(enableCelebration: value);
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: tokens.spacing(6)),

            // 説明
            Card(
              elevation: 0,
              color: tokens.brandPrimary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: tokens.cornerLarge(),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.spacing(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: tokens.brandPrimary,
                        ),
                        SizedBox(width: tokens.spacing(2)),
                        Text(
                          'ライブアクティビティについて',
                          style: tokens.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    Text(
                      'ライブアクティビティ機能では、他のユーザーと一緒に習慣に取り組んでいることを実感できます。'
                      'すべての情報は匿名化されており、個人を特定することはできません。',
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tokens.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacing(3)),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: tokens.cornerLarge(),
            side: BorderSide(color: tokens.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}