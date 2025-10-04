import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/spacing_system.dart';

/// フォームバリデーションシステム - 統一されたバリデーションメッセージ
class FormValidation {
  const FormValidation._();

  // ========================================
  // バリデーションルール
  // ========================================

  /// 必須フィールド
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'この項目'}は必須です';
    }
    return null;
  }

  /// 最小文字数
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return '${fieldName ?? 'この項目'}は$min文字以上で入力してください';
    }
    return null;
  }

  /// 最大文字数
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '${fieldName ?? 'この項目'}は$max文字以内で入力してください';
    }
    return null;
  }

  /// メールアドレス
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '有効なメールアドレスを入力してください';
    }
    return null;
  }

  /// パスワード（最小8文字、英数字含む）
  static String? password(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'パスワードは英字と数字を含む必要があります';
    }
    return null;
  }

  /// パスワード確認
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
      return '${fieldName ?? 'この項目'}は数値で入力してください';
    }
    return null;
  }

  /// 整数
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'この項目'}は整数で入力してください';
    }
    return null;
  }

  /// 範囲（数値）
  static String? range(String? value, num min, num max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return '${fieldName ?? 'この項目'}は数値で入力してください';
    }
    if (numValue < min || numValue > max) {
      return '${fieldName ?? 'この項目'}は$min〜$maxの範囲で入力してください';
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
      return '有効なURLを入力してください';
    }
    return null;
  }

  /// 電話番号（日本）
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^0\d{9,10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[-\s]'), ''))) {
      return '有効な電話番号を入力してください';
    }
    return null;
  }

  /// 郵便番号（日本）
  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) return null;
    final postalRegex = RegExp(r'^\d{3}-?\d{4}$');
    if (!postalRegex.hasMatch(value)) {
      return '有効な郵便番号を入力してください（例: 123-4567）';
    }
    return null;
  }

  /// カスタムバリデーション
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

  /// 複数のバリデーションを組み合わせ
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

/// バリデーション付きテキストフィールド
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
        // エラーメッセージは下部に表示
        errorMaxLines: 2,
        // ヘルパーテキストとエラーテキストのスタイル統一
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

/// インラインバリデーション付きテキストフィールド
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
            // エラー時の枠線色
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
        // エラーメッセージを行内に表示
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

/// フォームフィールドラッパー
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

        // フィールド
        child,

        // ヘルパーテキストまたはエラーメッセージ
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
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              SpacingSystem.hSpaceXS,
              Expanded(
                child: Text(
                  errorMessage ?? helperText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: errorMessage != null
                        ? colorScheme.error
                        : colorScheme.onSurface.withOpacity(0.6),
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
