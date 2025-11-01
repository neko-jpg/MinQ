import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class MinqEmptyState extends StatelessWidget {
  const MinqEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionArea,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? actionArea;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: tokens.spacing.xxl,
            height: tokens.spacing.xxl,
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withAlpha((255 * 0.08).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: tokens.spacing.xl,
              color: tokens.brandPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: tokens.typography.h4.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: tokens.typography.body.copyWith(color: tokens.textMuted),
          ),
          if (actionArea != null) ...<Widget>[
            SizedBox(height: tokens.spacing.md),
            actionArea!,
          ],
        ],
      ),
    );
  }
}
