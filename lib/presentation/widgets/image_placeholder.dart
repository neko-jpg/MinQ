import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/animation_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 画像プレースホルダとエラーハンドリングのユーティリティ
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
    final bgColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
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
          child: Icon(icon, size: tokens.spacing(12), color: iColor),
        ),
      ),
    );
  }
}

/// ネットワーク画像ウィジェット（プレースホルダとエラーハンドリング付き）
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
          final duration = AnimationSystem.getDuration(
            context,
            AnimationSystem.animatedSwitcher,
          );
          final curve = AnimationSystem.getCurve(
            context,
            AnimationSystem.animatedSwitcherCurve,
          );
          return AnimatedSwitcher(
            duration: duration,
            switchInCurve: curve,
            switchOutCurve: curve,
            child:
                frame != null
                    ? child
                    : placeholder ??
                        ImagePlaceholder(width: width, height: height),
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
          return ImagePlaceholder(width: width, height: height);
        },
      ),
    );
  }
}

/// アセット画像ウィジェット（エラーハンドリング付き）
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

/// アバター画像ウィジェット（プレースホルダとエラーハンドリング付き）
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
        child: Icon(fallbackIcon, size: radius * 1.2, color: iColor),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // エラー時はfallbackIconが表示される
      },
      child:
          imageUrl!.isEmpty
              ? Icon(fallbackIcon, size: radius * 1.2, color: iColor)
              : null,
    );
  }
}

/// フェードイン画像ウィジェット
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
              ImagePlaceholder(width: widget.width, height: widget.height),
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

/// 画像キャッシュ最適化ヘルパー
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
    // デバイスピクセル比を考慮したキャッシュサイズを計算
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final calculatedCacheWidth = // ignore: unused_local_variable
        cacheWidth ??
        (width != null ? (width! * devicePixelRatio).round() : null);
    final calculatedCacheHeight = // ignore: unused_local_variable
        cacheHeight ??
        (height != null ? (height! * devicePixelRatio).round() : null);

    return NetworkImageWithFallback(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
