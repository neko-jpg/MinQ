import 'package:flutter/material.dart';

@immutable
class SemanticColorScheme extends ThemeExtension<SemanticColorScheme> {
  const SemanticColorScheme({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  final Color? success;
  final Color? onSuccess;
  final Color? warning;
  final Color? onWarning;
  final Color? info;
  final Color? onInfo;

  @override
  SemanticColorScheme copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return SemanticColorScheme(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  SemanticColorScheme lerp(ThemeExtension<SemanticColorScheme>? other, double t) {
    if (other is! SemanticColorScheme) {
      return this;
    }
    return SemanticColorScheme(
      success: Color.lerp(success, other.success, t),
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t),
      warning: Color.lerp(warning, other.warning, t),
      onWarning: Color.lerp(onWarning, other.onWarning, t),
      info: Color.lerp(info, other.info, t),
      onInfo: Color.lerp(onInfo, other.onInfo, t),
    );
  }
}
