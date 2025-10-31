import 'package:flutter/material.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';

/// Helper class for color blindness support and color accessibility
class ColorBlindnessHelper {
  /// Transform a color based on the color blindness mode
  static Color transformColor(Color color, ColorBlindnessMode mode) {
    switch (mode) {
      case ColorBlindnessMode.none:
        return color;
      case ColorBlindnessMode.protanopia:
        return _simulateProtanopia(color);
      case ColorBlindnessMode.deuteranopia:
        return _simulateDeuteranopia(color);
      case ColorBlindnessMode.tritanopia:
        return _simulateTritanopia(color);
      case ColorBlindnessMode.monochromacy:
        return _simulateMonochromacy(color);
    }
  }

  /// Simulate protanopia (red-blind)
  static Color _simulateProtanopia(Color color) {
    final r = (color.r * 255.0).round() / 255.0;
    final g = (color.g * 255.0).round() / 255.0;
    final b = (color.b * 255.0).round() / 255.0;

    // Protanopia transformation matrix
    final newR = 0.567 * r + 0.433 * g + 0.0 * b;
    final newG = 0.558 * r + 0.442 * g + 0.0 * b;
    final newB = 0.0 * r + 0.242 * g + 0.758 * b;

    return Color.fromARGB(
      (color.a * 255.0).round(),
      (newR * 255).round().clamp(0, 255),
      (newG * 255).round().clamp(0, 255),
      (newB * 255).round().clamp(0, 255),
    );
  }

  /// Simulate deuteranopia (green-blind)
  static Color _simulateDeuteranopia(Color color) {
    final r = (color.r * 255.0).round() / 255.0;
    final g = (color.g * 255.0).round() / 255.0;
    final b = (color.b * 255.0).round() / 255.0;

    // Deuteranopia transformation matrix
    final newR = 0.625 * r + 0.375 * g + 0.0 * b;
    final newG = 0.7 * r + 0.3 * g + 0.0 * b;
    final newB = 0.0 * r + 0.3 * g + 0.7 * b;

    return Color.fromARGB(
      (color.a * 255.0).round(),
      (newR * 255).round().clamp(0, 255),
      (newG * 255).round().clamp(0, 255),
      (newB * 255).round().clamp(0, 255),
    );
  }

  /// Simulate tritanopia (blue-blind)
  static Color _simulateTritanopia(Color color) {
    final r = (color.r * 255.0).round() / 255.0;
    final g = (color.g * 255.0).round() / 255.0;
    final b = (color.b * 255.0).round() / 255.0;

    // Tritanopia transformation matrix
    final newR = 0.95 * r + 0.05 * g + 0.0 * b;
    final newG = 0.0 * r + 0.433 * g + 0.567 * b;
    final newB = 0.0 * r + 0.475 * g + 0.525 * b;

    return Color.fromARGB(
      (color.a * 255.0).round(),
      (newR * 255).round().clamp(0, 255),
      (newG * 255).round().clamp(0, 255),
      (newB * 255).round().clamp(0, 255),
    );
  }

  /// Simulate monochromacy (complete color blindness)
  static Color _simulateMonochromacy(Color color) {
    // Convert to grayscale using luminance formula
    final luminance = 0.299 * (color.r * 255.0).round() + 0.587 * (color.g * 255.0).round() + 0.114 * (color.b * 255.0).round();
    final gray = luminance.round().clamp(0, 255);
    
    return Color.fromARGB((color.a * 255.0).round(), gray, gray, gray);
  }

  /// Get alternative visual indicators for color-coded information
  static Widget addColorAlternatives({
    required Widget child,
    required Color color,
    String? pattern,
    IconData? icon,
    String? label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        if (icon != null) ...[
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: color),
        ],
        if (pattern != null) ...[
          const SizedBox(width: 4),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              image: _getPattern(pattern),
            ),
          ),
        ],
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }

  /// Get pattern decoration for color alternatives
  static DecorationImage? _getPattern(String pattern) {
    switch (pattern) {
      case 'dots':
        return const DecorationImage(
          image: AssetImage('assets/patterns/dots.png'),
          repeat: ImageRepeat.repeat,
        );
      case 'stripes':
        return const DecorationImage(
          image: AssetImage('assets/patterns/stripes.png'),
          repeat: ImageRepeat.repeat,
        );
      case 'diagonal':
        return const DecorationImage(
          image: AssetImage('assets/patterns/diagonal.png'),
          repeat: ImageRepeat.repeat,
        );
      default:
        return null;
    }
  }

  /// Status color alternatives using icons and patterns
  static const Map<String, StatusIndicator> statusIndicators = {
    'success': StatusIndicator(
      icon: Icons.check_circle,
      pattern: 'dots',
      label: '✓',
    ),
    'warning': StatusIndicator(
      icon: Icons.warning,
      pattern: 'stripes',
      label: '⚠',
    ),
    'error': StatusIndicator(
      icon: Icons.error,
      pattern: 'diagonal',
      label: '✗',
    ),
    'info': StatusIndicator(
      icon: Icons.info,
      pattern: 'dots',
      label: 'ℹ',
    ),
  };

  /// Create accessible status indicator
  static Widget statusIndicator({
    required String status,
    required Color color,
    required String semanticLabel,
    double size = 16,
  }) {
    final indicator = statusIndicators[status];
    if (indicator == null) {
      return Icon(Icons.circle, color: color, size: size);
    }

    return Semantics(
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            indicator.icon,
            color: color,
            size: size,
          ),
          const SizedBox(width: 2),
          Text(
            indicator.label,
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Create accessible progress indicator with multiple visual cues
  static Widget accessibleProgress({
    required double value,
    required Color color,
    required String semanticLabel,
    double height = 8,
    bool showPercentage = true,
    bool showPattern = true,
  }) {
    return Semantics(
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          if (showPercentage) ...[
            const SizedBox(height: 4),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  /// Create accessible chart colors with patterns
  static List<ChartColorData> getAccessibleChartColors() {
    return [
      const ChartColorData(
        color: Color(0xFF4F46E5),
        pattern: 'solid',
        icon: Icons.circle,
        label: 'Series 1',
      ),
      const ChartColorData(
        color: Color(0xFF8B5CF6),
        pattern: 'dots',
        icon: Icons.square,
        label: 'Series 2',
      ),
      const ChartColorData(
        color: Color(0xFF14B8A6),
        pattern: 'stripes',
        icon: Icons.change_history,
        label: 'Series 3',
      ),
      const ChartColorData(
        color: Color(0xFF10B981),
        pattern: 'diagonal',
        icon: Icons.diamond,
        label: 'Series 4',
      ),
      const ChartColorData(
        color: Color(0xFFF59E0B),
        pattern: 'cross',
        icon: Icons.star,
        label: 'Series 5',
      ),
    ];
  }

  /// Check if two colors are distinguishable for color blind users
  static bool areColorsDistinguishable(
    Color color1,
    Color color2,
    ColorBlindnessMode mode,
  ) {
    final transformed1 = transformColor(color1, mode);
    final transformed2 = transformColor(color2, mode);
    
    // Calculate color difference using Delta E formula (simplified)
    final deltaR = ((transformed1.r * 255.0).round() - (transformed2.r * 255.0).round()).abs();
    final deltaG = ((transformed1.g * 255.0).round() - (transformed2.g * 255.0).round()).abs();
    final deltaB = ((transformed1.b * 255.0).round() - (transformed2.b * 255.0).round()).abs();
    
    final difference = (deltaR + deltaG + deltaB) / 3;
    
    // Threshold for distinguishability (adjust as needed)
    return difference > 30;
  }

  /// Get high contrast version of a color
  static Color getHighContrastColor(Color color, bool isDarkMode) {
    final luminance = color.computeLuminance();
    
    if (isDarkMode) {
      // In dark mode, make light colors lighter and dark colors darker
      return luminance > 0.5 
          ? Colors.white 
          : Colors.black;
    } else {
      // In light mode, make dark colors darker and light colors lighter
      return luminance > 0.5 
          ? Colors.black 
          : Colors.white;
    }
  }
}

/// Data class for status indicators
class StatusIndicator {
  const StatusIndicator({
    required this.icon,
    required this.pattern,
    required this.label,
  });

  final IconData icon;
  final String pattern;
  final String label;
}

/// Data class for chart colors with accessibility features
class ChartColorData {
  const ChartColorData({
    required this.color,
    required this.pattern,
    required this.icon,
    required this.label,
  });

  final Color color;
  final String pattern;
  final IconData icon;
  final String label;
}