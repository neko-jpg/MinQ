import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 画像最適化マネージャー
class ImageOptimizer {
  static final ImageOptimizer _instance = ImageOptimizer._internal();
  factory ImageOptimizer() => _instance;
  ImageOptimizer._internal();

  final Map<String, Uint8List> _optimizedCache = {};
  final Map<String, ui.Image> _decodedCache = {};

  /// 画像を最適化
  Future<Uint8List> optimizeImage(
    Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
    ImageFormat format = ImageFormat.webp,
  }) async {
    final cacheKey = _generateCacheKey(imageData, maxWidth, maxHeight, quality, format);
    
    if (_optimizedCache.containsKey(cacheKey)) {
      return _optimizedCache[cacheKey]!;
    }

    try {
      final optimized = await _performOptimization(
        imageData,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
        format: format,
      );
      
      _optimizedCache[cacheKey] = optimized;
      return optimized;
    } catch (e) {
      if (kDebugMode) {
        print('Image optimization failed: $e');
      }
      return imageData; // フォールバック
    }
  }

  /// 画像最適化を実行
  Future<Uint8List> _performOptimization(
    Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
    ImageFormat format = ImageFormat.webp,
  }) async {
    // 画像をデコード
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // リサイズが必要かチェック
    int targetWidth = image.width;
    int targetHeight = image.height;

    if (maxWidth != null && targetWidth > maxWidth) {
      final ratio = maxWidth / targetWidth;
      targetWidth = maxWidth;
      targetHeight = (targetHeight * ratio).round();
    }

    if (maxHeight != null && targetHeight > maxHeight) {
      final ratio = maxHeight / targetHeight;
      targetHeight = maxHeight;
      targetWidth = (targetWidth * ratio).round();
    }

    // リサイズが必要な場合
    ui.Image resizedImage = image;
    if (targetWidth != image.width || targetHeight != image.height) {
      resizedImage = await _resizeImage(image, targetWidth, targetHeight);
    }

    // エンコード
    final byteData = await resizedImage.toByteData(
      format: _getImageByteFormat(format),
    );

    if (byteData == null) {
      throw Exception('Failed to encode image');
    }

    return byteData.buffer.asUint8List();
  }

  /// 画像をリサイズ
  Future<ui.Image> _resizeImage(ui.Image image, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }

  /// キャッシュキーを生成
  String _generateCacheKey(
    Uint8List imageData,
    int? maxWidth,
    int? maxHeight,
    int quality,
    ImageFormat format,
  ) {
    final hash = imageData.fold<int>(0, (prev, byte) => prev + byte) % 1000000;
    return '${hash}_${maxWidth}_${maxHeight}_${quality}_${format.name}';
  }

  /// 画像フォーマットを変換
  ui.ImageByteFormat _getImageByteFormat(ImageFormat format) {
    switch (format) {
      case ImageFormat.png:
        return ui.ImageByteFormat.png;
      case ImageFormat.jpeg:
        return ui.ImageByteFormat.rawRgba;
      case ImageFormat.webp:
        return ui.ImageByteFormat.rawRgba; // WebPは直接サポートされていない
    }
  }

  /// キャッシュをクリア
  void clearCache() {
    _optimizedCache.clear();
    _decodedCache.clear();
  }

  /// キャッシュサイズを取得
  int getCacheSize() {
    return _optimizedCache.values.fold<int>(
      0,
      (sum, data) => sum + data.length,
    );
  }
}

/// 画像フォーマット
enum ImageFormat {
  png,
  jpeg,
  webp,
}

/// 最適化された画像ウィジェット
class OptimizedImage extends StatefulWidget {
  const OptimizedImage({
    super.key,
    required this.imageProvider,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.maxWidth,
    this.maxHeight,
    this.quality = 85,
    this.format = ImageFormat.webp,
  });

  final ImageProvider imageProvider;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? maxWidth;
  final int? maxHeight;
  final int quality;
  final ImageFormat format;

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  ImageProvider? _optimizedProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _optimizeImage();
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider) {
      _optimizeImage();
    }
  }

  Future<void> _optimizeImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 画像データを取得
      final imageData = await _getImageData(widget.imageProvider);
      
      // 最適化
      final optimized = await ImageOptimizer().optimizeImage(
        imageData,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        quality: widget.quality,
        format: widget.format,
      );

      // 最適化された画像プロバイダーを作成
      _optimizedProvider = MemoryImage(optimized);
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Image optimization error: $e');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<Uint8List> _getImageData(ImageProvider provider) async {
    if (provider is NetworkImage) {
      // ネットワーク画像の場合（実装は簡略化）
      throw UnimplementedError('Network image optimization not implemented');
    } else if (provider is AssetImage) {
      // アセット画像の場合
      final bundle = rootBundle;
      final data = await bundle.load(provider.assetName);
      return data.buffer.asUint8List();
    } else if (provider is MemoryImage) {
      // メモリ画像の場合
      return provider.bytes;
    } else {
      throw UnsupportedError('Unsupported image provider: ${provider.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? 
        const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return widget.errorWidget ?? 
        const Icon(Icons.error, color: Colors.red);
    }

    return Image(
      image: _optimizedProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}

/// 画像プリローダー
class ImagePreloader {
  static final ImagePreloader _instance = ImagePreloader._internal();
  factory ImagePreloader() => _instance;
  ImagePreloader._internal();

  final Set<String> _preloadedImages = {};

  /// 重要な画像をプリロード
  Future<void> preloadCriticalImages(BuildContext context) async {
    final criticalImages = [
      'assets/images/logo.png',
      'assets/images/onboarding_1.png',
      'assets/images/onboarding_2.png',
      'assets/images/onboarding_3.png',
    ];

    for (final imagePath in criticalImages) {
      if (_preloadedImages.contains(imagePath)) continue;

      try {
        await precacheImage(AssetImage(imagePath), context);
        _preloadedImages.add(imagePath);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to preload image: $imagePath');
        }
      }
    }
  }

  /// アイコンをプリロード
  Future<void> preloadIcons(BuildContext context) async {
    final iconPaths = [
      'assets/icons/quest.png',
      'assets/icons/stats.png',
      'assets/icons/profile.png',
      'assets/icons/settings.png',
    ];

    for (final iconPath in iconPaths) {
      if (_preloadedImages.contains(iconPath)) continue;

      try {
        await precacheImage(AssetImage(iconPath), context);
        _preloadedImages.add(iconPath);
      } catch (e) {
        // アイコンの読み込み失敗は無視
      }
    }
  }

  /// プリロード済みかチェック
  bool isPreloaded(String imagePath) {
    return _preloadedImages.contains(imagePath);
  }

  /// キャッシュをクリア
  void clearCache() {
    _preloadedImages.clear();
  }
}

/// 画像キャッシュマネージャー
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  /// 画像キャッシュを最適化
  void optimizeImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    // キャッシュサイズを制限（100MB）
    imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    
    // キャッシュ数を制限（1000枚）
    imageCache.maximumSize = 1000;
  }

  /// 低メモリ時のクリーンアップ
  void handleLowMemory() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    // キャッシュサイズを半分に削減
    final currentSize = imageCache.currentSizeBytes;
    if (currentSize > 50 * 1024 * 1024) { // 50MB以上の場合
      imageCache.clear();
      
      if (kDebugMode) {
        print('Image cache cleared due to low memory');
      }
    }
  }

  /// キャッシュ統計を取得
  Map<String, dynamic> getCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    return {
      'currentSize': imageCache.currentSize,
      'currentSizeBytes': imageCache.currentSizeBytes,
      'maximumSize': imageCache.maximumSize,
      'maximumSizeBytes': imageCache.maximumSizeBytes,
    };
  }
}