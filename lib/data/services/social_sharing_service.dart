import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:minq/domain/social/achievement_share.dart';

/// ソーシャルシェア機能を提供するサービス
class SocialSharingService {
  static const String _shareDirectory = 'minq_shares';

  /// 実績をソーシャルメディアにシェア
  Future<bool> shareAchievement(AchievementShare achievement) async {
    try {
      final imageFile = await _generateAchievementImage(achievement);
      if (imageFile == null) return false;

      final shareText = _generateShareText(achievement);
      
      // シェア機能のシミュレーション（実際のシェアは後で実装）
      debugPrint('Achievement shared: $shareText');
      debugPrint('Image saved at: ${imageFile.path}');

      return true;
    } catch (e) {
      debugPrint('Achievement sharing failed: $e');
      return false;
    }
  }

  /// 進捗をソーシャルメディアにシェア
  Future<bool> shareProgress(ProgressShare progress) async {
    try {
      final imageFile = await _generateProgressImage(progress);
      if (imageFile == null) return false;

      final shareText = _generateProgressShareText(progress);
      
      // シェア機能のシミュレーション（実際のシェアは後で実装）
      debugPrint('Progress shared: $shareText');
      debugPrint('Image saved at: ${imageFile.path}');

      return true;
    } catch (e) {
      debugPrint('Progress sharing failed: $e');
      return false;
    }
  }

  /// 実績画像を生成
  Future<File?> _generateAchievementImage(AchievementShare achievement) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(800, 600);

      // 背景を描画
      final backgroundPaint = Paint()..color = const Color(0xFF4ECDC4);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

      // グラデーション背景
      final gradient = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size.width, size.height),
        [
          const Color(0xFF4ECDC4),
          const Color(0xFF44A08D),
        ],
      );
      final gradientPaint = Paint()..shader = gradient;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);

      // タイトルを描画
      final titlePainter = TextPainter(
        text: TextSpan(
          text: achievement.title,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      titlePainter.layout(maxWidth: size.width - 80);
      titlePainter.paint(canvas, const Offset(40, 100));

      // 説明を描画
      final descriptionPainter = TextPainter(
        text: TextSpan(
          text: achievement.description,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white70,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      descriptionPainter.layout(maxWidth: size.width - 80);
      descriptionPainter.paint(canvas, const Offset(40, 200));

      // 統計情報を描画
      final statsPainter = TextPainter(
        text: TextSpan(
          text: '連続記録: ${achievement.currentStreak}日\n総クエスト: ${achievement.totalQuests}個',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      statsPainter.layout(maxWidth: size.width - 80);
      statsPainter.paint(canvas, const Offset(40, 350));

      // MinQロゴ/ブランディング
      final brandPainter = TextPainter(
        text: const TextSpan(
          text: 'MinQ',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      brandPainter.layout();
      brandPainter.paint(canvas, Offset(size.width - 120, size.height - 60));

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;

      return await _saveImageToFile(byteData.buffer.asUint8List(), 'achievement_${achievement.achievementId}');
    } catch (e) {
      debugPrint('Failed to generate achievement image: $e');
      return null;
    }
  }

  /// 進捗画像を生成
  Future<File?> _generateProgressImage(ProgressShare progress) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(800, 600);

      // 背景を描画
      final gradient = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size.width, size.height),
        [
          const Color(0xFFFFD700),
          const Color(0xFFFFA726),
        ],
      );
      final gradientPaint = Paint()..shader = gradient;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);

      // メインタイトル
      final titlePainter = TextPainter(
        text: const TextSpan(
          text: '習慣化を継続中！',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      titlePainter.layout(maxWidth: size.width - 80);
      titlePainter.paint(canvas, const Offset(40, 80));

      // 現在の連続記録（大きく表示）
      final streakPainter = TextPainter(
        text: TextSpan(
          text: '${progress.currentStreak}',
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      streakPainter.layout();
      streakPainter.paint(canvas, Offset((size.width - streakPainter.width) / 2, 180));

      // 「日連続」ラベル
      final daysPainter = TextPainter(
        text: const TextSpan(
          text: '日連続',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      daysPainter.layout();
      daysPainter.paint(canvas, Offset((size.width - daysPainter.width) / 2, 320));

      // その他の統計
      final statsPainter = TextPainter(
        text: TextSpan(
          text: 'ベスト記録: ${progress.bestStreak}日\n総クエスト: ${progress.totalQuests}個\n今日完了: ${progress.completedToday}個',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      statsPainter.layout(maxWidth: size.width - 80);
      statsPainter.paint(canvas, Offset((size.width - statsPainter.width) / 2, 400));

      // MinQブランディング
      final brandPainter = TextPainter(
        text: const TextSpan(
          text: 'MinQ',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      brandPainter.layout();
      brandPainter.paint(canvas, Offset(size.width - 100, size.height - 50));

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;

      return await _saveImageToFile(byteData.buffer.asUint8List(), 'progress_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      debugPrint('Failed to generate progress image: $e');
      return null;
    }
  }

  /// 画像をファイルに保存
  Future<File> _saveImageToFile(Uint8List imageBytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final shareDir = Directory('${directory.path}/$_shareDirectory');
    
    if (!await shareDir.exists()) {
      await shareDir.create(recursive: true);
    }

    final file = File('${shareDir.path}/$fileName.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// 実績シェア用のテキストを生成
  String _generateShareText(AchievementShare achievement) {
    final messages = [
      '${achievement.title}を達成しました！🎉',
      'MinQで習慣化を継続中💪',
      '連続記録: ${achievement.currentStreak}日',
      '#MinQ #習慣化 #継続は力なり',
    ];

    if (achievement.customMessage?.isNotEmpty == true) {
      messages.insert(1, achievement.customMessage!);
    }

    return messages.join('\n');
  }

  /// 進捗シェア用のテキストを生成
  String _generateProgressShareText(ProgressShare progress) {
    final messages = [
      '習慣化を${progress.currentStreak}日連続で継続中！🔥',
      'MinQで毎日コツコツ頑張ってます💪',
    ];

    if (progress.bestStreak > progress.currentStreak) {
      messages.add('ベスト記録は${progress.bestStreak}日！');
    }

    if (progress.motivationalMessage?.isNotEmpty == true) {
      messages.add(progress.motivationalMessage!);
    }

    messages.addAll([
      '#MinQ #習慣化 #継続は力なり #毎日コツコツ',
    ]);

    return messages.join('\n');
  }

  /// 一時ファイルをクリーンアップ
  Future<void> cleanupTempFiles() async {
    try {
      final directory = await getTemporaryDirectory();
      final shareDir = Directory('${directory.path}/$_shareDirectory');
      
      if (await shareDir.exists()) {
        await shareDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to cleanup temp files: $e');
    }
  }
}