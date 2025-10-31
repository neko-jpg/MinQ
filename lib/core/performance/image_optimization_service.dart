import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Service for optimizing images to improve app performance
class ImageOptimizationService {
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxImageWidth = 1920;
  static const int _maxImageHeight = 1080;
  static const double _compressionQuality = 0.8;
  
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, DateTime> _cacheAccessTimes = {};
  int _currentCacheSize = 0;
  
  static final ImageOptimizationService _instance = ImageOptimizationService._internal();
  factory ImageOptimizationService() => _instance;
  ImageOptimizationService._internal();
  
  /// Optimize image from file path
  Future<Uint8List?> optimizeImageFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      
      final bytes = await file.readAsBytes();
      return await optimizeImageBytes(bytes);
    } catch (e) {
      debugPrint('Error optimizing image from file: $e');
      return null;
    }
  }
  
  /// Optimize image from bytes
  Future<Uint8List?> optimizeImageBytes(Uint8List bytes) async {
    try {
      // Generate cache key
      final cacheKey = _generateCacheKey(bytes);
      
      // Check memory cache first
      if (_memoryCache.containsKey(cacheKey)) {
        _updateCacheAccess(cacheKey);
        return _memoryCache[cacheKey];
      }
      
      // Check disk cache
      final cachedBytes = await _getCachedImage(cacheKey);
      if (cachedBytes != null) {
        _addToMemoryCache(cacheKey, cachedBytes);
        return cachedBytes;
      }
      
      // Decode image
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      // Calculate new dimensions
      final newSize = _calculateOptimalSize(image.width, image.height);
      
      // Resize if needed
      ui.Image resizedImage = image;
      if (newSize.width != image.width || newSize.height != image.height) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(0, 0, newSize.width.toDouble(), newSize.height.toDouble()),
          Paint()..filterQuality = FilterQuality.high,
        );
        
        final picture = recorder.endRecording();
        resizedImage = await picture.toImage(newSize.width.toInt(), newSize.height.toInt());
        picture.dispose();
      }
      
      // Convert to bytes with compression
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData == null) return null;
      
      final optimizedBytes = byteData.buffer.asUint8List();
      
      // Cache the optimized image
      await _cacheImage(cacheKey, optimizedBytes);
      _addToMemoryCache(cacheKey, optimizedBytes);
      
      // Cleanup
      image.dispose();
      if (resizedImage != image) {
        resizedImage.dispose();
      }
      
      return optimizedBytes;
    } catch (e) {
      debugPrint('Error optimizing image bytes: $e');
      return null;
    }
  }
  
  /// Get optimized image widget
  Widget getOptimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return FutureBuilder<Uint8List?>(
      future: _loadAndOptimizeNetworkImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _buildPlaceholder(width, height);
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return errorWidget ?? _buildErrorWidget(width, height);
        }
        
        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
        );
      },
    );
  }
  
  /// Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
    _cacheAccessTimes.clear();
    _currentCacheSize = 0;
  }
  
  /// Clear disk cache
  Future<void> clearDiskCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing disk cache: $e');
    }
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCacheSize': _currentCacheSize,
      'memoryCacheCount': _memoryCache.length,
      'maxCacheSize': _maxCacheSize,
      'cacheUtilization': _currentCacheSize / _maxCacheSize,
    };
  }
  
  // Private methods
  
  String _generateCacheKey(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  Size _calculateOptimalSize(int originalWidth, int originalHeight) {
    if (originalWidth <= _maxImageWidth && originalHeight <= _maxImageHeight) {
      return Size(originalWidth.toDouble(), originalHeight.toDouble());
    }
    
    final aspectRatio = originalWidth / originalHeight;
    
    int newWidth, newHeight;
    if (aspectRatio > 1) {
      // Landscape
      newWidth = _maxImageWidth;
      newHeight = (_maxImageWidth / aspectRatio).round();
    } else {
      // Portrait
      newHeight = _maxImageHeight;
      newWidth = (_maxImageHeight * aspectRatio).round();
    }
    
    return Size(newWidth.toDouble(), newHeight.toDouble());
  }
  
  Future<Uint8List?> _loadAndOptimizeNetworkImage(String url) async {
    try {
      // For demo purposes, we'll simulate network loading
      // In a real app, you'd use http package or similar
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Generate a cache key for the URL
      final cacheKey = _generateCacheKey(utf8.encode(url));
      
      // Check caches
      if (_memoryCache.containsKey(cacheKey)) {
        _updateCacheAccess(cacheKey);
        return _memoryCache[cacheKey];
      }
      
      final cachedBytes = await _getCachedImage(cacheKey);
      if (cachedBytes != null) {
        _addToMemoryCache(cacheKey, cachedBytes);
        return cachedBytes;
      }
      
      // For demo, return null (would load from network in real implementation)
      return null;
    } catch (e) {
      debugPrint('Error loading network image: $e');
      return null;
    }
  }
  
  void _addToMemoryCache(String key, Uint8List bytes) {
    // Remove old entries if cache is full
    while (_currentCacheSize + bytes.length > _maxCacheSize && _memoryCache.isNotEmpty) {
      _evictLeastRecentlyUsed();
    }
    
    _memoryCache[key] = bytes;
    _cacheAccessTimes[key] = DateTime.now();
    _currentCacheSize += bytes.length;
  }
  
  void _updateCacheAccess(String key) {
    _cacheAccessTimes[key] = DateTime.now();
  }
  
  void _evictLeastRecentlyUsed() {
    if (_cacheAccessTimes.isEmpty) return;
    
    String oldestKey = _cacheAccessTimes.keys.first;
    DateTime oldestTime = _cacheAccessTimes[oldestKey]!;
    
    for (final entry in _cacheAccessTimes.entries) {
      if (entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }
    
    final bytes = _memoryCache.remove(oldestKey);
    _cacheAccessTimes.remove(oldestKey);
    if (bytes != null) {
      _currentCacheSize -= bytes.length;
    }
  }
  
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/image_cache');
  }
  
  Future<Uint8List?> _getCachedImage(String key) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$key.cache');
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error reading cached image: $e');
    }
    return null;
  }
  
  Future<void> _cacheImage(String key, Uint8List bytes) async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      
      final file = File('${cacheDir.path}/$key.cache');
      await file.writeAsBytes(bytes);
    } catch (e) {
      debugPrint('Error caching image: $e');
    }
  }
  
  Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  
  Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.error_outline,
        color: Colors.grey[600],
      ),
    );
  }
}