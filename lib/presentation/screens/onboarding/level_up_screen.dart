import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/onboarding/progressive_onboarding.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// レベルアップ画面
/// 新しいレベルに到達した時の演出画面
class LevelUpScreen extends ConsumerStatefulWidget {
  final int newLevel;
  final OnboardingLevel levelInfo;
  final VoidCallback? onContinue;

  const LevelUpScreen({
    super.key,
    required this.newLevel,
    required this.levelInfo,
    this.onContinue,
  });

  @override
  ConsumerState<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends ConsumerState<LevelUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _featuresController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _featuresController, curve: Curves.easeOutBack),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _featuresController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(230),
      body: SafeArea(
        child: Stack(
          children: [
            // 背景エフェクト
            _buildBackgroundEffects(tokens),

            // メインコンテンツ
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(tokens.spacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // レベルアップアニメーション
                    _buildLevelUpAnimation(tokens),

                    SizedBox(height: tokens.spacing.xl),

                    // レベル情報
                    _buildLevelInfo(tokens),

                    SizedBox(height: tokens.spacing.xl),

                    // 解放された機能
                    _buildUnlockedFeatures(tokens),

                    SizedBox(height: tokens.spacing.xl),

                    // 続行ボタン
                    _buildContinueButton(tokens),
                  ],
                ),
              ),
            ),

            // 閉じるボタン
            Positioned(
              top: tokens.spacing.md,
              right: tokens.spacing.md,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects(MinqTheme tokens) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5 * _mainController.value,
                colors: [
                  tokens.brandPrimary.withAlpha(77),
                  Colors.purple.withAlpha(51),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelUpAnimation(MinqTheme tokens) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              // 星のアニメーション
              Container(
                width: tokens.spacing.xl * 2,
                height: tokens.spacing.xl * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.yellow.shade300, Colors.orange.shade400],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withAlpha(128),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.star,
                  size: tokens.spacing.lg * 2,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: tokens.spacing.md),

              // レベルアップテキスト
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'LEVEL UP!',
                  style: tokens.typography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelInfo(MinqTheme tokens) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(26),
          borderRadius: tokens.cornerLarge(),
          border: Border.all(color: Colors.white.withAlpha(77), width: 1),
        ),
        child: Column(
          children: [
            // レベル番号
            Container(
              width: tokens.spacing.xl,
              height: tokens.spacing.xl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [tokens.brandPrimary, Colors.purple.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: tokens.brandPrimary.withAlpha(128),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${widget.newLevel}',
                  style: tokens.typography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: tokens.spacing.md),

            // レベルタイトル
            Text(
              widget.levelInfo.title,
              style: tokens.typography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: tokens.spacing.sm),

            // レベル説明
            Text(
              widget.levelInfo.description,
              style: tokens.typography.bodyLarge.copyWith(
                color: Colors.white.withAlpha(204),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedFeatures(MinqTheme tokens) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _featuresController,
        child: Container(
          padding: EdgeInsets.all(tokens.spacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: tokens.cornerLarge(),
            border: Border.all(color: Colors.white.withAlpha(51)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_open,
                    color: Colors.green.shade400,
                    size: tokens.spacing.lg,
                  ),
                  SizedBox(width: tokens.spacing.sm),
                  Text(
                    '解放された機能',
                    style: tokens.typography.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: tokens.spacing.md),

              ...widget.levelInfo.unlockedFeatures.map((feature) {
                return _buildFeatureItem(tokens, feature);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(MinqTheme tokens, String featureId) {
    final featureInfo = _getFeatureInfo(featureId);

    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing.sm),
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: tokens.cornerMedium(),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.spacing.lg,
            height: tokens.spacing.lg,
            decoration: BoxDecoration(
              color: Colors.green.shade400.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              featureInfo.icon,
              color: Colors.green.shade400,
              size: tokens.spacing.md,
            ),
          ),

          SizedBox(width: tokens.spacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featureInfo.name,
                  style: tokens.typography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  featureInfo.description,
                  style: tokens.typography.bodySmall.copyWith(
                    color: Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.check_circle,
            color: Colors.green.shade400,
            size: tokens.spacing.md,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(MinqTheme tokens) {
    return FadeTransition(
      opacity: _featuresController,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            widget.onContinue?.call();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.brandPrimary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
            elevation: 8,
            shadowColor: tokens.brandPrimary.withAlpha(128),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '新機能を試してみる',
                style: tokens.typography.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Icon(Icons.arrow_forward, size: tokens.spacing.md),
            ],
          ),
        ),
      ),
    );
  }

  FeatureInfo _getFeatureInfo(String featureId) {
    return switch (featureId) {
      'quest_create' => const FeatureInfo(
        name: 'クエスト作成',
        description: '新しい習慣を作成できます',
        icon: Icons.add_task,
      ),
      'quest_complete' => const FeatureInfo(
        name: 'クエスト完了',
        description: '習慣を記録して進捗を追跡',
        icon: Icons.check_circle,
      ),
      'basic_stats' => const FeatureInfo(
        name: '基本統計',
        description: '進捗と成果を確認',
        icon: Icons.bar_chart,
      ),
      'notifications' => const FeatureInfo(
        name: '通知機能',
        description: 'リマインダーでサポート',
        icon: Icons.notifications,
      ),
      'streak_tracking' => const FeatureInfo(
        name: 'ストリーク追跡',
        description: '連続記録を管理',
        icon: Icons.local_fire_department,
      ),
      'weekly_stats' => const FeatureInfo(
        name: '週間統計',
        description: '詳細な分析データ',
        icon: Icons.analytics,
      ),
      'pair_feature' => const FeatureInfo(
        name: 'ペア機能',
        description: '友達と一緒に習慣形成',
        icon: Icons.people,
      ),
      'advanced_stats' => const FeatureInfo(
        name: '高度な統計',
        description: '詳細な分析とレポート',
        icon: Icons.insights,
      ),
      'export_data' => const FeatureInfo(
        name: 'データエクスポート',
        description: 'データをバックアップ',
        icon: Icons.download,
      ),
      'tags' => const FeatureInfo(
        name: 'タグ機能',
        description: '習慣を分類・整理',
        icon: Icons.label,
      ),
      'achievements' => const FeatureInfo(
        name: '実績システム',
        description: 'バッジと称号を獲得',
        icon: Icons.emoji_events,
      ),
      'events' => const FeatureInfo(
        name: 'イベント機能',
        description: '特別なチャレンジ',
        icon: Icons.event,
      ),
      'templates' => const FeatureInfo(
        name: 'テンプレート',
        description: '習慣のテンプレート',
        icon: Icons.article,
      ),
      'timer' => const FeatureInfo(
        name: 'タイマー機能',
        description: '集中時間を測定',
        icon: Icons.timer,
      ),
      'advanced_customization' => const FeatureInfo(
        name: '高度なカスタマイズ',
        description: 'アプリを自分好みに',
        icon: Icons.tune,
      ),
      _ => const FeatureInfo(
        name: '新機能',
        description: '新しい機能が解放されました',
        icon: Icons.star,
      ),
    };
  }
}

/// 機能情報
class FeatureInfo {
  final String name;
  final String description;
  final IconData icon;

  const FeatureInfo({
    required this.name,
    required this.description,
    required this.icon,
  });
}
