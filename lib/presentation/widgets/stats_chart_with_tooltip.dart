import 'package:flutter/material.dart';

/// ツールチップ付き統計チャート
class StatsChartWithTooltip extends StatefulWidget {
  final List<ChartData> data;
  final String Function(ChartData) tooltipBuilder;

  const StatsChartWithTooltip({
    super.key,
    required this.data,
    required this.tooltipBuilder,
  });

  @override
  State<StatsChartWithTooltip> createState() => _StatsChartWithTooltipState();
}

class _StatsChartWithTooltipState extends State<StatsChartWithTooltip> {
  int? _hoveredIndex;
  Offset? _tooltipPosition;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            _handleTap(details.localPosition);
          },
          child: CustomPaint(
            painter: ChartPainter(
              data: widget.data,
              hoveredIndex: _hoveredIndex,
            ),
            size: Size.infinite,
          ),
        ),
        if (_hoveredIndex != null && _tooltipPosition != null)
          Positioned(
            left: _tooltipPosition!.dx,
            top: _tooltipPosition!.dy,
            child: _buildTooltip(),
          ),
      ],
    );
  }

  void _handleTap(Offset position) {
    // タップ位置からデータポイントを特定
    // 簡易実装
    setState(() {
      _hoveredIndex = 0; // TODO: 実際の計算
      _tooltipPosition = position;
    });
  }

  Widget _buildTooltip() {
    final data = widget.data[_hoveredIndex!];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.tooltipBuilder(data),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// チャートデータ
class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});
}

/// チャートペインター
class ChartPainter extends CustomPainter {
  final List<ChartData> data;
  final int? hoveredIndex;

  ChartPainter({required this.data, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: チャート描画実装
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex;
  }
}
