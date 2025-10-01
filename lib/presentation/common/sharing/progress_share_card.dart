import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/social/achievement_share.dart';
import 'package:minq/presentation/common/feedback/haptic_manager.dart';
import 'package:minq/presentation/common/celebration/celebration_system.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 進捗共有カードウィジェット
class ProgressShareCard extends ConsumerStatefulWidget {
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
  ConsumerState<ProgressShareCard> createState() => _ProgressShareCardState();
}

class _ProgressShareCardState extends ConsumerState<ProgressShareCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shareController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shareScaleAnimation;

  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

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
              onPressed: _isSharing ? null : _handleShare,
              icon: _isSharing
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.share, color: Colors.white),
              label: Text(
                _isSharing ? '準備中...' : '進捗をシェア',
                style: const TextStyle(
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

  Future<void> _handleShare() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    HapticManager.selection();
    _shareController.forward().then((_) => _shareController.reverse());

    try {
      final boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/minq_progress.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'MinQで${widget.currentStreak}日連続で目標達成中！ #MinQ #習慣化アプリ',
      );

      // Log analytics event on successful share
      ref.read(analyticsServiceProvider).logEvent(
        'share_progress',
        parameters: {
          'current_streak': widget.currentStreak,
          'total_quests': widget.totalQuests,
        },
      );

    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shareFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
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