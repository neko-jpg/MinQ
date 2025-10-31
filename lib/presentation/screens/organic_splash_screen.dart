import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Brand-first splash experience with a calmer pace and minimum dwell time.
class OrganicSplashScreen extends ConsumerStatefulWidget {
  const OrganicSplashScreen({super.key});

  @override
  ConsumerState<OrganicSplashScreen> createState() =>
      _OrganicSplashScreenState();
}

class _OrganicSplashScreenState extends ConsumerState<OrganicSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Decoration> _background;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _haloOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<double> _taglineOpacity;

  bool _pointerPressed = false;

  static const Duration _totalDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();

    _background = DecorationTween(
      begin: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B1F3B), Color(0xFF101527)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      end: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF22D3EE)],
          begin: Alignment(0.2, -1.0),
          end: Alignment.bottomRight,
        ),
      ),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: Curves.easeInOutCubic),
      ),
    );

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
    );

    _haloOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.decelerate),
    );

    _wordmarkOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeIn),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Semantics(
        label: 'MinQを起動しています',
        hint: '長押しでスキップできます',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (_) {
            _pointerPressed = true;
            HapticFeedback.mediumImpact();
            _controller.forward(from: 1.0);
          },
          onLongPressEnd: (_) {
            _pointerPressed = false;
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return DecoratedBox(
                decoration: _background.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildHalo(context),
                    _buildLogo(context),
                    _buildWordmark(context),
                    _buildFooter(context, tokens),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHalo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final opacity = _haloOpacity.value;

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colorScheme.primary.withOpacity(0.45 * opacity),
                colorScheme.primary.withOpacity(0.0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Transform.scale(
      scale: _logoScale.value,
      child: Opacity(
        opacity: _logoOpacity.value,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.45),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.check_circle,
              size: 54,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordmark(BuildContext context) {
    final tokens = context.tokens;

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.55,
      child: FadeTransition(
        opacity: _wordmarkOpacity,
        child: Column(
          children: [
            Text(
              'MinQ',
              style: tokens.typography.h3.copyWith(
                color: tokens.surfaceForeground,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _taglineOpacity,
              child: Text(
                '習慣をクエストに。毎日を冒険に。',
                style: tokens.typography.bodyMedium.copyWith(
                  color: tokens.surfaceForeground.withOpacity(0.84),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, MinqTheme tokens) {
    final mediaQuery = MediaQuery.of(context);
    final showIndicator = !_pointerPressed;

    return Positioned(
      bottom: mediaQuery.padding.bottom + 48,
      child: FadeTransition(
        opacity: _taglineOpacity,
        child: Column(
          children: [
            if (showIndicator)
              SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    tokens.primaryForeground,
                  ),
                  backgroundColor: Colors.white24,
                ),
              ),
            if (showIndicator) const SizedBox(height: 12),
            Text(
              '初期設定を準備中…',
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.surfaceForeground.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
