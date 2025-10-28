import 'package:flutter/material.dart';

/// MinQ デザイントークン
/// アプリ全体で使用される基本的なデザイン要素を定義
class MinqTokens {
  const MinqTokens._();

  // カラートークン
  static const Color brandPrimary = Color(0xFF4F46E5);
  static const Color brandSecondary = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F6FB);

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

/// BuildContextの拡張でMinqTokensにアクセス
extension MinqTokensExtension on BuildContext {
  MinqTokens get tokens => const MinqTokens._();
}
