import 'package:flutter/material.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';

/// Comprehensive layout fixes to prevent overflow and improve responsiveness
class LayoutFixes {
  /// Fixes common Row overflow issues by using SafeRow or Wrap
  static Widget fixRowOverflow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    bool useWrapFallback = true,
    double spacing = 8.0,
    double runSpacing = 4.0,
  }) {
    if (useWrapFallback) {
      return FlexOverflowHandler(
        direction: Axis.horizontal,
        mainAxisAlignment: mainAxisAlignment,
        spacing: spacing,
        runSpacing: runSpacing,
        children: children,
      );
    }

    return SafeRow(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Fixes common Column overflow issues by using SafeColumn or ScrollView
  static Widget fixColumnOverflow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool enableScrolling = true,
    EdgeInsets? padding,
  }) {
    if (enableScrolling) {
      return SafeScrollView(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        padding: padding,
        children: children,
      );
    }

    return SafeColumn(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Creates a responsive container that prevents overflow
  static Widget responsiveContainer({
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool centerContent = true,
  }) {
    return ResponsiveLayout.constrainedContainer(
      maxWidth: maxWidth ?? ResponsiveLayout.maxContentWidth,
      padding: padding,
      child: centerContent ? Center(child: child) : child,
    );
  }

  /// Fixes text overflow issues
  static Widget fixTextOverflow({
    required String text,
    TextStyle? style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign? textAlign,
    bool flexible = true,
  }) {
    Widget textWidget = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: true,
    );

    if (flexible) {
      return Flexible(child: textWidget);
    }

    return textWidget;
  }

  /// Creates a safe card layout that prevents overflow
  static Widget safeCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? color,
    List<BoxShadow>? boxShadow,
    Border? border,
    bool enableScrolling = false,
  }) {
    Widget content = child;

    if (enableScrolling) {
      content = SingleChildScrollView(child: content);
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      child: SafeContainer(
        padding: padding,
        child: content,
      ),
    );
  }

  /// Fixes ListView overflow and performance issues
  static Widget fixListView({
    required List<Widget> children,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
  }) {
    return ListView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Creates a responsive grid that adapts to screen size
  static Widget responsiveGrid({
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    double childAspectRatio = 1.0,
    EdgeInsets? padding,
    bool shrinkWrap = true,
  }) {
    return ResponsiveLayoutBuilder(
      builder: (context, screenType, constraints) {
        int columns;
        switch (screenType) {
          case ScreenType.mobile:
            columns = mobileColumns ?? 1;
            break;
          case ScreenType.tablet:
            columns = tabletColumns ?? 2;
            break;
          case ScreenType.desktop:
          case ScreenType.largeDesktop:
            columns = desktopColumns ?? 3;
            break;
        }

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: const NeverScrollableScrollPhysics(),
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

  /// Fixes button layout and ensures minimum touch targets
  static Widget fixButtonLayout({
    required Widget button,
    double minWidth = ResponsiveLayout.minTouchTarget,
    double minHeight = ResponsiveLayout.minTouchTarget,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: minHeight,
      ),
      child: button,
    );
  }

  /// Creates a safe form layout that handles keyboard and scrolling
  static Widget safeForm({
    required List<Widget> children,
    GlobalKey<FormState>? formKey,
    EdgeInsets? padding,
    bool handleKeyboard = true,
    bool enableScrolling = true,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    Widget content = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );

    if (enableScrolling) {
      content = SingleChildScrollView(
        padding: padding,
        child: content,
      );
    } else if (padding != null) {
      content = Padding(
        padding: padding,
        child: content,
      );
    }

    if (handleKeyboard) {
      content = KeyboardAwareWidget(child: content);
    }

    if (formKey != null) {
      content = Form(
        key: formKey,
        child: content,
      );
    }

    return content;
  }

  /// Fixes AppBar layout and ensures proper spacing
  static PreferredSizeWidget fixAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
    double elevation = 0,
    TextStyle? titleStyle,
    bool automaticallyImplyLeading = true,
  }) {
    // Ensure actions have proper touch targets
    List<Widget>? safeActions;
    if (actions != null) {
      safeActions = actions.map((action) {
        return ResponsiveLayout.ensureTouchTarget(child: action);
      }).toList();
    }

    return AppBar(
      title: Text(title, style: titleStyle),
      actions: safeActions,
      leading: leading != null
        ? ResponsiveLayout.ensureTouchTarget(child: leading)
        : null,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  /// Creates a responsive bottom navigation that adapts to screen size
  static Widget responsiveBottomNavigation({
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    Color? backgroundColor,
    BottomNavigationBarType? type,
  }) {
    return ResponsiveLayoutBuilder(
      builder: (context, screenType, constraints) {
        // Adjust font sizes based on screen type
        double selectedFontSize = screenType == ScreenType.mobile ? 12 : 14;
        double unselectedFontSize = screenType == ScreenType.mobile ? 10 : 12;
        double iconSize = screenType == ScreenType.mobile ? 24 : 28;

        return Container(
          height: ResponsiveLayout.minTouchTarget + 36,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BottomNavigationBar(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedItemColor: selectedItemColor,
            unselectedItemColor: unselectedItemColor,
            backgroundColor: backgroundColor,
            type: type ?? BottomNavigationBarType.fixed,
            selectedFontSize: selectedFontSize,
            unselectedFontSize: unselectedFontSize,
            iconSize: iconSize,
            elevation: 0,
          ),
        );
      },
    );
  }

  /// Fixes dialog layout and ensures proper constraints
  static Widget fixDialog({
    required Widget content,
    String? title,
    List<Widget>? actions,
    EdgeInsets? contentPadding,
    double? maxWidth,
    double? maxHeight,
  }) {
    Widget dialog = AlertDialog(
      title: title != null ? Text(title) : null,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 400,
          maxHeight: maxHeight ?? 600,
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      ),
      contentPadding: contentPadding,
      actions: actions?.map((action) {
        return ResponsiveLayout.ensureTouchTarget(child: action);
      }).toList(),
    );

    return dialog;
  }

  /// Creates a safe bottom sheet that handles keyboard and scrolling
  static Widget safeBottomSheet({
    required Widget content,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool handleKeyboard = true,
    EdgeInsets? padding,
    double? maxHeight,
  }) {
    Widget sheet = content;

    if (handleKeyboard) {
      sheet = KeyboardAwareWidget(child: sheet);
    }

    if (padding != null) {
      sheet = Padding(padding: padding, child: sheet);
    }

    if (maxHeight != null) {
      sheet = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: sheet,
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: sheet,
        );
      },
    );
  }
}