import 'package:flutter/material.dart';
import 'package:minq/domain/time_capsule/time_capsule.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class TimeCapsuleCard extends StatelessWidget {
  const TimeCapsuleCard({
    super.key,
    required this.capsule,
    required this.onTap,
  });

  final TimeCapsule capsule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDelivered = capsule.deliveryDate.isBefore(DateTime.now());
    final daysUntilDelivery =
        capsule.deliveryDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(
          color: isDelivered ? tokens.encouragement : tokens.border,
          width: isDelivered ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(tokens.spacing.sm),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? tokens.encouragement.withAlpha((255 * 0.1).round())
                          : tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                    ),
                    child: Icon(
                      isDelivered ? Icons.mail : Icons.schedule_send,
                      color:
                          isDelivered
                              ? tokens.encouragement
                              : tokens.brandPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: tokens.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDelivered ? '配信済み' : '配信待ち',
                          style: tokens.typography.caption.copyWith(
                            color:
                                isDelivered
                                    ? tokens.encouragement
                                    : tokens.brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${capsule.createdAt.year}年${capsule.createdAt.month}月${capsule.createdAt.day}日作成',
                          style: tokens.typography.caption.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDelivered)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.sm,
                        vertical: tokens.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.encouragement,
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Text(
                        '開封可能',
                        style: tokens.typography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.sm,
                        vertical: tokens.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.surfaceVariant,
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Text(
                        '$daysUntilDelivery日後',
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: tokens.spacing.md),

              // メッセージプレビュー
              Text(
                _truncateMessage(capsule.message),
                style:
                    tokens.typography.body.copyWith(color: tokens.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: tokens.spacing.md),

              // 配信日
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: tokens.textMuted),
                  SizedBox(width: tokens.spacing.xs),
                  Text(
                    '配信日: ${capsule.deliveryDate.year}年${capsule.deliveryDate.month}月${capsule.deliveryDate.day}日',
                    style:
                        tokens.typography.caption.copyWith(color: tokens.textMuted),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: tokens.textMuted,
                  ),
                ],
              ),

              // 開封アニメーション（配信済みの場合）
              if (isDelivered) ...[
                SizedBox(height: tokens.spacing.sm),
                _OpeningAnimation(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _truncateMessage(String message) {
    if (message.length <= 60) return message;
    return '${message.substring(0, 60)}...';
  }
}

class _OpeningAnimation extends StatefulWidget {
  @override
  State<_OpeningAnimation> createState() => _OpeningAnimationState();
}

class _OpeningAnimationState extends State<_OpeningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.sm,
                vertical: tokens.spacing.xs,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tokens.encouragement.withAlpha((255 * 0.8).round()),
                    tokens.joyAccent.withAlpha((255 * 0.8).round()),
                  ],
                ),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  SizedBox(width: tokens.spacing.xs),
                  Text(
                    'タップして開封',
                    style: tokens.typography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
