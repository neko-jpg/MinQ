import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:minq/core/accessibility/semantic_helpers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Accessible text field widget that adapts to accessibility settings
class AccessibleTextField extends ConsumerWidget {
  const AccessibleTextField({
    super.key,
    this.controller,
    required this.semanticLabel,
    this.semanticHint,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.validator,
  });

  final TextEditingController? controller;
  final String semanticLabel;
  final String? semanticHint;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final accessibilitySettings = ref.watch(accessibilityServiceProvider);
    
    // Calculate effective text size
    final effectiveTextSize = 16.0 * accessibilitySettings.textScale;
    
    // Get accessible colors
    final backgroundColor = accessibilitySettings.highContrast
        ? tokens.highContrastBackground
        : tokens.surfaceAlt;
    
    final borderColor = accessibilitySettings.highContrast
        ? tokens.highContrastText
        : tokens.border;
    
    final focusColor = accessibilitySettings.highContrast
        ? tokens.highContrastPrimary
        : tokens.brandPrimary;
    
    final textColor = accessibilitySettings.highContrast
        ? tokens.highContrastText
        : tokens.textPrimary;

    // Create input decoration with accessibility considerations
    final decoration = InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundColor,
      
      // Enhanced border for high contrast mode
      border: OutlineInputBorder(
        borderRadius: tokens.cornerMedium(),
        borderSide: BorderSide(
          color: borderColor,
          width: accessibilitySettings.highContrast ? 2 : 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: tokens.cornerMedium(),
        borderSide: BorderSide(
          color: borderColor,
          width: accessibilitySettings.highContrast ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: tokens.cornerMedium(),
        borderSide: BorderSide(
          color: focusColor,
          width: accessibilitySettings.highContrast ? 3 : 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: tokens.cornerMedium(),
        borderSide: BorderSide(
          color: tokens.accentError,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: tokens.cornerMedium(),
        borderSide: BorderSide(
          color: tokens.accentError,
          width: 3,
        ),
      ),
      
      // Accessible text styles
      labelStyle: TextStyle(
        fontSize: effectiveTextSize * 0.9,
        color: textColor,
        fontWeight: accessibilitySettings.boldText 
            ? FontWeight.bold 
            : FontWeight.normal,
      ),
      hintStyle: TextStyle(
        fontSize: effectiveTextSize * 0.9,
        color: tokens.textMuted,
        fontWeight: accessibilitySettings.boldText 
            ? FontWeight.w600 
            : FontWeight.normal,
      ),
      helperStyle: TextStyle(
        fontSize: effectiveTextSize * 0.8,
        color: tokens.textSecondary,
        fontWeight: accessibilitySettings.boldText 
            ? FontWeight.w600 
            : FontWeight.normal,
      ),
      errorStyle: TextStyle(
        fontSize: effectiveTextSize * 0.8,
        color: tokens.accentError,
        fontWeight: FontWeight.w600,
      ),
      
      // Enhanced padding for larger touch targets
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md * accessibilitySettings.buttonScale,
        vertical: tokens.spacing.sm * accessibilitySettings.buttonScale,
      ),
    );

    Widget textField = TextFormField(
      controller: controller,
      decoration: decoration,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: validator,
      style: TextStyle(
        fontSize: effectiveTextSize,
        color: textColor,
        fontWeight: accessibilitySettings.boldText 
            ? FontWeight.w600 
            : FontWeight.normal,
      ),
      onChanged: (value) {
        // Provide haptic feedback on text change if enabled
        if (accessibilitySettings.hapticFeedback && value.isNotEmpty) {
          ref.read(accessibilityServiceProvider.notifier).provideHapticFeedback();
        }
        onChanged?.call(value);
      },
      onFieldSubmitted: onSubmitted,
    );

    // Add focus indicator for keyboard navigation
    if (accessibilitySettings.focusIndicator) {
      textField = Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: hasFocus
                  ? BoxDecoration(
                      borderRadius: tokens.cornerMedium(),
                      boxShadow: [
                        BoxShadow(
                          color: focusColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    )
                  : null,
              child: textField,
            );
          },
        ),
      );
    }

    // Wrap with semantic helpers
    return SemanticHelpers.accessibleTextField(
      child: textField,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      semanticValue: controller?.text,
      obscureText: obscureText,
      multiline: maxLines != 1,
      readOnly: readOnly,
    );
  }
}

/// Accessible search field with enhanced features
class AccessibleSearchField extends ConsumerWidget {
  const AccessibleSearchField({
    super.key,
    this.controller,
    required this.semanticLabel,
    this.semanticHint,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String semanticLabel;
  final String? semanticHint;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final accessibilitySettings = ref.watch(accessibilityServiceProvider);
    
    return AccessibleTextField(
      controller: controller,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint ?? 'Enter search terms',
      hintText: hintText ?? 'Search...',
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: Icon(
        Icons.search,
        color: accessibilitySettings.highContrast
            ? tokens.highContrastText
            : tokens.textSecondary,
      ),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: accessibilitySettings.highContrast
                    ? tokens.highContrastText
                    : tokens.textSecondary,
              ),
              onPressed: () {
                controller?.clear();
                onClear?.call();
                ref.read(accessibilityServiceProvider.notifier)
                    .provideHapticFeedback();
              },
              tooltip: 'Clear search',
            )
          : null,
    );
  }
}

/// Accessible password field with visibility toggle
class AccessiblePasswordField extends ConsumerStatefulWidget {
  const AccessiblePasswordField({
    super.key,
    this.controller,
    required this.semanticLabel,
    this.semanticHint,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.validator,
  });

  final TextEditingController? controller;
  final String semanticLabel;
  final String? semanticHint;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? Function(String?)? validator;

  @override
  ConsumerState<AccessiblePasswordField> createState() => _AccessiblePasswordFieldState();
}

class _AccessiblePasswordFieldState extends ConsumerState<AccessiblePasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final accessibilitySettings = ref.watch(accessibilityServiceProvider);
    
    return AccessibleTextField(
      controller: widget.controller,
      semanticLabel: widget.semanticLabel,
      semanticHint: widget.semanticHint,
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      obscureText: _obscureText,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      validator: widget.validator,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.visiblePassword,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: accessibilitySettings.highContrast
              ? tokens.highContrastText
              : tokens.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
          ref.read(accessibilityServiceProvider.notifier)
              .provideHapticFeedback();
        },
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}