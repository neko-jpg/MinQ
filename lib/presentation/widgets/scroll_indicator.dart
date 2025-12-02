import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/animation_system.dart';
import 'package:minq/presentation/theme/spacing_system.dart';

/// スクロール到達インジケータの種類
enum ScrollIndicatorType {
  /// EdgeGlow（Android標準）
  edgeGlow,

  /// Scrollbar（iOS/Desktop標準）
  scrollbar,

  /// カスタムインジケータ
  custom,

  /// インジケータなし
  none,
}

/// スクロール到達インジケータ設定
class ScrollIndicatorConfig {
  final ScrollIndicatorType type;
  final Color? glowColor;
  final bool showScrollbar;
  final bool interactive;
  final double thickness;
  final Radius radius;

  const ScrollIndicatorConfig({
    this.type = ScrollIndicatorType.scrollbar,
    this.glowColor,
    this.showScrollbar = true,
    this.interactive = true,
    this.thickness = 8.0,
    this.radius = const Radius.circular(4),
  });

  /// プラットフォームに応じたデフォルト設定
  factory ScrollIndicatorConfig.platform(BuildContext context) {
    final platform = Theme.of(context).platform;
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const ScrollIndicatorConfig(type: ScrollIndicatorType.edgeGlow);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const ScrollIndicatorConfig(
          type: ScrollIndicatorType.scrollbar,
          interactive: false,
        );
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ScrollIndicatorConfig(
          type: ScrollIndicatorType.scrollbar,
          interactive: true,
        );
    }
  }
}

/// スクロール到達インジケータウィジェット
class ScrollIndicatorWrapper extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final ScrollIndicatorConfig? config;

  const ScrollIndicatorWrapper({
    super.key,
    required this.child,
    this.controller,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? ScrollIndicatorConfig.platform(context);

    switch (effectiveConfig.type) {
      case ScrollIndicatorType.edgeGlow:
        return _buildEdgeGlow(context, effectiveConfig);
      case ScrollIndicatorType.scrollbar:
        return _buildScrollbar(context, effectiveConfig);
      case ScrollIndicatorType.custom:
        return _buildCustomIndicator(context, effectiveConfig);
      case ScrollIndicatorType.none:
        return child;
    }
  }

  Widget _buildEdgeGlow(BuildContext context, ScrollIndicatorConfig config) {
    final theme = Theme.of(context);
    final glowColor = config.glowColor ?? theme.colorScheme.primary;

    // ignore: unused_local_variable
    final unused = theme;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: true),
      child: GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: glowColor,
        child: child,
      ),
    );
  }

  Widget _buildScrollbar(BuildContext context, ScrollIndicatorConfig config) {
    if (controller != null) {
      return Scrollbar(
        controller: controller,
        thumbVisibility: config.showScrollbar,
        interactive: config.interactive,
        thickness: config.thickness,
        radius: config.radius,
        child: child,
      );
    }

    return Scrollbar(
      thumbVisibility: config.showScrollbar,
      interactive: config.interactive,
      thickness: config.thickness,
      radius: config.radius,
      child: child,
    );
  }

  Widget _buildCustomIndicator(
    BuildContext context,
    ScrollIndicatorConfig config,
  ) {
    return CustomScrollIndicator(controller: controller, child: child);
  }
}

/// カスタムスクロールインジケータ
class CustomScrollIndicator extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;

  const CustomScrollIndicator({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<CustomScrollIndicator> createState() => _CustomScrollIndicatorState();
}

class _CustomScrollIndicatorState extends State<CustomScrollIndicator> {
  late ScrollController _controller;
  bool _showTopIndicator = false;
  bool _showBottomIndicator = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_updateIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicators();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_updateIndicators);
    }
    super.dispose();
  }

  void _updateIndicators() {
    if (!_controller.hasClients) return;

    final position = _controller.position;
    final showTop = position.pixels > 0;
    final showBottom = position.pixels < position.maxScrollExtent;

    if (showTop != _showTopIndicator || showBottom != _showBottomIndicator) {
      setState(() {
        _showTopIndicator = showTop;
        _showBottomIndicator = showBottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // 上部インジケータ
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showTopIndicator ? 1.0 : 0.0,
            duration: AnimationSystem.fast,
            child: const _ScrollEdgeIndicator(isTop: true),
          ),
        ),
        // 下部インジケータ
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showBottomIndicator ? 1.0 : 0.0,
            duration: AnimationSystem.fast,
            child: const _ScrollEdgeIndicator(isTop: false),
          ),
        ),
      ],
    );
  }
}

/// スクロール端インジケータ
class _ScrollEdgeIndicator extends StatelessWidget {
  final bool isTop;

  const _ScrollEdgeIndicator({required this.isTop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.surface.withOpacity(0.0),
      theme.colorScheme.surface.withOpacity(0.8),
    ];

    return IgnorePointer(
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

/// スクロール位置インジケータ（ページネーション用）
class ScrollPositionIndicator extends StatefulWidget {
  final ScrollController controller;
  final int itemCount;
  final double itemExtent;
  final Axis scrollDirection;

  const ScrollPositionIndicator({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemExtent,
    this.scrollDirection = Axis.horizontal,
  });

  @override
  State<ScrollPositionIndicator> createState() =>
      _ScrollPositionIndicatorState();
}

class _ScrollPositionIndicatorState extends State<ScrollPositionIndicator> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateIndex);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateIndex);
    super.dispose();
  }

  void _updateIndex() {
    if (!widget.controller.hasClients) return;

    final offset = widget.controller.offset;
    final index = (offset / widget.itemExtent).round();

    if (index != _currentIndex && index >= 0 && index < widget.itemCount) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.itemCount, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: AnimationSystem.fast,
          curve: AnimationSystem.standard,
          width: isActive ? 24 : 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: SpacingSystem.xxs),
          decoration: BoxDecoration(
            color:
                isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// スクロール進捗インジケータ
class ScrollProgressIndicator extends StatefulWidget {
  final ScrollController controller;
  final Color? color;
  final double height;

  const ScrollProgressIndicator({
    super.key,
    required this.controller,
    this.color,
    this.height = 4,
  });

  @override
  State<ScrollProgressIndicator> createState() =>
      _ScrollProgressIndicatorState();
}

class _ScrollProgressIndicatorState extends State<ScrollProgressIndicator> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateProgress);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateProgress);
    super.dispose();
  }

  void _updateProgress() {
    if (!widget.controller.hasClients) return;

    final position = widget.controller.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    final progress =
        maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;

    if (progress != _progress) {
      setState(() {
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = widget.color ?? theme.colorScheme.primary;

    return Container(
      height: widget.height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: AnimationSystem.fast,
          width: MediaQuery.of(context).size.width * _progress,
          height: widget.height,
          color: indicatorColor,
        ),
      ),
    );
  }
}

/// スクロール可能領域の拡張
extension ScrollableExtension on Widget {
  /// EdgeGlowインジケータを追加
  Widget withEdgeGlow({Color? color}) {
    return Builder(
      builder: (context) {
        return ScrollIndicatorWrapper(
          config: ScrollIndicatorConfig(
            type: ScrollIndicatorType.edgeGlow,
            glowColor: color,
          ),
          child: this,
        );
      },
    );
  }

  /// Scrollbarを追加
  Widget withScrollbar({
    ScrollController? controller,
    bool interactive = true,
    double thickness = 8.0,
  }) {
    return ScrollIndicatorWrapper(
      controller: controller,
      config: ScrollIndicatorConfig(
        type: ScrollIndicatorType.scrollbar,
        interactive: interactive,
        thickness: thickness,
      ),
      child: this,
    );
  }

  /// カスタムインジケータを追加
  Widget withCustomIndicator({ScrollController? controller}) {
    return ScrollIndicatorWrapper(
      controller: controller,
      config: const ScrollIndicatorConfig(type: ScrollIndicatorType.custom),
      child: this,
    );
  }
}
