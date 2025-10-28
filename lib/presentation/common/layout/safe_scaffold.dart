import 'package:flutter/material.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';

/// A scaffold that handles safe areas, responsive layout, and prevents overflow issues
class SafeScaffold extends StatelessWidget {
  const SafeScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.enableResponsiveLayout = true,
    this.maxContentWidth,
    this.padding,
    this.avoidSystemUI = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool enableResponsiveLayout;
  final double? maxContentWidth;
  final EdgeInsets? padding;
  final bool avoidSystemUI;

  @override
  Widget build(BuildContext context) {
    Widget? safeBody = body;

    if (safeBody != null) {
      // Wrap body in SafeArea to avoid system UI conflicts
      if (avoidSystemUI) {
        safeBody = SafeArea(
          top: !extendBodyBehindAppBar,
          bottom: !extendBody,
          child: safeBody,
        );
      }

      // Apply responsive layout if enabled
      if (enableResponsiveLayout) {
        safeBody = ResponsiveLayout.constrainedContainer(
          maxWidth: maxContentWidth ?? ResponsiveLayout.maxContentWidth,
          padding: padding ?? context.responsivePadding,
          child: safeBody,
        );
      } else if (padding != null) {
        safeBody = Padding(
          padding: padding!,
          child: safeBody,
        );
      }
    }

    return Scaffold(
      appBar: appBar,
      body: safeBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

/// A scrollable view that prevents overflow and handles responsive layout
class SafeScrollView extends StatelessWidget {
  const SafeScrollView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.enableResponsiveLayout = true,
    this.maxContentWidth,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  final List<Widget> children;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool enableResponsiveLayout;
  final double? maxContentWidth;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );

    if (enableResponsiveLayout) {
      content = ResponsiveLayout.constrainedContainer(
        maxWidth: maxContentWidth ?? ResponsiveLayout.maxContentWidth,
        child: content,
      );
    }

    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      padding: padding ?? context.responsivePadding,
      keyboardDismissBehavior: keyboardDismissBehavior,
      child: content,
    );
  }
}

/// A flexible widget that prevents overflow in Flex layouts
class SafeFlex extends StatelessWidget {
  const SafeFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.clipBehavior = Clip.none,
    this.preventOverflow = true,
  });

  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final Clip clipBehavior;
  final bool preventOverflow;

  @override
  Widget build(BuildContext context) {
    List<Widget> safeChildren = children;

    if (preventOverflow) {
      // Wrap children in Flexible to prevent overflow
      safeChildren = children.map((child) {
        if (child is Flexible || child is Expanded) {
          return child;
        }
        return Flexible(child: child);
      }).toList();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Flex(
          direction: direction,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
          children: safeChildren,
        );
      },
    );
  }
}

/// A row that prevents overflow
class SafeRow extends SafeFlex {
  const SafeRow({
    super.key,
    required super.children,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
  }) : super(direction: Axis.horizontal);
}

/// A column that prevents overflow
class SafeColumn extends SafeFlex {
  const SafeColumn({
    super.key,
    required super.children,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
  }) : super(direction: Axis.vertical);
}

/// A widget that prevents text overflow by wrapping in Flexible
class SafeText extends StatelessWidget {
  const SafeText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap = true,
    this.overflow = TextOverflow.ellipsis,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.flex = 1,
  });

  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Text(
        data,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaleFactor != null ? TextScaler.linear(textScaleFactor!) : null,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      ),
    );
  }
}

/// A container that prevents overflow by using intrinsic dimensions
class SafeContainer extends StatelessWidget {
  const SafeContainer({
    super.key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.none,
    this.preventOverflow = true,
  });

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Widget? child;
  final Clip clipBehavior;
  final bool preventOverflow;

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );

    if (preventOverflow && child != null) {
      container = LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
            ),
            child: container,
          );
        },
      );
    }

    return container;
  }
}

/// A widget that handles keyboard insets properly
class KeyboardAwareWidget extends StatelessWidget {
  const KeyboardAwareWidget({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: (padding ?? EdgeInsets.zero).copyWith(
        bottom: (padding?.bottom ?? 0) + keyboardHeight,
      ),
      child: child,
    );
  }
}

/// A widget that handles overflow by wrapping content in scrollable views
class OverflowHandler extends StatelessWidget {
  const OverflowHandler({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.enableScrolling = true,
    this.padding,
  });

  final Widget child;
  final Axis scrollDirection;
  final bool enableScrolling;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (!enableScrolling) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: scrollDirection,
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: scrollDirection == Axis.horizontal ? 0 : constraints.maxWidth,
              minHeight: scrollDirection == Axis.vertical ? 0 : constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// A widget that prevents RenderFlex overflow by using Wrap instead of Row/Column
class FlexOverflowHandler extends StatelessWidget {
  const FlexOverflowHandler({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.fallbackToWrap = true,
  });

  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;
  final bool fallbackToWrap;

  @override
  Widget build(BuildContext context) {
    if (!fallbackToWrap) {
      return Flex(
        direction: direction,
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use Wrap to prevent overflow
        return Wrap(
          direction: direction,
          alignment: _wrapAlignmentFromMainAxis(mainAxisAlignment),
          crossAxisAlignment: crossAxisAlignment,
          spacing: spacing,
          runSpacing: runSpacing,
          children: children,
        );
      },
    );
  }

  WrapAlignment _wrapAlignmentFromMainAxis(MainAxisAlignment mainAxis) {
    switch (mainAxis) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }
}

/// A widget that ensures proper system UI handling
class SystemUIHandler extends StatelessWidget {
  const SystemUIHandler({
    super.key,
    required this.child,
    this.handleKeyboard = true,
    this.handleStatusBar = true,
    this.handleNavigationBar = true,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final bool handleKeyboard;
  final bool handleStatusBar;
  final bool handleNavigationBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (handleKeyboard || handleStatusBar || handleNavigationBar) {
      result = SafeArea(
        top: handleStatusBar,
        bottom: handleNavigationBar,
        child: result,
      );
    }

    if (handleKeyboard && resizeToAvoidBottomInset) {
      result = KeyboardAwareWidget(child: result);
    }

    return result;
  }
}

/// A layout builder that provides responsive breakpoints
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 900,
    this.desktopBreakpoint = 1200,
  });

  final Widget Function(BuildContext context, ScreenType screenType, BoxConstraints constraints) builder;
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = _getScreenType(constraints.maxWidth);
        return builder(context, screenType, constraints);
      },
    );
  }

  ScreenType _getScreenType(double width) {
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    if (width < desktopBreakpoint) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }
}

/// A widget that handles orientation changes gracefully
class OrientationHandler extends StatelessWidget {
  const OrientationHandler({
    super.key,
    required this.child,
    this.landscapeChild,
    this.adaptPadding = true,
    this.adaptSpacing = true,
  });

  final Widget child;
  final Widget? landscapeChild;
  final bool adaptPadding;
  final bool adaptSpacing;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscapeChild != null) {
          return landscapeChild!;
        }

        Widget result = child;

        if (adaptPadding || adaptSpacing) {
          final mediaQuery = MediaQuery.of(context);
          final isLandscape = orientation == Orientation.landscape;

          // Adjust padding for landscape mode
          if (adaptPadding && isLandscape) {
            result = Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQuery.size.width * 0.1,
              ),
              child: result,
            );
          }
        }

        return result;
      },
    );
  }
}