import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';
import 'package:minq/presentation/widgets/micro_interactions.dart';

/// Polished card components with enhanced shadows, gradients, and visual hierarchy
/// Replaces basic card designs with professional UI components

/// Primary card with gradient background and enhanced shadow
class PolishedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool elevated;
  final bool interactive;
  final String? semanticLabel;

  const PolishedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.elevated = true,
    this.interactive = false,
    this.semanticLabel,
  });

  @override
  State<PolishedCard> createState() => _PolishedCardState();
}

class _PolishedCardState extends State<PolishedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.interactive ? 0.98 : 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: widget.interactive ? 1.5 : 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.interactive) {
      setState(() => _isPressed = true);
      _controller.forward();
      MicroInteractions.tapFeedback();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding ?? EdgeInsets.all(MinqTokens.spacing(4)),
      decoration: BoxDecoration(
        color:
            widget.gradient == null
                ? (widget.backgroundColor ?? MinqTokens.surface)
                : null,
        gradient: widget.gradient,
        borderRadius: MinqTokens.cornerLarge(),
        boxShadow:
            widget.elevated
                ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(
                      (25 * _shadowAnimation.value).round(),
                    ),
                    blurRadius: 10 * _shadowAnimation.value,
                    offset: const Offset(0, 5),
                  ),
                ]
                : null,
        border:
            !widget.elevated
                ? Border.all(color: const Color(0xFFE5E7EB), width: 1)
                : null,
      ),
      child: widget.child,
    );

    if (widget.interactive && widget.onTap != null) {
      cardContent = Semantics(
        label: widget.semanticLabel,
        button: true,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: cardContent,
              );
            },
          ),
        ),
      );
    }

    return cardContent;
  }
}

/// Feature card with gradient background and icon
class PolishedFeatureCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool isEnabled;
  final Widget? trailing;

  const PolishedFeatureCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.primaryColor,
    this.secondaryColor,
    this.isEnabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? MinqTokens.brandPrimary;
    final secondary =
        secondaryColor ?? Color.lerp(primary, Colors.white, 0.2) ?? primary;

    return PolishedCard(
      interactive: isEnabled && onTap != null,
      onTap: onTap,
      gradient: LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: MinqTokens.cornerMedium(),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: MinqTokens.spacing(4)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MinqTokens.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: MinqTokens.spacing(1)),
                  Text(
                    subtitle!,
                    style: MinqTokens.bodySmall.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: MinqTokens.spacing(2)),
            trailing!,
          ] else if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha(179),
              size: 16,
            ),
        ],
      ),
    );
  }
}

/// Stats card with progress indicator and enhanced visuals
class PolishedStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final double? progress;
  final Color? accentColor;
  final VoidCallback? onTap;

  const PolishedStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.progress,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? MinqTokens.brandPrimary;

    return PolishedCard(
      interactive: onTap != null,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(25),
                    borderRadius: MinqTokens.cornerSmall(),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                SizedBox(width: MinqTokens.spacing(2)),
              ],
              Expanded(
                child: Text(
                  title,
                  style: MinqTokens.bodyMedium.copyWith(
                    color: MinqTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MinqTokens.spacing(4)),
          Text(
            value,
            style: MinqTokens.titleLarge.copyWith(
              color: MinqTokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: MinqTokens.spacing(1)),
            Text(
              subtitle!,
              style: MinqTokens.bodySmall.copyWith(
                color: MinqTokens.textSecondary,
              ),
            ),
          ],
          if (progress != null) ...[
            SizedBox(height: MinqTokens.spacing(4)),
            ClipRRect(
              borderRadius: MinqTokens.cornerSmall(),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: accent.withAlpha(25),
                valueColor: AlwaysStoppedAnimation(accent),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Action card with call-to-action button
class PolishedActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final VoidCallback onAction;
  final IconData? icon;
  final Color? accentColor;
  final bool isDestructive;

  const PolishedActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionText,
    required this.onAction,
    this.icon,
    this.accentColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        isDestructive
            ? const Color(0xFFEF4444)
            : (accentColor ?? MinqTokens.brandPrimary);

    return PolishedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(25),
                    borderRadius: MinqTokens.cornerMedium(),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                SizedBox(width: MinqTokens.spacing(4)),
              ],
              Expanded(
                child: Text(
                  title,
                  style: MinqTokens.titleMedium.copyWith(
                    color: MinqTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MinqTokens.spacing(2)),
          Text(
            description,
            style: MinqTokens.bodyMedium.copyWith(
              color: MinqTokens.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: MinqTokens.spacing(6)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: MinqTokens.cornerMedium(),
                ),
                padding: EdgeInsets.symmetric(vertical: MinqTokens.spacing(4)),
              ),
              child: Text(
                actionText,
                style: MinqTokens.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification card with dismiss functionality
class PolishedNotificationCard extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool isDismissible;

  const PolishedNotificationCard({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.accentColor,
    this.onTap,
    this.onDismiss,
    this.isDismissible = true,
  });

  @override
  State<PolishedNotificationCard> createState() =>
      _PolishedNotificationCardState();
}

class _PolishedNotificationCardState extends State<PolishedNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _dismissController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _dismissController.forward();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? MinqTokens.brandPrimary;

    return AnimatedBuilder(
      animation: _dismissController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(300 * _slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: PolishedCard(
              interactive: widget.onTap != null,
              onTap: widget.onTap,
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent.withAlpha(25),
                        borderRadius: MinqTokens.cornerSmall(),
                      ),
                      child: Icon(widget.icon, color: accent, size: 18),
                    ),
                    SizedBox(width: MinqTokens.spacing(4)),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: MinqTokens.bodyLarge.copyWith(
                            color: MinqTokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: MinqTokens.spacing(1)),
                        Text(
                          widget.message,
                          style: MinqTokens.bodySmall.copyWith(
                            color: MinqTokens.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isDismissible) ...[
                    SizedBox(width: MinqTokens.spacing(2)),
                    GestureDetector(
                      onTap: _handleDismiss,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: MinqTokens.textSecondary.withAlpha(25),
                          borderRadius: MinqTokens.cornerSmall(),
                        ),
                        child: Icon(
                          Icons.close,
                          color: MinqTokens.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Progress card with animated progress indicator
class PolishedProgressCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final double progress;
  final String progressText;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const PolishedProgressCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.progress,
    required this.progressText,
    this.icon,
    this.accentColor,
    this.onTap,
  });

  @override
  State<PolishedProgressCard> createState() => _PolishedProgressCardState();
}

class _PolishedProgressCardState extends State<PolishedProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _progressController.forward();
  }

  @override
  void didUpdateWidget(PolishedProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
      );
      _progressController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? MinqTokens.brandPrimary;

    return PolishedCard(
      interactive: widget.onTap != null,
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(25),
                    borderRadius: MinqTokens.cornerMedium(),
                  ),
                  child: Icon(widget.icon, color: accent, size: 20),
                ),
                SizedBox(width: MinqTokens.spacing(4)),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: MinqTokens.titleMedium.copyWith(
                        color: MinqTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: MinqTokens.spacing(1)),
                      Text(
                        widget.subtitle!,
                        style: MinqTokens.bodySmall.copyWith(
                          color: MinqTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                widget.progressText,
                style: MinqTokens.bodyLarge.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: MinqTokens.spacing(6)),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).progress,
                        style: MinqTokens.bodySmall.copyWith(
                          color: MinqTokens.textSecondary,
                        ),
                      ),
                      Text(
                        '${(_progressAnimation.value * 100).round()}%',
                        style: MinqTokens.bodySmall.copyWith(
                          color: MinqTokens.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MinqTokens.spacing(2)),
                  ClipRRect(
                    borderRadius: MinqTokens.cornerSmall(),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: accent.withAlpha(25),
                      valueColor: AlwaysStoppedAnimation(accent),
                      minHeight: 8,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
