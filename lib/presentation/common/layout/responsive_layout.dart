import 'package:flutter/material.dart';

/// Responsive layout utilities for handling different screen sizes and orientations
class ResponsiveLayout {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Minimum touch target size for accessibility (44pt)
  static const double minTouchTarget = 44.0;

  /// Maximum content width for readability
  static const double maxContentWidth = 640.0;

  /// Get screen type based on width
  static ScreenType getScreenType(double width) {
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    if (width < desktopBreakpoint) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenType.desktop:
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive column count for grids
  static int getResponsiveColumns(BuildContext context, {int maxColumns = 4}) {
    final width = MediaQuery.of(context).size.width;
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
      case ScreenType.largeDesktop:
        return maxColumns;
    }
  }

  /// Get responsive font scale
  static double getResponsiveFontScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenType = getScreenType(width);

    switch (screenType) {
      case ScreenType.mobile:
        return 1.0;
      case ScreenType.tablet:
        return 1.1;
      case ScreenType.desktop:
      case ScreenType.largeDesktop:
        return 1.2;
    }
  }

  /// Ensure minimum touch target size
  static Widget ensureTouchTarget({
    required Widget child,
    double minSize = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: child,
    );
  }

  /// Create responsive container with max width constraint
  static Widget constrainedContainer({
    required Widget child,
    double maxWidth = maxContentWidth,
    EdgeInsets? padding,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content = child;

        if (constraints.maxWidth > maxWidth) {
          content = Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          );
        }

        if (padding != null) {
          content = Padding(padding: padding, child: content);
        }

        return content;
      },
    );
  }
}

enum ScreenType { mobile, tablet, desktop, largeDesktop }

/// Extension for responsive utilities on BuildContext
extension ResponsiveContext on BuildContext {
  ScreenType get screenType =>
      ResponsiveLayout.getScreenType(MediaQuery.of(this).size.width);

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop =>
      screenType == ScreenType.desktop || screenType == ScreenType.largeDesktop;

  EdgeInsets get responsivePadding =>
      ResponsiveLayout.getResponsivePadding(this);

  int responsiveColumns({int maxColumns = 4}) =>
      ResponsiveLayout.getResponsiveColumns(this, maxColumns: maxColumns);

  double get responsiveFontScale =>
      ResponsiveLayout.getResponsiveFontScale(this);
}
