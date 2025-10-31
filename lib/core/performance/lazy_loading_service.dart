import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Service for implementing lazy loading of images and content
class LazyLoadingService {
  static const double _defaultPreloadDistance = 200.0;
  static const int _maxConcurrentLoads = 3;
  static const Duration _loadTimeout = Duration(seconds: 10);
  
  final Map<String, LazyLoadItem> _loadingItems = {};
  final Map<String, Uint8List> _loadedContent = {};
  final Set<String> _currentlyLoading = {};
  final List<LazyLoadRequest> _loadQueue = [];
  
  int _concurrentLoads = 0;
  Timer? _queueProcessor;
  
  static final LazyLoadingService _instance = LazyLoadingService._internal();
  factory LazyLoadingService() => _instance;
  LazyLoadingService._internal() {
    _startQueueProcessor();
  }
  
  /// Register item for lazy loading
  void registerItem(LazyLoadItem item) {
    _loadingItems[item.id] = item;
  }
  
  /// Unregister item
  void unregisterItem(String itemId) {
    _loadingItems.remove(itemId);
    _loadedContent.remove(itemId);
    _currentlyLoading.remove(itemId);
  }
  
  /// Check if item should be loaded based on viewport
  bool shouldLoadItem(String itemId, ScrollController scrollController) {
    final item = _loadingItems[itemId];
    if (item == null) return false;
    
    // Check if already loaded
    if (_loadedContent.containsKey(itemId)) return false;
    
    // Check if currently loading
    if (_currentlyLoading.contains(itemId)) return false;
    
    // Calculate if item is within preload distance
    final scrollOffset = scrollController.offset;
    final viewportHeight = scrollController.position.viewportDimension;
    
    final itemTop = item.position.dy;
    final itemBottom = itemTop + item.size.height;
    
    final preloadTop = scrollOffset - _defaultPreloadDistance;
    final preloadBottom = scrollOffset + viewportHeight + _defaultPreloadDistance;
    
    return itemBottom >= preloadTop && itemTop <= preloadBottom;
  }
  
  /// Load item content
  Future<Uint8List?> loadItem(String itemId, {LazyLoadPriority priority = LazyLoadPriority.normal}) async {
    // Check if already loaded
    if (_loadedContent.containsKey(itemId)) {
      return _loadedContent[itemId];
    }
    
    // Check if currently loading
    if (_currentlyLoading.contains(itemId)) {
      return await _waitForLoad(itemId);
    }
    
    final item = _loadingItems[itemId];
    if (item == null) return null;
    
    // Add to queue
    final request = LazyLoadRequest(
      itemId: itemId,
      item: item,
      priority: priority,
      requestTime: DateTime.now(),
    );
    
    _addToQueue(request);
    return await _waitForLoad(itemId);
  }
  
  /// Preload items in viewport
  Future<void> preloadViewportItems(ScrollController scrollController) async {
    final itemsToLoad = <String>[];
    
    for (final entry in _loadingItems.entries) {
      if (shouldLoadItem(entry.key, scrollController)) {
        itemsToLoad.add(entry.key);
      }
    }
    
    // Load items with low priority
    for (final itemId in itemsToLoad) {
      loadItem(itemId, priority: LazyLoadPriority.low);
    }
  }
  
  /// Get loaded content
  Uint8List? getLoadedContent(String itemId) {
    return _loadedContent[itemId];
  }
  
  /// Clear loaded content to free memory
  void clearLoadedContent({List<String>? itemIds}) {
    if (itemIds != null) {
      for (final itemId in itemIds) {
        _loadedContent.remove(itemId);
      }
    } else {
      _loadedContent.clear();
    }
  }
  
  /// Get loading statistics
  LazyLoadingStats getStats() {
    return LazyLoadingStats(
      registeredItems: _loadingItems.length,
      loadedItems: _loadedContent.length,
      currentlyLoading: _currentlyLoading.length,
      queuedItems: _loadQueue.length,
      memoryUsage: _calculateMemoryUsage(),
    );
  }
  
  /// Optimize memory usage
  void optimizeMemory() {
    // Remove least recently used items if memory usage is high
    final memoryUsage = _calculateMemoryUsage();
    const maxMemoryUsage = 50 * 1024 * 1024; // 50MB
    
    if (memoryUsage > maxMemoryUsage) {
      _evictLeastRecentlyUsed();
    }
  }
  
  // Private methods
  
  void _startQueueProcessor() {
    _queueProcessor = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _processQueue();
    });
  }
  
  void _addToQueue(LazyLoadRequest request) {
    // Remove existing request for same item
    _loadQueue.removeWhere((r) => r.itemId == request.itemId);
    
    // Add new request
    _loadQueue.add(request);
    
    // Sort by priority
    _loadQueue.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }
  
  void _processQueue() {
    if (_concurrentLoads >= _maxConcurrentLoads || _loadQueue.isEmpty) {
      return;
    }
    
    final request = _loadQueue.removeAt(0);
    _executeLoad(request);
  }
  
  Future<void> _executeLoad(LazyLoadRequest request) async {
    if (_currentlyLoading.contains(request.itemId)) return;
    
    _currentlyLoading.add(request.itemId);
    _concurrentLoads++;
    
    try {
      final content = await _loadContent(request.item).timeout(_loadTimeout);
      
      if (content != null) {
        _loadedContent[request.itemId] = content;
      }
    } catch (e) {
      debugPrint('Failed to load item ${request.itemId}: $e');
    } finally {
      _currentlyLoading.remove(request.itemId);
      _concurrentLoads--;
    }
  }
  
  Future<Uint8List?> _loadContent(LazyLoadItem item) async {
    switch (item.type) {
      case LazyLoadType.image:
        return await _loadImage(item);
      case LazyLoadType.video:
        return await _loadVideo(item);
      case LazyLoadType.data:
        return await _loadData(item);
    }
  }
  
  Future<Uint8List?> _loadImage(LazyLoadItem item) async {
    try {
      // Simulate image loading (in real implementation, use http or file loading)
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Return placeholder image data
      return Uint8List.fromList(List.generate(1024, (i) => i % 256));
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }
  
  Future<Uint8List?> _loadVideo(LazyLoadItem item) async {
    try {
      // Simulate video thumbnail loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return placeholder video data
      return Uint8List.fromList(List.generate(2048, (i) => i % 256));
    } catch (e) {
      debugPrint('Error loading video: $e');
      return null;
    }
  }
  
  Future<Uint8List?> _loadData(LazyLoadItem item) async {
    try {
      // Simulate data loading
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Return placeholder data
      return Uint8List.fromList(List.generate(512, (i) => i % 256));
    } catch (e) {
      debugPrint('Error loading data: $e');
      return null;
    }
  }
  
  Future<Uint8List?> _waitForLoad(String itemId) async {
    const maxWaitTime = Duration(seconds: 15);
    final startTime = DateTime.now();
    
    while (_currentlyLoading.contains(itemId)) {
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        break;
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return _loadedContent[itemId];
  }
  
  int _calculateMemoryUsage() {
    int totalSize = 0;
    for (final content in _loadedContent.values) {
      totalSize += content.length;
    }
    return totalSize;
  }
  
  void _evictLeastRecentlyUsed() {
    // Simple LRU eviction - remove half of the loaded content
    final itemsToRemove = _loadedContent.keys.take(_loadedContent.length ~/ 2).toList();
    
    for (final itemId in itemsToRemove) {
      _loadedContent.remove(itemId);
    }
    
    debugPrint('Evicted ${itemsToRemove.length} items from lazy loading cache');
  }
  
  void dispose() {
    _queueProcessor?.cancel();
    _loadingItems.clear();
    _loadedContent.clear();
    _currentlyLoading.clear();
    _loadQueue.clear();
  }
}

// Data classes

class LazyLoadItem {
  final String id;
  final LazyLoadType type;
  final String source; // URL, file path, or data identifier
  final Offset position;
  final Size size;
  final Map<String, dynamic> metadata;
  
  const LazyLoadItem({
    required this.id,
    required this.type,
    required this.source,
    required this.position,
    required this.size,
    this.metadata = const {},
  });
}

class LazyLoadRequest {
  final String itemId;
  final LazyLoadItem item;
  final LazyLoadPriority priority;
  final DateTime requestTime;
  
  const LazyLoadRequest({
    required this.itemId,
    required this.item,
    required this.priority,
    required this.requestTime,
  });
}

class LazyLoadingStats {
  final int registeredItems;
  final int loadedItems;
  final int currentlyLoading;
  final int queuedItems;
  final int memoryUsage;
  
  const LazyLoadingStats({
    required this.registeredItems,
    required this.loadedItems,
    required this.currentlyLoading,
    required this.queuedItems,
    required this.memoryUsage,
  });
}

enum LazyLoadType { image, video, data }

enum LazyLoadPriority { low, normal, high, critical }

// Widget for lazy loading images
class LazyLoadImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final LazyLoadPriority priority;
  
  const LazyLoadImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.priority = LazyLoadPriority.normal,
  });
  
  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  final _lazyLoadingService = LazyLoadingService();
  Uint8List? _imageData;
  bool _isLoading = false;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildErrorWidget();
    }
    
    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }
    
    return widget.placeholder ?? _buildPlaceholder();
  }
  
  Future<void> _loadImage() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final imageData = await _lazyLoadingService.loadItem(
        widget.imageUrl,
        priority: widget.priority,
      );
      
      if (mounted) {
        setState(() {
          _imageData = imageData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }
  
  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Icon(Icons.image, color: Colors.grey[600]),
      ),
    );
  }
  
  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Icon(
        Icons.error_outline,
        color: Colors.grey[600],
      ),
    );
  }
}

// Widget for lazy loading content in lists
class LazyLoadListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const LazyLoadListView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });
  
  @override
  State<LazyLoadListView> createState() => _LazyLoadListViewState();
}

class _LazyLoadListViewState extends State<LazyLoadListView> {
  late ScrollController _scrollController;
  final _lazyLoadingService = LazyLoadingService();
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      children: widget.children,
    );
  }
  
  void _onScroll() {
    // Preload items in viewport
    _lazyLoadingService.preloadViewportItems(_scrollController);
  }
}