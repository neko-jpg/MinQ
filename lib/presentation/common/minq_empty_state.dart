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
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: tokens.spacing(20),
            height: tokens.spacing(20),
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: tokens.spacing(12),
              color: tokens.brandPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing(6)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
          ),
          SizedBox(height: tokens.spacing(3)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          if (actionArea != null) ...<Widget>[
            SizedBox(height: tokens.spacing(5)),
            actionArea!,
          ],
        ],
      ),
    );
  }
}