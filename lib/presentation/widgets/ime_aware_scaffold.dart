import 'package:flutter/material.dart';

/// IME蟇ｾ蠢彜caffold - 繧ｭ繝ｼ繝懊・繝芽｡ｨ遉ｺ譎ゅ・繧ｪ繝ｼ繝舌・繝ｩ繝・・繧帝亟縺・
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
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
    );
  }
}

/// IME蟇ｾ蠢懊ヵ繧ｩ繝ｼ繝 - 繧ｭ繝ｼ繝懊・繝芽｡ｨ遉ｺ譎ゅ↓閾ｪ蜍輔せ繧ｯ繝ｭ繝ｼ繝ｫ
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
            padding: widget.padding?.add(
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

/// IME蟇ｾ蠢懊ユ繧ｭ繧ｹ繝医ヵ繧｣繝ｼ繝ｫ繝・- 繝輔か繝ｼ繧ｫ繧ｹ譎ゅ↓閾ｪ蜍輔せ繧ｯ繝ｭ繝ｼ繝ｫ
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

      // 繝輔ぅ繝ｼ繝ｫ繝峨′隕九∴繧倶ｽ咲ｽｮ縺ｾ縺ｧ繧ｹ繧ｯ繝ｭ繝ｼ繝ｫ
      if (position.dy + fieldHeight > visibleHeight) {
        final scrollOffset = widget.scrollController!.offset +
            (position.dy + fieldHeight - visibleHeight) +
            50; // 菴咏區

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

/// 繧ｭ繝ｼ繝懊・繝蛾ｫ倥＆讀懷・繧ｦ繧｣繧ｸ繧ｧ繝・ヨ
class KeyboardHeightDetector extends StatelessWidget {
  final Widget Function(BuildContext context, double keyboardHeight) builder;

  const KeyboardHeightDetector({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return builder(context, keyboardHeight);
  }
}

/// 繧ｭ繝ｼ繝懊・繝芽｡ｨ遉ｺ迥ｶ諷区､懷・
class KeyboardVisibilityDetector extends StatelessWidget {
  final Widget Function(BuildContext context, bool isKeyboardVisible) builder;

  const KeyboardVisibilityDetector({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return builder(context, isKeyboardVisible);
  }
}

/// IME繝倥Ν繝代・髢｢謨ｰ
class IMEHelper {
  const IMEHelper._();

  /// 繧ｭ繝ｼ繝懊・繝峨′陦ｨ遉ｺ縺輔ｌ縺ｦ縺・ｋ縺・
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// 繧ｭ繝ｼ繝懊・繝峨・鬮倥＆繧貞叙蠕・
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// 繧ｭ繝ｼ繝懊・繝峨ｒ髢峨§繧・
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// 谺｡縺ｮ繝輔ぅ繝ｼ繝ｫ繝峨↓繝輔か繝ｼ繧ｫ繧ｹ
  static void focusNextField(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// 蜑阪・繝輔ぅ繝ｼ繝ｫ繝峨↓繝輔か繝ｼ繧ｫ繧ｹ
  static void focusPreviousField(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// 螳牙・縺ｪ菴咏區繧定ｨ育ｮ暦ｼ医く繝ｼ繝懊・繝芽・・・・
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

/// IME蟇ｾ蠢懊・繝医Β繧ｷ繝ｼ繝・
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
      builder: (context) => IMEAwareBottomSheet(
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      padding: padding?.add(
            EdgeInsets.only(bottom: keyboardHeight),
          ) ??
          EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
