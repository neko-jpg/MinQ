import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/core/logging/app_logger.dart';

/// ニックネーム検証サービス
class NicknameValidator {
  final FirebaseFirestore _firestore;

  NicknameValidator({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ニックネームの重複チェック
  Future<NicknameValidationResult> validate(String nickname) async {
    // 空チェック
    if (nickname.trim().isEmpty) {
      return NicknameValidationResult.error('ニックネームを入力してください');
    }

    // 長さチェック
    if (nickname.length < 2) {
      return NicknameValidationResult.error('ニックネームは2文字以上で入力してください');
    }

    if (nickname.length > 20) {
      return NicknameValidationResult.error('ニックネームは20文字以内で入力してください');
    }

    // 禁止文字チェック
    if (_containsInvalidCharacters(nickname)) {
      return NicknameValidationResult.error('使用できない文字が含まれています');
    }

    // NGワードチェック
    if (_containsNGWords(nickname)) {
      return NicknameValidationResult.error('使用できないニックネームです');
    }

    // 重複チェック
    try {
      final isDuplicate = await _checkDuplicate(nickname);
      if (isDuplicate) {
        return NicknameValidationResult.error('このニックネームは既に使用されています');
      }

      return NicknameValidationResult.success();
    } catch (e, stack) {
      AppLogger.error(
        'Failed to validate nickname',
        error: e,
        stackTrace: stack,
      );
      return NicknameValidationResult.error('検証中にエラーが発生しました');
    }
  }

  /// 重複チェック
  Future<bool> _checkDuplicate(String nickname) async {
    final normalizedNickname = _normalize(nickname);

    final snapshot =
        await _firestore
            .collection('users')
            .where('nickname_normalized', isEqualTo: normalizedNickname)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// ニックネームを正規化（大文字小文字、全角半角を統一）
  String _normalize(String nickname) {
    return nickname.toLowerCase().replaceAll(RegExp(r'[Ａ-Ｚａ-ｚ０-９]'), (match) {
      // 全角英数字を半角に変換
      final char = match.group(0)!;
      return String.fromCharCode(char.codeUnitAt(0) - 0xFEE0);
    }).trim();
  }

  /// 禁止文字チェック
  bool _containsInvalidCharacters(String nickname) {
    // 制御文字、特殊記号などをチェック
    final invalidPattern = RegExp(r'[<>{}[\]\\|`^]');
    return invalidPattern.hasMatch(nickname);
  }

  /// NGワードチェック
  bool _containsNGWords(String nickname) {
    final ngWords = [
      'admin',
      'administrator',
      'moderator',
      'system',
      'official',
      'support',
      'minq',
      // 追加のNGワードをここに記載
    ];

    final normalizedNickname = _normalize(nickname);

    for (final ngWord in ngWords) {
      if (normalizedNickname.contains(ngWord.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  /// ニックネームの利用可能性をチェック（リアルタイム）
  Stream<bool> isAvailable(String nickname) {
    if (nickname.trim().isEmpty) {
      return Stream.value(false);
    }

    final normalizedNickname = _normalize(nickname);

    return _firestore
        .collection('users')
        .where('nickname_normalized', isEqualTo: normalizedNickname)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty);
  }
}

/// ニックネーム検証結果
class NicknameValidationResult {
  final bool isValid;
  final String? errorMessage;

  NicknameValidationResult._({required this.isValid, this.errorMessage});

  factory NicknameValidationResult.success() {
    return NicknameValidationResult._(isValid: true);
  }

  factory NicknameValidationResult.error(String message) {
    return NicknameValidationResult._(isValid: false, errorMessage: message);
  }
}
