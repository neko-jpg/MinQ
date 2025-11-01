import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:minq/core/challenges/offline_challenge_service.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';
import 'package:minq/presentation/widgets/challenges/challenge_progress_animation.dart';
import 'package:minq/presentation/widgets/common/offline_indicator.dart';
import 'package:minq/presentation/widgets/common/shimmer_loading.dart';

/// Enhanced challenge card with modern design and offline support
class EnhancedChallengeCard extends ConsumerStatefulWidget {
  const EnhancedChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.onProgressUpdate,
    this.showOfflineIndicator = true,
  });

  final LocalChallenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onProgressUpdate;
  final bool showOfflineIndicator;

  @override
  ConsumerState<EnhancedChallengeCard> createState() =>
      _EnhancedChallengeCardState();
}

class _EnhancedChallengeCardState extends ConsumerState<EnhancedChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        widget.challenge.progress >= widget.challenge.targetValue;
    final progressPercentage =
        widget.challenge.targetValue > 0
            ? widget.challenge.progress / widget.challenge.targetValue
            : 0.0;
    final isExpiringSoon = _isExpiringSoon();
    final isOffline = widget.challenge.syncStatus != SyncStatus.synced;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.onTap,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: MinqTokens.spacing(4),
                vertical: MinqTokens.spacing(2),
              ),
              decoration: BoxDecoration(
                borderRadius: MinqTokens.cornerLarge(),
                gradient: _getCardGradient(isCompleted, isExpiringSoon),
                boxShadow: [
                  BoxShadow(
                    color: _getGlowColor(
                      isCompleted,
                      isExpiringSoon,
                    ).withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 12 + (8 * _glowAnimation.value),
                    spreadRadius: 2 + (2 * _glowAnimation.value),
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: MinqTokens.cornerLarge(),
                child: Stack(
                  children: [
                    // Background pattern
                    _buildBackgroundPattern(),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(MinqTokens.spacing(4)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with title and status indicators
                          _buildHeader(isCompleted, isExpiringSoon, isOffline),

                          SizedBox(height: MinqTokens.spacing(2)),

                          // Description
                          _buildDescription(),

                          SizedBox(height: MinqTokens.spacing(3)),

                          // Progress section
                          _buildProgressSection(
                            progressPercentage,
                            isCompleted,
                          ),

                          SizedBox(height: MinqTokens.spacing(3)),

                          // Footer with rewards and time
                          _buildFooter(isExpiringSoon),
                        ],
                      ),
                    ),

                    // Completion overlay
                    if (isCompleted) _buildCompletionOverlay(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _ChallengeCardPatternPainter(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCompleted, bool isExpiringSoon, bool isOffline) {
    return Row(
      children: [
        // Challenge icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: MinqTokens.cornerMedium(),
          ),
          child: Icon(_getChallengeIcon(), color: Colors.white, size: 24),
        ),

        SizedBox(width: MinqTokens.spacing(3)),

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.challenge.title,
                      style: MinqTokens.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOffline && widget.showOfflineIndicator)
                    const OfflineIndicator(size: 16),
                ],
              ),
              SizedBox(height: MinqTokens.spacing(1)),
              Text(
                _getSubtitle(isExpiringSoon),
                style: MinqTokens.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),

        // Status badge
        _buildStatusBadge(isCompleted, isExpiringSoon),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.challenge.description,
      style: MinqTokens.bodyMedium.copyWith(
        color: Colors.white.withOpacity(0.9),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressSection(double progressPercentage, bool isCompleted) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '進捗',
              style: MinqTokens.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${widget.challenge.progress}/${widget.challenge.targetValue}',
              style: MinqTokens.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: MinqTokens.spacing(2)),

        // Animated progress bar
        ChallengeProgressAnimation(
          progress: progressPercentage,
          isCompleted: isCompleted,
          height: 8,
        ),

        SizedBox(height: MinqTokens.spacing(1)),

        // Progress percentage
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progressPercentage * 100).toInt()}%',
            style: MinqTokens.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isExpiringSoon) {
    return Row(
      children: [
        // XP reward
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MinqTokens.spacing(2),
            vertical: MinqTokens.spacing(1),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: MinqTokens.cornerSmall(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 16),
              SizedBox(width: MinqTokens.spacing(1)),
              Text(
                '${widget.challenge.xpReward} XP',
                style: MinqTokens.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Time remaining
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpiringSoon ? Icons.schedule : Icons.access_time,
              color:
                  isExpiringSoon
                      ? Colors.orange.shade200
                      : Colors.white.withOpacity(0.8),
              size: 16,
            ),
            SizedBox(width: MinqTokens.spacing(1)),
            Text(
              _getTimeRemaining(),
              style: MinqTokens.bodySmall.copyWith(
                color:
                    isExpiringSoon
                        ? Colors.orange.shade200
                        : Colors.white.withOpacity(0.8),
                fontWeight:
                    isExpiringSoon ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isCompleted, bool isExpiringSoon) {
    if (isCompleted) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: MinqTokens.spacing(2),
          vertical: MinqTokens.spacing(1),
        ),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.3),
          borderRadius: MinqTokens.cornerSmall(),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade200, size: 16),
            SizedBox(width: MinqTokens.spacing(1)),
            Text(
              '完了',
              style: MinqTokens.bodySmall.copyWith(
                color: Colors.green.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isExpiringSoon) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: MinqTokens.spacing(2),
          vertical: MinqTokens.spacing(1),
        ),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.3),
          borderRadius: MinqTokens.cornerSmall(),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, color: Colors.orange.shade200, size: 16),
            SizedBox(width: MinqTokens.spacing(1)),
            Text(
              '期限間近',
              style: MinqTokens.bodySmall.copyWith(
                color: Colors.orange.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MinqTokens.spacing(2),
        vertical: MinqTokens.spacing(1),
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: MinqTokens.cornerSmall(),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        'アクティブ',
        style: MinqTokens.bodySmall.copyWith(
          color: Colors.blue.shade200,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: MinqTokens.cornerLarge(),
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.green.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.green.shade200,
            size: 64,
          ),
        ),
      ),
    );
  }

  LinearGradient _getCardGradient(bool isCompleted, bool isExpiringSoon) {
    if (isCompleted) {
      return LinearGradient(
        colors: [Colors.green.shade600, Colors.green.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (isExpiringSoon) {
      return LinearGradient(
        colors: [Colors.orange.shade600, Colors.red.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return LinearGradient(
      colors: [
        MinqTokens.brandPrimary,
        MinqTokens.brandPrimary.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getGlowColor(bool isCompleted, bool isExpiringSoon) {
    if (isCompleted) return Colors.green;
    if (isExpiringSoon) return Colors.orange;
    return MinqTokens.brandPrimary;
  }

  IconData _getChallengeIcon() {
    // You could add a type field to LocalChallenge and use it here
    // For now, we'll use a default icon based on the title/description
    final title = widget.challenge.title.toLowerCase();
    if (title.contains('daily') || title.contains('毎日')) return Icons.today;
    if (title.contains('weekly') || title.contains('週間'))
      return Icons.date_range;
    if (title.contains('streak') || title.contains('連続'))
      return Icons.local_fire_department;
    if (title.contains('social') || title.contains('ソーシャル'))
      return Icons.people;
    return Icons.emoji_events;
  }

  String _getSubtitle(bool isExpiringSoon) {
    final participantCount = widget.challenge.participants.length;
    if (participantCount > 1) {
      return '$participantCount人が参加中';
    }
    return isExpiringSoon ? '期限が迫っています' : 'チャレンジ中';
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final endDate = widget.challenge.endDate;
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return '終了';
    }

    if (difference.inDays > 0) {
      return '残り${difference.inDays}日';
    }

    if (difference.inHours > 0) {
      return '残り${difference.inHours}時間';
    }

    return '残り${difference.inMinutes}分';
  }

  bool _isExpiringSoon() {
    final now = DateTime.now();
    final endDate = widget.challenge.endDate;
    final difference = endDate.difference(now);

    // Consider "expiring soon" if less than 24 hours remain
    return difference.inHours < 24 && difference.isPositive;
  }
}

/// Custom painter for background pattern
class _ChallengeCardPatternPainter extends CustomPainter {
  final Color color;

  _ChallengeCardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // Draw subtle geometric pattern
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
