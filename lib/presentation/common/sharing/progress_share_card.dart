import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minq/domain/social/achievement_share.dart';
import 'package:minq/presentation/common/feedback/haptic_manager.dart';
import 'package:minq/presentation/common/celebration/celebration_system.dart';

/// 進捗共有カードウィジェット
class ProgressShareCard extends StatefulWidget {
  final int currentStreak;
  final int bestStreak;
  final int totalQuests;
  final int completedToday;
  final VoidCallback? onShare;
  final bool showShareButton;

  const ProgressShareCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalQuests,
    required this.completedToday,
    this.onShare,
    this.showShareButton = true,
  });

  @override
  State<ProgressShareCard> createState() => _ProgressShareCardState();
}

class _ProgressShareCardState extends State<ProgressShareCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shareController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shareScaleAnimation;
  
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shareController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shareScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _shareController,
      curve: Curves.easeInOut,
    ));

    // 連続記録が高い場合はパルスアニメーションを開始
    if (widget.currentStreak >= 7) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _cardKey,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _getGradientForStreak(widget.currentStreak),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getPrimaryColor(widget.currentStreak).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildMainStats(),
                    const SizedBox(height: 16),
                    _buildSubStats(),
                    if (widget.showShareButton) ...[
                      const SizedBox(height: 20),
                      _buildShareButton(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '習慣化の記録',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getStreakMessage(widget.currentStreak),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _buildStreakBadge(),
      ],
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.currentStreak}',
            style: TextStyle(
              color: _getPrimaryColor(widget.currentStreak),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '連続記録',
            '${widget.currentStreak}日',
            Icons.local_fire_department,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'ベスト記録',
            '${widget.bestStreak}日',
            Icons.emoji_events,
          ),
        ),
      ],
    );
  }

  Widget _buildSubStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '総クエスト',
            '${widget.totalQuests}個',
            Icons.task_alt,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            '今日完了',
            '${widget.completedToday}個',
            Icons.today,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return AnimatedBuilder(
      animation: _shareScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _shareScaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleShare,
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                '進捗をシェア',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleShare() async {
    HapticManager.selection();
    
    _shareController.forward().then((_) {
      _shareController.reverse();
    });

    // 祝福演出を表示（高い連続記録の場合）
    if (widget.currentStreak >= 7) {
      CelebrationSystem.showCelebration(
        context,
        config: CelebrationSystem.getStreakCelebration(widget.currentStreak),
      );
    }

    // 進捗データを作成
    final progressShare = ProgressShare(
      currentStreak: widget.currentStreak,
      bestStreak: widget.bestStreak,
      totalQuests: widget.totalQuests,
      completedToday: widget.completedToday,
      shareDate: DateTime.now(),
      motivationalMessage: _getMotivationalMessage(),
    );

    // シェア実行のシミュレーション
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('進捗をシェアしました！'),
          backgroundColor: _getPrimaryColor(widget.currentStreak),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    widget.onShare?.call();
  }

  LinearGradient _getGradientForStreak(int streak) {
    if (streak >= 100) {
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 50) {
      return const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 30) {
      return const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 7) {
      return const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getPrimaryColor(int streak) {
    if (streak >= 100) return const Color(0xFFFFD700);
    if (streak >= 50) return const Color(0xFF9C27B0);
    if (streak >= 30) return const Color(0xFF2196F3);
    if (streak >= 7) return const Color(0xFF4CAF50);
    return const Color(0xFF4ECDC4);
  }

  String _getStreakMessage(int streak) {
    if (streak >= 100) return '伝説の継続者！';
    if (streak >= 50) return '継続マスター！';
    if (streak >= 30) return '習慣化成功！';
    if (streak >= 7) return '素晴らしい継続！';
    if (streak >= 3) return '良いペース！';
    return '継続中！';
  }

  String _getMotivationalMessage() {
    final messages = [
      '毎日コツコツ、継続は力なり！',
      '小さな積み重ねが大きな変化を生む',
      '今日も一歩前進！',
      '習慣化で人生が変わる',
      '継続こそが最大の才能',
    ];
    
    return messages[Random().nextInt(messages.length)];
  }
}

/// 進捗共有カードのプレビュー
class ProgressShareCardPreview extends StatelessWidget {
  final ProgressShare progressShare;

  const ProgressShareCardPreview({
    super.key,
    required this.progressShare,
  });

  @override
  Widget build(BuildContext context) {
    return ProgressShareCard(
      currentStreak: progressShare.currentStreak,
      bestStreak: progressShare.bestStreak,
      totalQuests: progressShare.totalQuests,
      completedToday: progressShare.completedToday,
      showShareButton: false,
    );
  }
}