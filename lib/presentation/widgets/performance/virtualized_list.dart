import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// High-performance virtualized list widget for handling large datasets
class VirtualizedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemHeight;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? separator;
  final int? initialIndex;
  final VoidCallback? onEndReached;
  final double endReachedThreshold;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final bool enablePrefetch;
  final int prefetchCount;

  const VirtualizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemHeight,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.separator,
    this.initialIndex,
    this.onEndReached,
    this.endReachedThreshold = 200.0,
    this.loadingWidget,
    this.emptyWidget,
    this.enablePrefetch = true,
    this.prefetchCount = 5,
  });

  @override
  State<VirtualizedList<T>> createState() => _VirtualizedListState<T>();
}

class _VirtualizedListState<T> extends State<VirtualizedList<T>> {
  late ScrollController _scrollController;
  final Map<int, double> _itemHeights = {};
  final Map<int, Widget> _cachedWidgets = {};
  final Set<int> _visibleIndices = {};

  double _estimatedItemHeight = 60.0;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);

    if (widget.itemHeight != null) {
      _estimatedItemHeight = widget.itemHeight!;
    }

    // Jump to initial index if specified
    if (widget.initialIndex != null && widget.initialIndex! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToIndex(widget.initialIndex!);
      });
    }
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
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? _buildEmptyWidget();
    }

    return CustomScrollView(
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      slivers: [
        if (widget.padding != null)
          SliverPadding(padding: widget.padding!, sliver: _buildSliverList())
        else
          _buildSliverList(),

        if (_isLoadingMore && widget.loadingWidget != null)
          SliverToBoxAdapter(child: widget.loadingWidget!),
      ],
    );
  }

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= widget.items.length) return null;

          return _buildListItem(context, index);
        },
        childCount: widget.items.length,
        findChildIndexCallback: _findChildIndex,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    // Check cache first
    if (_cachedWidgets.containsKey(index)) {
      return _cachedWidgets[index]!;
    }

    final item = widget.items[index];
    Widget itemWidget = widget.itemBuilder(context, item, index);

    // Wrap with height measurement
    if (widget.itemHeight == null) {
      itemWidget = _HeightMeasureWidget(
        onHeightMeasured: (height) {
          _itemHeights[index] = height;
          _updateEstimatedHeight();
        },
        child: itemWidget,
      );
    }

    // Add separator if specified
    if (widget.separator != null && index < widget.items.length - 1) {
      itemWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [itemWidget, widget.separator!],
      );
    }

    // Cache the widget if within visible range
    if (_visibleIndices.contains(index)) {
      _cachedWidgets[index] = itemWidget;

      // Limit cache size
      if (_cachedWidgets.length > 50) {
        _evictOldCachedWidgets();
      }
    }

    return itemWidget;
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No items to display',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    _updateVisibleIndices();
    _checkEndReached();

    if (widget.enablePrefetch) {
      _prefetchItems();
    }
  }

  void _updateVisibleIndices() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    try {
      RenderAbstractViewport.of(renderBox);
    } catch (e) {
      // Viewport not available in test environment
      return;
    }

    final scrollOffset = _scrollController.offset;
    final viewportHeight = renderBox.size.height;

    final startIndex = _getIndexAtOffset(scrollOffset);
    final endIndex = _getIndexAtOffset(scrollOffset + viewportHeight);

    _visibleIndices.clear();
    for (int i = startIndex; i <= endIndex && i < widget.items.length; i++) {
      _visibleIndices.add(i);
    }
  }

  int _getIndexAtOffset(double offset) {
    if (widget.itemHeight != null) {
      return (offset / widget.itemHeight!).floor().clamp(
        0,
        widget.items.length - 1,
      );
    }

    // Estimate based on measured heights
    double currentOffset = 0;
    for (int i = 0; i < widget.items.length; i++) {
      final itemHeight = _itemHeights[i] ?? _estimatedItemHeight;
      if (currentOffset + itemHeight > offset) {
        return i;
      }
      currentOffset += itemHeight;
    }

    return widget.items.length - 1;
  }

  void _checkEndReached() {
    if (widget.onEndReached == null || _isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (maxScroll - currentScroll <= widget.endReachedThreshold) {
      _isLoadingMore = true;
      widget.onEndReached!();

      // Reset loading state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  void _prefetchItems() {
    final lastVisibleIndex = _visibleIndices.isEmpty ? 0 : _visibleIndices.last;

    for (
      int i = lastVisibleIndex + 1;
      i <= lastVisibleIndex + widget.prefetchCount && i < widget.items.length;
      i++
    ) {
      if (!_cachedWidgets.containsKey(i)) {
        // Prefetch by building the widget
        final item = widget.items[i];
        final widget_ = widget.itemBuilder(context, item, i);
        _cachedWidgets[i] = widget_;
      }
    }
  }

  void _evictOldCachedWidgets() {
    final sortedIndices = _cachedWidgets.keys.toList()..sort();
    final toRemove = sortedIndices.take(10).toList();

    for (final index in toRemove) {
      if (!_visibleIndices.contains(index)) {
        _cachedWidgets.remove(index);
      }
    }
  }

  void _updateEstimatedHeight() {
    if (_itemHeights.isNotEmpty) {
      final totalHeight = _itemHeights.values.reduce((a, b) => a + b);
      _estimatedItemHeight = totalHeight / _itemHeights.length;
    }
  }

  void _jumpToIndex(int index) {
    if (index < 0 || index >= widget.items.length) return;

    double offset = 0;
    if (widget.itemHeight != null) {
      offset = index * widget.itemHeight!;
    } else {
      // Estimate offset based on measured heights
      for (int i = 0; i < index; i++) {
        offset += _itemHeights[i] ?? _estimatedItemHeight;
      }
    }

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  int? _findChildIndex(Key key) {
    if (key is ValueKey<int>) {
      return key.value;
    }
    return null;
  }
}

/// Widget that measures its height and reports it back
class _HeightMeasureWidget extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onHeightMeasured;

  const _HeightMeasureWidget({
    required this.onHeightMeasured,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _HeightMeasureRenderObject(onHeightMeasured);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _HeightMeasureRenderObject renderObject,
  ) {
    renderObject.onHeightMeasured = onHeightMeasured;
  }
}

class _HeightMeasureRenderObject extends RenderProxyBox {
  ValueChanged<double> onHeightMeasured;
  double? _lastHeight;

  _HeightMeasureRenderObject(this.onHeightMeasured);

  @override
  void performLayout() {
    super.performLayout();

    if (size.height != _lastHeight) {
      _lastHeight = size.height;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onHeightMeasured(size.height);
      });
    }
  }
}

/// Optimized list view for quest items
class QuestVirtualizedList extends StatelessWidget {
  final List<dynamic> quests;
  final Widget Function(BuildContext context, dynamic quest, int index)
  itemBuilder;
  final VoidCallback? onLoadMore;
  final bool isLoading;

  const QuestVirtualizedList({
    super.key,
    required this.quests,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && quests.isEmpty) {
      return _buildLoadingWidget();
    }

    return VirtualizedList(
      items: quests,
      itemBuilder: itemBuilder,
      itemHeight: 80.0, // Estimated quest card height
      onEndReached: onLoadMore,
      loadingWidget: isLoading ? _buildLoadingWidget() : null,
      emptyWidget: _buildEmptyWidget(),
      enablePrefetch: true,
      prefetchCount: 10,
    );
  }

  Widget _buildLoadingWidget() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first quest to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
