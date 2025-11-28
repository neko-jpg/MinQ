import 'package:flutter/material.dart';

/// MinQ デザイントークン
/// アプリ全体で使用される基本的なデザイン要素を定義
class MinqTheme {
  const MinqTheme._();

  // カラートークン
  static const Color brandPrimary = Color(0xFF6366F1);
  static const Color brandSecondary = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);

  // スペーシングトークン
  static double spacing(int multiplier) => multiplier * 4.0;

  // コーナートークン
  static BorderRadius cornerSmall() => BorderRadius.circular(4);
  static BorderRadius cornerMedium() => BorderRadius.circular(8);
  static BorderRadius cornerLarge() => BorderRadius.circular(16);

  // タイポグラフィトークン
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
}

/// BuildContextの拡張でMinqThemeにアクセス
extension MinqThemeExtension on BuildContext {
  MinqTheme get tokens => const MinqTheme._();
}
