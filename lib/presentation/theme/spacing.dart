/// スペーシングユーティリティクラス
class Spacing {
  const Spacing._();

  // 基本スペーシング値
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // 動的スペーシング（倍数ベース）
  static double scale(double multiplier) => 4.0 * multiplier;
}
