import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/spacing_system.dart';

/// フォームバリチE�EションシスチE�� - 統一されたバリチE�EションメチE��ージ
class FormValidation {
  const FormValidation._();

  // ========================================
  // バリチE�Eションルール
  // ========================================

  /// 忁E��フィールチE
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'こ�E頁E��'}は忁E��でぁE;
    }
    return null;
  }

  /// 最小文字数
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return '${fieldName ?? 'こ�E頁E��'}は$min斁E��以上で入力してください';
    }
    return null;
  }

  /// 最大斁E��数
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '${fieldName ?? 'こ�E頁E��'}は$max斁E��以冁E��入力してください';
    }
    return null;
  }

  /// メールアドレス
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '有効なメールアドレスを�E力してください';
    }
    return null;
  }

  /// パスワード（最封E斁E��、英数字含む�E�E
  static String? password(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8) {
      return 'パスワード�E8斁E��以上で入力してください';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'パスワード�E英字と数字を含む忁E��がありまぁE;
    }
    return null;
  }

  /// パスワード確誁E
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) return null;
    if (value != originalPassword) {
      return 'パスワードが一致しません';
    }
    return null;
  }

  /// 数値
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null && double.tryParse(value) == null) {
      return '${fieldName ?? 'こ�E頁E��'}は数値で入力してください';
    }
    return null;
  }

  /// 整数
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'こ�E頁E��'}は整数で入力してください';
    }
    return null;
  }

  /// 篁E���E�数値�E�E
  static String? range(String? value, num min, num max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return '${fieldName ?? 'こ�E頁E��'}は数値で入力してください';
    }
    if (numValue < min || numValue > max) {
      return '${fieldName ?? 'こ�E頁E��'}は$min、Emaxの篁E��で入力してください';
    }
    return null;
  }

  /// URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return '有効なURLを�E力してください';
    }
    return null;
  }

  /// 電話番号�E�日本�E�E
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^0\d{9,10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[-\s]'), ''))) {
      return '有効な電話番号を�E力してください';
    }
    return null;
  }

  /// 郵便番号�E�日本�E�E
  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) return null;
    final postalRegex = RegExp(r'^\d{3}-?\d{4}$');
    if (!postalRegex.hasMatch(value)) {
      return '有効な郵便番号を�E力してください�E�侁E 123-4567�E�E;
    }
    return null;
  }

  /// カスタムバリチE�Eション
  static String? custom(
    String? value,
    bool Function(String?) validator,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) return null;
    if (!validator(value)) {
      return errorMessage;
    }
    return null;
  }

  /// 褁E��のバリチE�Eションを絁E��合わぁE
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// バリチE�Eション付きチE��ストフィールチE
class ValidatedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const ValidatedTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabled: enabled,
        // エラーメチE��ージは下部に表示
        errorMaxLines: 2,
        // ヘルパ�EチE��ストとエラーチE��スト�Eスタイル統一
        helperStyle: Theme.of(context).textTheme.bodySmall,
        errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    );
  }
}

/// インラインバリチE�Eション付きチE��ストフィールチE
class InlineValidatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showValidationIcon;

  const InlineValidatedTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.showValidationIcon = true,
  });

  @override
  State<InlineValidatedTextField> createState() =>
      _InlineValidatedTextFieldState();
}

class _InlineValidatedTextFieldState extends State<InlineValidatedTextField> {
  String? _errorMessage;
  bool _isValid = false;
  bool _hasInteracted = false;

  void _validate(String value) {
    if (!_hasInteracted && value.isEmpty) return;

    setState(() {
      _hasInteracted = true;
      _errorMessage = widget.validator?.call(value);
      _isValid = _errorMessage == null && value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.showValidationIcon && _hasInteracted
                ? _isValid
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : _errorMessage != null
                        ? Icon(Icons.error, color: colorScheme.error)
                        : widget.suffixIcon
                : widget.suffixIcon,
            // エラー時�E枠線色
            enabledBorder: _errorMessage != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error),
                  )
                : null,
            focusedBorder: _errorMessage != null
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  )
                : null,
          ),
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          onChanged: _validate,
        ),
        // エラーメチE��ージを行�Eに表示
        if (_errorMessage != null) ...[
          SpacingSystem.vSpaceXS,
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: colorScheme.error,
              ),
              SpacingSystem.hSpaceXS,
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// フォームフィールドラチE��ー
class FormFieldWrapper extends StatelessWidget {
  final String? label;
  final bool required;
  final Widget child;
  final String? errorMessage;
  final String? helperText;

  const FormFieldWrapper({
    super.key,
    this.label,
    this.required = false,
    required this.child,
    this.errorMessage,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ラベル
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: theme.textTheme.titleSmall,
              ),
              if (required) ...[
                SpacingSystem.hSpaceXS,
                Text(
                  '*',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
          SpacingSystem.vSpaceXS,
        ],

        // フィールチE
        child,

        // ヘルパ�EチE��ストまた�EエラーメチE��ージ
        if (errorMessage != null || helperText != null) ...[
          SpacingSystem.vSpaceXS,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage != null)
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: colorScheme.error,
                )
              else if (helperText != null)
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              SpacingSystem.hSpaceXS,
              Expanded(
                child: Text(
                  errorMessage ?? helperText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: errorMessage != null
                        ? colorScheme.error
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
