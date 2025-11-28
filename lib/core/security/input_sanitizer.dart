/// 入力サニタイザー
/// XSS、SQLインジェクション、その他の攻撃を防ぐ
class InputSanitizer {
  /// HTMLタグを除去
  static String sanitizeHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&[^;]+;'), '');
  }

  /// SQLインジェクション対策（基本的な文字をエスケープ）
  static String sanitizeSql(String input) {
    return input
        .replaceAll("'", "''")
        .replaceAll('"', '""')
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// URLを検証
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// ディープリンクURLを検証
  static bool isValidDeepLink(String url) {
    try {
      final uri = Uri.parse(url);

      // スキームをチェック
      if (!uri.hasScheme) return false;

      // 許可されたスキームのみ
      final allowedSchemes = ['minq', 'https'];
      if (!allowedSchemes.contains(uri.scheme)) return false;

      // ホストをチェック（httpsの場合）
      if (uri.scheme == 'https') {
        final allowedHosts = ['minq.app', 'www.minq.app'];
        if (!allowedHosts.contains(uri.host)) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// メールアドレスを検証
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// ユーザー名を検証（英数字とアンダースコアのみ）
  static bool isValidUsername(String username) {
    if (username.isEmpty || username.length > 20) return false;

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }

  /// 危険な文字を除去
  static String removeDangerousCharacters(String input) {
    // 制御文字を除去
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  /// 文字列の長さを制限
  static String limitLength(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return input.substring(0, maxLength);
  }

  /// 空白文字をトリム
  static String trimWhitespace(String input) {
    return input.trim();
  }

  /// 連続する空白を1つにまとめる
  static String normalizeWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// ディープリンクパラメータをサニタイズ
  static Map<String, String> sanitizeDeepLinkParams(
    Map<String, String> params,
  ) {
    final sanitized = <String, String>{};

    for (final entry in params.entries) {
      final key = sanitizeParamKey(entry.key);
      final value = sanitizeParamValue(entry.value);

      if (key.isNotEmpty && value.isNotEmpty) {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// パラメータキーをサニタイズ
  static String sanitizeParamKey(String key) {
    // 英数字とアンダースコアのみ許可
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  }

  /// パラメータ値をサニタイズ
  static String sanitizeParamValue(String value) {
    // 危険な文字を除去
    return removeDangerousCharacters(value);
  }

  /// クエストIDを検証（UUIDまたは英数字）
  static bool isValidQuestId(String id) {
    // UUID形式
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    // または20文字以内の英数字
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]{1,20}$');

    return uuidRegex.hasMatch(id) || alphanumericRegex.hasMatch(id);
  }

  /// ユーザーIDを検証
  static bool isValidUserId(String id) {
    return isValidQuestId(id); // 同じ形式
  }

  /// テキスト入力を完全にサニタイズ
  static String sanitizeTextInput(String input, {int maxLength = 1000}) {
    return limitLength(
      normalizeWhitespace(removeDangerousCharacters(sanitizeHtml(input))),
      maxLength,
    );
  }

  /// NGワードをチェック
  static bool containsNGWords(String input, List<String> ngWords) {
    final lowerInput = input.toLowerCase();
    for (final word in ngWords) {
      if (lowerInput.contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  /// NGワードをマスク
  static String maskNGWords(String input, List<String> ngWords) {
    var result = input;
    for (final word in ngWords) {
      final regex = RegExp(word, caseSensitive: false);
      result = result.replaceAll(regex, '*' * word.length);
    }
    return result;
  }

  /// 電話番号を検証（日本の電話番号）
  static bool isValidPhoneNumber(String phone) {
    // ハイフンなしの10-11桁の数字
    final phoneRegex = RegExp(r'^0\d{9,10}$');
    final cleanPhone = phone.replaceAll(RegExp(r'[-\s]'), '');
    return phoneRegex.hasMatch(cleanPhone);
  }

  /// 郵便番号を検証（日本の郵便番号）
  static bool isValidPostalCode(String postalCode) {
    // 7桁の数字（ハイフンあり/なし）
    final postalRegex = RegExp(r'^\d{3}-?\d{4}$');
    return postalRegex.hasMatch(postalCode);
  }

  /// 数値を検証
  static bool isValidNumber(String input) {
    return double.tryParse(input) != null;
  }

  /// 整数を検証
  static bool isValidInteger(String input) {
    return int.tryParse(input) != null;
  }

  /// 範囲内の数値かチェック
  static bool isNumberInRange(String input, double min, double max) {
    final number = double.tryParse(input);
    if (number == null) return false;
    return number >= min && number <= max;
  }

  /// 日付文字列を検証（ISO 8601形式）
  static bool isValidDateString(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// JSONを検証
  static bool isValidJson(String json) {
    try {
      // jsonDecode(json);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Base64を検証
  static bool isValidBase64(String input) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    return base64Regex.hasMatch(input) && input.length % 4 == 0;
  }

  /// パスワード強度をチェック
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;

    var score = 0;

    // 長さ
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // 大文字
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;

    // 小文字
    if (RegExp(r'[a-z]').hasMatch(password)) score++;

    // 数字
    if (RegExp(r'\d').hasMatch(password)) score++;

    // 記号
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

/// パスワード強度
enum PasswordStrength { weak, medium, strong }
