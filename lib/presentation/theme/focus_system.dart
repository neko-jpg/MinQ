import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

enum FocusAccent { neutral, success, error }

/// フォーカスシステム - キーボード操作対応
class FocusSystem {
  const FocusSystem._();

  // ========================================
  // フォーカスリング設定
  // ========================================

  /// フォーカスリングの幅
  static const double focusRingWidth = 2.0;

  /// フォーカスリングの太い幅（強調時）
  static const double focusRingWidthBold = 3.0;

  /// フォーカスリングのオフセット
  static const double focusRingOffset = 2.0;

  /// フォーカスリングの角丸
  static const double focusRingRadius = 4.0;

  // ========================================
  // フォーカスカラー
  // ========================================

  /// 状態に応じたフォーカスカラーを解決
  static Color resolveFocusColor(
    BuildContext context, {
    FocusAccent accent = FocusAccent.neutral,
    Color? override,
  }) {
    if (override != null) {
      return override;
    }

    final tokens = context.tokens;
    Color baseColor;
    switch (accent) {
      case FocusAccent.success:
        baseColor = tokens.accentSuccess;
        break;
      case FocusAccent.error:
        baseColor = tokens.accentError;
        break;
      case FocusAccent.neutral:
      default:
        baseColor = tokens.brandPrimary;
        break;
    }

    if (tokens.isHighContrastMode(context)) {
      return tokens.getAccessibleTextColor(context);
    }

    return baseColor;
  }

  // ========================================
  // フォーカステーマ
  // ========================================

  /// ライトモードのフォーカステーマ
  static Color lightFocusColor() {
    return Colors.blue.withOpacity(0.3);
  }

  /// ダークモードのフォーカステーマ
  static Color darkFocusColor() {
    return Colors.blue.withOpacity(0.3);
  }

  // ========================================
  // フォーカスデコレーション
  // ========================================

  /// フォーカスリングのBoxDecoration
  static BoxDecoration focusDecoration({
    required Color focusColor,
    double width = focusRingWidth,
    double radius = focusRingRadius,
    bool highContrast = false,
  }) {
    return BoxDecoration(
      border: Border.all(color: focusColor, width: width),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: highContrast ? focusColor : focusColor.withOpacity(0.3),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// BuildContextからフォーカスデコレーションを生成
  static BoxDecoration focusDecorationForContext(
    BuildContext context, {
    FocusAccent accent = FocusAccent.neutral,
    Color? override,
    double width = focusRingWidth,
    double radius = focusRingRadius,
  }) {
    final tokens = context.tokens;
    final focusColor = resolveFocusColor(
      context,
      accent: accent,
      override: override,
    );

    return focusDecoration(
      focusColor: focusColor,
      width: width,
      radius: radius,
      highContrast: tokens.isHighContrastMode(context),
    );
  }

  /// フォーカス時のアウトライン
  static OutlineInputBorder focusedBorder({
    required Color focusColor,
    double width = focusRingWidth,
    double radius = 8.0,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: focusColor, width: width),
    );
  }
}

/// フォーカス対応ウィジェット
class FocusableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onFocusChange;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color? focusColor;

  const FocusableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onFocusChange,
    this.autofocus = false,
    this.focusNode,
    this.focusColor,
  });

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocusChange?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final focusColor = FocusSystem.resolveFocusColor(
      context,
      override: widget.focusColor,
    );

    return Semantics(
      focused: _isFocused,
      button: widget.onTap != null,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              widget.onTap?.call();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            widget.onTap?.call();
          },
          child: Container(
            decoration:
                _isFocused
                    ? FocusSystem.focusDecoration(
                      focusColor: focusColor,
                      highContrast: tokens.isHighContrastMode(context),
                    )
                    : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// キーボードナビゲーション対応リスト
class KeyboardNavigableList extends StatefulWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;

  const KeyboardNavigableList({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.padding,
  });

  @override
  State<KeyboardNavigableList> createState() => _KeyboardNavigableListState();
}

class _KeyboardNavigableListState extends State<KeyboardNavigableList> {
  int _focusedIndex = 0;
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
  }

  @override
  void didUpdateWidget(KeyboardNavigableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _initializeFocusNodes();
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _initializeFocusNodes() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    _focusNodes.clear();
    for (int i = 0; i < widget.children.length; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  void _moveFocus(int direction) {
    final newIndex = (_focusedIndex + direction).clamp(
      0,
      widget.children.length - 1,
    );
    if (newIndex != _focusedIndex) {
      setState(() {
        _focusedIndex = newIndex;
      });
      _focusNodes[newIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (widget.scrollDirection == Axis.vertical) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _moveFocus(1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _moveFocus(-1);
              return KeyEventResult.handled;
            }
          } else {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _moveFocus(1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _moveFocus(-1);
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: ListView.builder(
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          return Focus(
            focusNode: _focusNodes[index],
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _focusedIndex = index;
                });
              }
            },
            child: widget.children[index],
          );
        },
      ),
    );
  }
}

/// フォーカス対応ボタン
class FocusableButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;

  const FocusableButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      child: child,
    );
  }
}

/// フォーカストラバーサル順序
class FocusTraversalOrderWidget extends StatelessWidget {
  final double order;
  final Widget child;

  const FocusTraversalOrderWidget({
    super.key,
    required this.order,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(order: NumericFocusOrder(order), child: child);
  }
}

/// キーボードショートカットヘルパー
class KeyboardShortcuts {
  const KeyboardShortcuts._();

  /// Ctrl/Cmd + S: 保存
  static bool isSaveShortcut(RawKeyEvent event) {
    return event.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyS;
  }

  /// Ctrl/Cmd + N: 新規作成
  static bool isNewShortcut(RawKeyEvent event) {
    return event.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyN;
  }

  /// Ctrl/Cmd + F: 検索
  static bool isSearchShortcut(RawKeyEvent event) {
    return event.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyF;
  }

  /// Esc: キャンセル/閉じる
  static bool isEscapeKey(RawKeyEvent event) {
    return event.logicalKey == LogicalKeyboardKey.escape;
  }

  /// Enter: 確定
  static bool isEnterKey(RawKeyEvent event) {
    return event.logicalKey == LogicalKeyboardKey.enter;
  }

  /// Space: 選択/トグル
  static bool isSpaceKey(RawKeyEvent event) {
    return event.logicalKey == LogicalKeyboardKey.space;
  }

  /// Tab: 次のフォーカス
  static bool isTabKey(RawKeyEvent event) {
    return event.logicalKey == LogicalKeyboardKey.tab;
  }

  /// Shift + Tab: 前のフォーカス
  static bool isShiftTabKey(RawKeyEvent event) {
    return event.isShiftPressed && event.logicalKey == LogicalKeyboardKey.tab;
  }
}
