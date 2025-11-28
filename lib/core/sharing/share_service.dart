import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minq/core/sharing/ai_share_banner_service.dart';
import 'package:minq/core/sharing/ogp_image_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 共有サービス
class ShareService {
  final OgpImageGenerator? _ogpGenerator;
  final AIShareBannerService? _aiBannerService;

  ShareService({
    OgpImageGenerator? ogpGenerator,
    AIShareBannerService? aiBannerService,
  }) : _ogpGenerator = ogpGenerator,
       _aiBannerService = aiBannerService;

  /// テキストを共有
  Future<void> shareText({required String text, String? subject}) async {
      // ignore: deprecated_member_use
    await Share.share(text, subject: subject);
  }

  /// ファイルを共有
  Future<void> shareFile({
    required File file,
    String? text,
    String? subject,
  }) async {
      // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: text, subject: subject);
  }

  /// 複数ファイルを共有
  Future<void> shareFiles({
    required List<File> files,
    String? text,
    String? subject,
  }) async {
      // ignore: deprecated_member_use
    await Share.shareXFiles(
      files.map((f) => XFile(f.path)).toList(),
      text: text,
      subject: subject,
    );
  }

  /// ウィジェットを画像として共有
  Future<void> shareWidget({
    required GlobalKey key,
    String? text,
    String? filename,
  }) async {
    final image = await _captureWidget(key);
    if (image == null) return;

    final file = await _saveImage(image, filename ?? 'share.png');
    await shareFile(file: file, text: text);
  }

  /// クエスト達成をOGP画像付きで共有
  Future<void> shareAchievementWithOgp({
    required String questTitle,
    required int currentStreak,
    required int totalCompleted,
    String? additionalText,
  }) async {
    if (_ogpGenerator == null) {
      // OGPジェネレーターがない場合はテキストのみ共有
      await shareText(
        text: ShareTemplates.questAchievement(
          questTitle: questTitle,
          streak: currentStreak,
        ),
      );
      return;
    }

    final imageFile = await _ogpGenerator.generateAchievementBanner(
      questTitle: questTitle,
      currentStreak: currentStreak,
      totalCompleted: totalCompleted,
    );

    if (imageFile == null) {
      // 画像生成失敗時はテキストのみ共有
      await shareText(
        text: ShareTemplates.questAchievement(
          questTitle: questTitle,
          streak: currentStreak,
        ),
      );
      return;
    }

    final text =
        additionalText ??
        ShareTemplates.questAchievement(
          questTitle: questTitle,
          streak: currentStreak,
        );

    await shareFile(file: imageFile, text: text);
  }

  Future<void> shareAIGeneratedBanner({
    required String title,
    required String subtitle,
    String? text,
    int seed = 0,
  }) async {
    if (_aiBannerService == null) {
      await shareText(text: text ?? '$title\n$subtitle');
      return;
    }

    final bannerBytes = await _aiBannerService.buildBanner(
      title: title,
      subtitle: subtitle,
      seed: seed,
    );
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/miinq_ai_banner.png');
    await file.writeAsBytes(bannerBytes, flush: true);
    await shareFile(file: file, text: text ?? '$title\n$subtitle');
  }

  /// ウィジェットをキャプチャ
  Future<ui.Image?> _captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      return image;
    } catch (e) {
      debugPrint('❌ Failed to capture widget: $e');
      return null;
    }
  }

  /// 画像を保存
  Future<File> _saveImage(ui.Image image, String filename) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(buffer);

    return file;
  }
}

/// クエスト達成カード共有
class QuestAchievementShare {
  final ShareService _shareService;

  QuestAchievementShare(this._shareService);

  /// 達成カードを共有
  Future<void> shareAchievement({
    required GlobalKey cardKey,
    required String questTitle,
    required int streak,
  }) async {
    final text = '''
🎉 クエスト達成！

「$questTitle」を完了しました！
連続達成: $streak日

#MiniQuest #習慣化 #目標達成
''';

    await _shareService.shareWidget(
      key: cardKey,
      text: text,
      filename: 'quest_achievement.png',
    );
  }

  /// 統計を共有
  Future<void> shareStats({
    required GlobalKey statsKey,
    required int totalQuests,
    required int completedQuests,
    required double achievementRate,
  }) async {
    final text = '''
📊 今週の成果

完了クエスト: $completedQuests/$totalQuests
達成率: ${achievementRate.toStringAsFixed(1)}%

#MiniQuest #習慣化 #進捗
''';

    await _shareService.shareWidget(
      key: statsKey,
      text: text,
      filename: 'stats.png',
    );
  }

  /// ストリークを共有
  Future<void> shareStreak({
    required GlobalKey streakKey,
    required int streak,
    required String questTitle,
  }) async {
    final text = '''
🔥 $streak日連続達成！

「$questTitle」を$streak日連続で達成しました！

#MiniQuest #習慣化 #継続は力なり
''';

    await _shareService.shareWidget(
      key: streakKey,
      text: text,
      filename: 'streak.png',
    );
  }
}

/// 共有可能なカードウィジェット
class ShareableCard extends StatelessWidget {
  final GlobalKey cardKey;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const ShareableCard({
    super.key,
    required this.cardKey,
    required this.child,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: cardKey,
      child: Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

/// 共有テンプレート
class ShareTemplates {
  const ShareTemplates._();

  /// クエスト達成テンプレート
  static String questAchievement({
    required String questTitle,
    required int streak,
  }) {
    return '''
🎉 クエスト達成！

「$questTitle」を完了しました！
${streak > 1 ? '連続達成: $streak日\n' : ''}
#MiniQuest #習慣化 #目標達成
''';
  }

  /// 週次レポートテンプレート
  static String weeklyReport({
    required int completedQuests,
    required int totalQuests,
    required double achievementRate,
    required int activeDays,
  }) {
    return '''
📊 今週の成果

✅ 完了: $completedQuests/$totalQuests クエスト
📈 達成率: ${achievementRate.toStringAsFixed(1)}%
📅 アクティブ: $activeDays/7 日

#MiniQuest #習慣化 #週次レポート
''';
  }

  /// マイルストーンテンプレート
  static String milestone({
    required int totalCompletedQuests,
    required String milestone,
  }) {
    return '''
🏆 マイルストーン達成！

$totalCompletedQuests個のクエストを完了しました！
$milestone

#MiniQuest #習慣化 #マイルストーン
''';
  }

  /// ペア達成テンプレート
  static String pairAchievement({
    required String questTitle,
    required String pairName,
  }) {
    return '''
👥 ペアで達成！

$pairNameと一緒に「$questTitle」を完了しました！

#MiniQuest #習慣化 #ペア機能
''';
  }
}

/// 共有オプション
class ShareOptions {
  final bool includeImage;
  final bool includeText;
  final bool includeHashtags;
  final String? customMessage;

  const ShareOptions({
    this.includeImage = true,
    this.includeText = true,
    this.includeHashtags = true,
    this.customMessage,
  });

  /// デフォルトオプション
  static const defaultOptions = ShareOptions();

  /// 画像のみ
  static const imageOnly = ShareOptions(
    includeImage: true,
    includeText: false,
    includeHashtags: false,
  );

  /// テキストのみ
  static const textOnly = ShareOptions(
    includeImage: false,
    includeText: true,
    includeHashtags: true,
  );
}

/// 共有統計
class ShareStats {
  int _shareCount = 0;
  final Map<String, int> _shareTypeCount = {};

  /// 共有回数
  int get shareCount => _shareCount;

  /// 共有を記録
  void recordShare(String type) {
    _shareCount++;
    _shareTypeCount[type] = (_shareTypeCount[type] ?? 0) + 1;
  }

  /// タイプ別の共有回数
  int getShareCountByType(String type) {
    return _shareTypeCount[type] ?? 0;
  }

  /// 統計をリセット
  void reset() {
    _shareCount = 0;
    _shareTypeCount.clear();
  }

  /// 統計を取得
  Map<String, dynamic> getStats() {
    return {
      'totalShares': _shareCount,
      'sharesByType': Map.unmodifiable(_shareTypeCount),
    };
  }
}

/// 共有結果
enum ShareResult {
  /// 成功
  success,

  /// キャンセル
  cancelled,

  /// 失敗
  failed,
}

/// 共有コールバック
typedef ShareCallback = void Function(ShareResult result);

/// 共有ボタン
class ShareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  final IconData icon;

  const ShareButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.icon = Icons.share,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip ?? '共有',
      onPressed: onPressed,
    );
  }
}
