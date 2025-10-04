import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// チE�Eルチップ付き統計チャーチE
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
    // タチE�E位置からチE�Eタポイントを特宁E
    // 簡易実裁E
    setState(() {
      _hoveredIndex = 0; // TODO: 実際の計箁E
      _tooltipPosition = position;
    });
  }

  Widget _buildTooltip() {
    final data = widget.data[_hoveredIndex!];
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing(2)),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: tokens.cornerSmall(),
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

/// チャート�Eインター
class ChartPainter extends CustomPainter {
  final List<ChartData> data;
  final int? hoveredIndex;

  ChartPainter({required this.data, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: チャート描画実裁E
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex;
  }
}
