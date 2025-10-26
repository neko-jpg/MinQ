import 'package:flutter/material.dart';

/// A builder that provides different layouts for portrait and landscape orientations
class OrientationLayoutBuilder extends StatelessWidget {
  const OrientationLayoutBuilder({
    super.key,
    required this.portrait,
    this.landscape,
  });

  final Widget portrait;
  final Widget? landscape;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}

/// A widget that adapts its layout based on screen orientation and size
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.child,
    this.landscapeChild,
    this.tabletChild,
    this.desktopChild,
    this.enableOrientationAdaptation = true,
    this.enableSizeAdaptation = true,
  });

  final Widget child;
  final Widget? landscapeChild;
  final Widget? tabletChild;
  final Widget? desktopChild;
  final bool enableOrientationAdaptation;
  final bool enableSizeAdaptation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final width = constraints.maxWidth;
        
        // Size-based adaptation
        if (enableSizeAdaptation) {
          if (width >= 1200 && desktopChild != null) {
            return desktopChild!;
          }
          if (width >= 600 && tabletChild != null) {
            return tabletChild!;
          }
        }
        
        // Orientation-based adaptation
        if (enableOrientationAdaptation &&
            orientation == Orientation.landscape &&
            landscapeChild != null) {
          return landscapeChild!;
        }
        
        return child;
      },
    );
  }
}

/// A grid that adapts its column count based on screen size
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns;
        
        if (width >= 1200) {
          columns = desktopColumns;
        } else if (width >= 600) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }
        
        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// A widget that provides different layouts for different screen sizes
class BreakpointBuilder extends StatelessWidget {
  const BreakpointBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (width >= 1200 && largeDesktop != null) {
          return largeDesktop!;
        }
        if (width >= 900 && desktop != null) {
          return desktop!;
        }
        if (width >= 600 && tablet != null) {
          return tablet!;
        }
        
        return mobile;
      },
    );
  }
}