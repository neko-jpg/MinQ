import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Loading overlay widget that shows a loading indicator over content
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);
    
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: theme.overlay,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theme.brandPrimary),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: theme.typography.bodyMedium.copyWith(
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}