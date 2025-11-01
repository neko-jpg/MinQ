import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for keyboard navigation and focus management
class KeyboardNavigationHelper {
  /// Create a keyboard-navigable widget with proper focus handling
  static Widget keyboardNavigable({
    required Widget child,
    required FocusNode focusNode,
    VoidCallback? onActivate,
    Map<LogicalKeySet, VoidCallback>? shortcuts,
    bool autofocus = false,
    String? debugLabel,
  }) {
    Widget result = Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      debugLabel: debugLabel,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Handle Enter and Space as activation
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            onActivate?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );

    if (shortcuts != null && shortcuts.isNotEmpty) {
      final bindings = <ShortcutActivator, VoidCallback>{
        for (final entry in shortcuts.entries) entry.key: entry.value,
      };
      result = CallbackShortcuts(bindings: bindings, child: result);
    }

    return result;
  }

  /// Create a focus indicator that shows when an element is focused
  static Widget focusIndicator({
    required Widget child,
    required FocusNode focusNode,
    Color? focusColor,
    double borderWidth = 2.0,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final theme = Theme.of(context);
        final effectiveFocusColor = focusColor ?? theme.colorScheme.primary;

        return Container(
          decoration:
              focusNode.hasFocus
                  ? BoxDecoration(
                    border: Border.all(
                      color: effectiveFocusColor,
                      width: borderWidth,
                    ),
                    borderRadius: borderRadius ?? BorderRadius.circular(4),
                  )
                  : null,
          child: child,
        );
      },
    );
  }

  /// Create a skip link for keyboard users to skip navigation
  static Widget skipLink({
    required String text,
    required VoidCallback onPressed,
    required FocusNode focusNode,
  }) {
    return Positioned(
      top: -100, // Hidden by default
      left: 0,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, _) {
          return Transform.translate(
            offset: focusNode.hasFocus ? const Offset(0, 100) : Offset.zero,
            child: ElevatedButton(
              focusNode: focusNode,
              onPressed: onPressed,
              child: Text(text),
            ),
          );
        },
      ),
    );
  }

  /// Create a focus scope for managing focus within a specific area
  static Widget focusScope({
    required Widget child,
    FocusScopeNode? node,
    bool autofocus = false,
    ValueChanged<bool>? onFocusChange,
  }) {
    return FocusScope(
      node: node,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      child: child,
    );
  }

  /// Create a traversal group for controlling tab order
  static Widget traversalGroup({required Widget child}) {
    return FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: child);
  }

  /// Create an ordered focus traversal for specific tab order
  static Widget orderedTraversal({
    required Widget child,
    required List<FocusNode> order,
  }) {
    return FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: child);
  }

  /// Handle directional navigation (arrow keys)
  static KeyEventResult handleDirectionalNavigation(
    KeyEvent event,
    BuildContext context, {
    VoidCallback? onUp,
    VoidCallback? onDown,
    VoidCallback? onLeft,
    VoidCallback? onRight,
  }) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        onUp?.call();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        onDown?.call();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        onLeft?.call();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        onRight?.call();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  /// Create a keyboard shortcut handler
  static Widget shortcutHandler({
    required Widget child,
    required Map<LogicalKeySet, VoidCallback> shortcuts,
  }) {
    // Simplified shortcut handler - full implementation would require custom intents
    return child;
  }

  /// Common keyboard shortcuts
  static final Map<String, LogicalKeySet> commonShortcuts = {
    'save': LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS),
    'copy': LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC),
    'paste': LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV),
    'undo': LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ),
    'redo': LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY),
    'selectAll': LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyA,
    ),
    'find': LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF),
    'refresh': LogicalKeySet(LogicalKeyboardKey.f5),
    'escape': LogicalKeySet(LogicalKeyboardKey.escape),
    'enter': LogicalKeySet(LogicalKeyboardKey.enter),
    'space': LogicalKeySet(LogicalKeyboardKey.space),
    'tab': LogicalKeySet(LogicalKeyboardKey.tab),
    'shiftTab': LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab),
  };

  /// Focus management utilities
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Check if keyboard navigation is available
  static bool isKeyboardNavigationAvailable(BuildContext context) {
    // Check if the device supports keyboard input
    // This is a simplified check - in a real implementation you'd check for physical keyboard
    return true;
  }

  /// Create a roving tabindex pattern for lists
  static Widget rovingTabIndex({
    required Widget child,
    required List<FocusNode> focusNodes,
    required int selectedIndex,
    required ValueChanged<int> onSelectionChanged,
  }) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowDown:
              final nextIndex = (selectedIndex + 1) % focusNodes.length;
              onSelectionChanged(nextIndex);
              focusNodes[nextIndex].requestFocus();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowUp:
              final prevIndex =
                  selectedIndex == 0
                      ? focusNodes.length - 1
                      : selectedIndex - 1;
              onSelectionChanged(prevIndex);
              focusNodes[prevIndex].requestFocus();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.home:
              onSelectionChanged(0);
              focusNodes[0].requestFocus();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.end:
              final lastIndex = focusNodes.length - 1;
              onSelectionChanged(lastIndex);
              focusNodes[lastIndex].requestFocus();
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// Custom focus traversal policy for better keyboard navigation
class AccessibilityTraversalPolicy extends FocusTraversalPolicy {
  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    // Sort by reading order (top to bottom, left to right)
    final List<FocusNode> sorted = descendants.toList();
    sorted.sort((a, b) {
      final aRect = a.rect;
      final bRect = b.rect;

      // First sort by vertical position
      final verticalDiff = aRect.top.compareTo(bRect.top);
      if (verticalDiff != 0) return verticalDiff;

      // Then by horizontal position
      return aRect.left.compareTo(bRect.left);
    });

    return sorted;
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    switch (direction) {
      case TraversalDirection.up:
      case TraversalDirection.down:
      case TraversalDirection.left:
      case TraversalDirection.right:
        return true;
    }
  }

  @override
  FocusNode? findFirstFocusInDirection(
    FocusNode currentNode,
    TraversalDirection direction,
  ) {
    return null; // Use default behavior
  }
}
