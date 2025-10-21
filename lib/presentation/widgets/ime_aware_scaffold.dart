import 'package:flutter/material.dart';

/// IME対応Scaffold - キーボード表示時のオーバーラップを防ぐ
class IMEAwareScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const IMEAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar as PreferredSizeWidget?,
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
    );
  }
}

/// IME対応フォーム - キーボード表示時に自動スクロール
class IMEAwareForm extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const IMEAwareForm({
    super.key,
    this.formKey,
    required this.children,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  State<IMEAwareForm> createState() => _IMEAwareFormState();
}

class _IMEAwareFormState extends State<IMEAwareForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;

    return Form(
      key: widget.formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding:
                widget.padding?.add(
                  EdgeInsets.only(bottom: viewInsets.bottom),
                ) ??
                EdgeInsets.only(bottom: viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: widget.crossAxisAlignment,
                mainAxisAlignment: widget.mainAxisAlignment,
                children: widget.children,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// IME対応テキストフィールド - フォーカス時に自動スクロール
class IMEAwareTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final ScrollController? scrollController;

  const IMEAwareTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.scrollController,
  });

  @override
  State<IMEAwareTextField> createState() => _IMEAwareTextFieldState();
}

class _IMEAwareTextFieldState extends State<IMEAwareTextField> {
  late FocusNode _focusNode;
  final GlobalKey _fieldKey = GlobalKey();

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
    if (_focusNode.hasFocus) {
      _scrollToField();
    }
  }

  void _scrollToField() {
    if (widget.scrollController == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _fieldKey.currentContext;
      if (context == null) return;

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final position = renderBox.localToGlobal(Offset.zero);
      final fieldHeight = renderBox.size.height;
      final screenHeight = MediaQuery.of(context).size.height;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final visibleHeight = screenHeight - keyboardHeight;

      // フィールドが見える位置までスクロール
      if (position.dy + fieldHeight > visibleHeight) {
        final scrollOffset =
            widget.scrollController!.offset +
            (position.dy + fieldHeight - visibleHeight) +
            50; // 余白

        widget.scrollController!.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _fieldKey,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          enabled: widget.enabled,
        ),
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        enabled: widget.enabled,
      ),
    );
  }
}

/// キーボード高さ検出ウィジェット
class KeyboardHeightDetector extends StatelessWidget {
  final Widget Function(BuildContext context, double keyboardHeight) builder;

  const KeyboardHeightDetector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return builder(context, keyboardHeight);
  }
}

/// キーボード表示状態検出
class KeyboardVisibilityDetector extends StatelessWidget {
  final Widget Function(BuildContext context, bool isKeyboardVisible) builder;

  const KeyboardVisibilityDetector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return builder(context, isKeyboardVisible);
  }
}

/// IMEヘルパー関数
class IMEHelper {
  const IMEHelper._();

  /// キーボードが表示されているか
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// キーボードの高さを取得
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// キーボードを閉じる
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// 次のフィールドにフォーカス
  static void focusNextField(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// 前のフィールドにフォーカス
  static void focusPreviousField(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// 安全な余白を計算（キーボード考慮）
  static EdgeInsets getSafeInsets(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      left: mediaQuery.padding.left,
      top: mediaQuery.padding.top,
      right: mediaQuery.padding.right,
      bottom: mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom,
    );
  }
}

/// IME対応ボトムシート
class IMEAwareBottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isScrollControlled;

  const IMEAwareBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.isScrollControlled = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder:
          (context) => IMEAwareBottomSheet(
            padding: padding,
            isScrollControlled: isScrollControlled,
            child: child,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding:
          padding?.add(EdgeInsets.only(bottom: keyboardHeight)) ??
          EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(child: child),
    );
  }
}
