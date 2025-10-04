import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/animation_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 逕ｻ蜒上・繝ｬ繝ｼ繧ｹ繝帙Ν繝縺ｨ繧ｨ繝ｩ繝ｼ繝上Φ繝峨Μ繝ｳ繧ｰ縺ｮ繝ｦ繝ｼ繝・ぅ繝ｪ繝・ぅ
class ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.image_outlined,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final iColor = iconColor ?? theme.colorScheme.onSurfaceVariant;

    return Semantics(
      container: true,
      label: 'placeholder image',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: tokens.cornerMedium(),
        ),
        child: Center(
          child: Icon(
            icon,
            size: tokens.spacing(12),
            color: iColor,
          ),
        ),
      ),
    );
  }
}

/// 繝阪ャ繝医Ρ繝ｼ繧ｯ逕ｻ蜒上え繧｣繧ｸ繧ｧ繝・ヨ・医・繝ｬ繝ｼ繧ｹ繝帙Ν繝縺ｨ繧ｨ繝ｩ繝ｼ繝上Φ繝峨Μ繝ｳ繧ｰ莉倥″・・
class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: borderRadius ?? tokens.cornerMedium(),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          final duration =
              AnimationSystem.getDuration(context, AnimationSystem.animatedSwitcher);
          final curve =
              AnimationSystem.getCurve(context, AnimationSystem.animatedSwitcherCurve);
          return AnimatedSwitcher(
            duration: duration,
            switchInCurve: curve,
            switchOutCurve: curve,
            child: frame != null
                ? child
                : placeholder ??
                    ImagePlaceholder(
                      width: width,
                      height: height,
                    ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              ImagePlaceholder(
                width: width,
                height: height,
                icon: Icons.broken_image_outlined,
              );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return ImagePlaceholder(
            width: width,
            height: height,
          );
        },
      ),
    );
  }
}

/// 繧｢繧ｻ繝・ヨ逕ｻ蜒上え繧｣繧ｸ繧ｧ繝・ヨ・医お繝ｩ繝ｼ繝上Φ繝峨Μ繝ｳ繧ｰ莉倥″・・
class AssetImageWithFallback extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AssetImageWithFallback({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: borderRadius ?? tokens.cornerMedium(),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              ImagePlaceholder(
                width: width,
                height: height,
                icon: Icons.broken_image_outlined,
              );
        },
      ),
    );
  }
}

/// 繧｢繝舌ち繝ｼ逕ｻ蜒上え繧｣繧ｸ繧ｧ繝・ヨ・医・繝ｬ繝ｼ繧ｹ繝帙Ν繝縺ｨ繧ｨ繝ｩ繝ｼ繝上Φ繝峨Μ繝ｳ繧ｰ莉倥″・・
class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const AvatarImage({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final iColor = iconColor ?? theme.colorScheme.onPrimaryContainer;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Icon(
          fallbackIcon,
          size: radius * 1.2,
          color: iColor,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // 繧ｨ繝ｩ繝ｼ譎ゅ・fallbackIcon縺瑚｡ｨ遉ｺ縺輔ｌ繧・
      },
      child: imageUrl!.isEmpty
          ? Icon(
              fallbackIcon,
              size: radius * 1.2,
              color: iColor,
            )
          : null,
    );
  }
}

/// 繝輔ぉ繝ｼ繝峨う繝ｳ逕ｻ蜒上え繧｣繧ｸ繧ｧ繝・ヨ
class FadeInImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeDuration;

  const FadeInImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeDuration = AnimationSystem.fadeIn,
  });

  @override
  State<FadeInImage> createState() => _FadeInImageState();
}

class _FadeInImageState extends State<FadeInImage> {
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          ImagePlaceholder(
            width: widget.width,
            height: widget.height,
            icon: Icons.broken_image_outlined,
          );
    }

    return Stack(
      children: [
        if (!_isLoaded)
          widget.placeholder ??
              ImagePlaceholder(
                width: widget.width,
                height: widget.height,
              ),
        AnimatedOpacity(
          opacity: _isLoaded ? 1.0 : 0.0,
          duration: widget.fadeDuration,
          curve: AnimationSystem.fadeInCurve,
          child: Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _isLoaded = true);
                  }
                });
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _hasError = true);
                }
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

/// 逕ｻ蜒上く繝｣繝・す繝･譛驕ｩ蛹悶・繝ｫ繝代・
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    // 繝・ヰ繧､繧ｹ繝斐け繧ｻ繝ｫ豈斐ｒ閠・・縺励◆繧ｭ繝｣繝・す繝･繧ｵ繧､繧ｺ繧定ｨ育ｮ・
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final calculatedCacheWidth = cacheWidth ??
        (width != null ? (width! * devicePixelRatio).round() : null);
    final calculatedCacheHeight = cacheHeight ??
        (height != null ? (height! * devicePixelRatio).round() : null);

    return NetworkImageWithFallback(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
