import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:minq/core/ai/tflite_unified_ai_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// ハビットストーリー自動生成サービス
/// Instagram Stories風の美しいビジュアルストーリーを自動生成
class HabitStoryGenerator {
  static HabitStoryGenerator? _instance;
  static HabitStoryGenerator get instance =>
      _instance ??= HabitStoryGenerator._();

  HabitStoryGenerator._();

  final TFLiteUnifiedAIService _aiService = TFLiteUnifiedAIService.instance;

  bool _isGenerating = false;

  /// ストーリーの生成
  Future<HabitStory> generateStory({
    required StoryType type,
    required HabitProgressData progressData,
    StoryTemplate? customTemplate,
    StorySettings? settings,
  }) async {
    if (_isGenerating) {
      throw StateError('ストーリー生成中です。しばらくお待ちください。');
    }

    _isGenerating = true;

    try {
      log('HabitStory: ストーリー生成開始 - ${type.name}');

      await _aiService.initialize();

      // テンプレートの選択
      final template = customTemplate ?? _selectTemplate(type, progressData);

      // AIによるストーリーテキスト生成
      final storyText = await _generateStoryText(type, progressData, template);

      // ビジュアル要素の生成
      final visualElements = await _generateVisualElements(
        type,
        progressData,
        template,
      );

      // ストーリー画像の作成
      final storyImage = await _createStoryImage(
        template: template,
        storyText: storyText,
        visualElements: visualElements,
        settings: settings ?? const StorySettings(),
      );

      // 動画の作成（オプション）
      File? storyVideo;
      if (settings?.includeVideo == true) {
        storyVideo = await _createStoryVideo(storyImage, template, settings!);
      }

      final story = HabitStory(
        id: _generateStoryId(),
        type: type,
        title: storyText.title,
        content: storyText.content,
        template: template,
        visualElements: visualElements,
        imageFile: storyImage,
        videoFile: storyVideo,
        progressData: progressData,
        createdAt: DateTime.now(),
        shareUrl: null, // 後で生成
      );

      log('HabitStory: ストーリー生成完了');
      return story;
    } finally {
      _isGenerating = false;
    }
  }

  /// マイルストーンストーリーの生成
  Future<HabitStory> generateMilestoneStory({
    required MilestoneType milestone,
    required HabitProgressData progressData,
    StorySettings? settings,
  }) async {
    final type = _getMilestoneStoryType(milestone);

    return generateStory(
      type: type,
      progressData: progressData,
      settings: settings,
    );
  }

  /// 週次サマリーストーリーの生成
  Future<HabitStory> generateWeeklySummaryStory({
    required List<HabitProgressData> weeklyData,
    StorySettings? settings,
  }) async {
    // 週次データを統合
    final combinedData = _combineWeeklyData(weeklyData);

    return generateStory(
      type: StoryType.weeklySummary,
      progressData: combinedData,
      settings: settings,
    );
  }

  /// テンプレートの選択
  StoryTemplate _selectTemplate(StoryType type, HabitProgressData data) {
    switch (type) {
      case StoryType.dailyAchievement:
        return _getDailyAchievementTemplate(data);
      case StoryType.streakMilestone:
        return _getStreakMilestoneTemplate(data);
      case StoryType.weeklyProgress:
        return _getWeeklyProgressTemplate(data);
      case StoryType.monthlyReflection:
        return _getMonthlyReflectionTemplate(data);
      case StoryType.yearlyJourney:
        return _getYearlyJourneyTemplate(data);
      case StoryType.weeklySummary:
        return _getWeeklySummaryTemplate(data);
      case StoryType.motivational:
        return _getMotivationalTemplate(data);
      case StoryType.celebration:
        return _getCelebrationTemplate(data);
    }
  }

  /// AIストーリーテキストの生成
  Future<StoryText> _generateStoryText(
    StoryType type,
    HabitProgressData data,
    StoryTemplate template,
  ) async {
    try {
      final prompt = _buildStoryPrompt(type, data, template);

      final aiResponse = await _aiService.generateChatResponse(
        prompt,
        systemPrompt:
            'あなたは感動的なストーリーテラーです。ユーザーの習慣の成果を祝福し、励ましの言葉を込めた美しいストーリーを作成してください。',
        maxTokens: 200,
      );

      if (aiResponse.isNotEmpty && aiResponse.length > 20) {
        return _parseAIStoryResponse(aiResponse, type);
      }
    } catch (e) {
      log('HabitStory: AIテキスト生成エラー - $e');
    }

    return _getFallbackStoryText(type, data);
  }

  /// ストーリープロンプトの構築
  String _buildStoryPrompt(
    StoryType type,
    HabitProgressData data,
    StoryTemplate template,
  ) {
    switch (type) {
      case StoryType.dailyAchievement:
        return '''
今日の習慣達成について感動的なストーリーを作成してください：
- 習慣: ${data.habitTitle}
- 達成日数: ${data.currentStreak}日連続
- 今日の気分: ${data.todayMood}/5
- カテゴリ: ${data.category}

タイトル（10文字以内）と本文（50文字以内）で、達成感と継続への励ましを込めて作成してください。
''';

      case StoryType.streakMilestone:
        return '''
ストリーク達成の感動的なストーリーを作成してください：
- 習慣: ${data.habitTitle}
- 達成ストリーク: ${data.currentStreak}日
- 総実行回数: ${data.totalCompletions}回
- 開始日: ${data.startDate}

この継続力を称賛し、さらなる継続への意欲を高めるストーリーを作成してください。
''';

      case StoryType.weeklyProgress:
        return '''
週次進捗の振り返りストーリーを作成してください：
- 今週の完了率: ${(data.weeklyCompletionRate * 100).toStringAsFixed(0)}%
- アクティブな習慣: ${data.activeHabits}個
- 今週の気分平均: ${data.averageWeeklyMood.toStringAsFixed(1)}/5

今週の成果を振り返り、来週への前向きなメッセージを込めてください。
''';

      default:
        return '''
習慣継続の素晴らしい成果についてストーリーを作成してください：
- 習慣: ${data.habitTitle}
- 継続日数: ${data.currentStreak}日
- 成果: ${data.achievements.join(', ')}

ユーザーの努力を称賛し、継続への励ましを込めたストーリーを作成してください。
''';
    }
  }

  /// AI応答の解析
  StoryText _parseAIStoryResponse(String response, StoryType type) {
    final lines =
        response.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.length >= 2) {
      return StoryText(
        title: lines[0].trim(),
        content: lines.skip(1).join('\n').trim(),
        hashtags: _generateHashtags(type),
      );
    }

    return StoryText(
      title: _getDefaultTitle(type),
      content: response.trim(),
      hashtags: _generateHashtags(type),
    );
  }

  /// ビジュアル要素の生成
  Future<VisualElements> _generateVisualElements(
    StoryType type,
    HabitProgressData data,
    StoryTemplate template,
  ) async {
    return VisualElements(
      backgroundGradient: _selectBackgroundGradient(type, data),
      primaryColor: _selectPrimaryColor(data.category),
      accentColor: _selectAccentColor(data.category),
      iconEmoji: _selectIconEmoji(data.category),
      decorativeElements: _generateDecorativeElements(type, data),
      progressVisualization: _createProgressVisualization(data),
      moodVisualization: _createMoodVisualization(data),
    );
  }

  /// ストーリー画像の作成
  Future<File> _createStoryImage({
    required StoryTemplate template,
    required StoryText storyText,
    required VisualElements visualElements,
    required StorySettings settings,
  }) async {
    // カスタムペインターでストーリー画像を描画
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(settings.width.toDouble(), settings.height.toDouble());

    final painter = StoryPainter(
      template: template,
      storyText: storyText,
      visualElements: visualElements,
      settings: settings,
    );

    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(settings.width, settings.height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    // ファイルに保存
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/habit_story_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    return file;
  }

  /// ストーリー動画の作成（簡略版）
  Future<File?> _createStoryVideo(
    File imageFile,
    StoryTemplate template,
    StorySettings settings,
  ) async {
    try {
      // 実際の実装では、FFmpegやFlutter FFmpegを使用して動画を作成
      // ここでは簡略化してnullを返す
      log('HabitStory: 動画生成は未実装');
      return null;
    } catch (e) {
      log('HabitStory: 動画生成エラー - $e');
      return null;
    }
  }

  /// ストーリーの共有
  Future<void> shareStory(
    HabitStory story, {
    List<SharePlatform>? platforms,
  }) async {
    try {
      final files = <XFile>[];

      if (story.imageFile != null) {
        files.add(XFile(story.imageFile!.path));
      }

      if (story.videoFile != null) {
        files.add(XFile(story.videoFile!.path));
      }

      final shareText = '''
${story.title}

${story.content}

${story.visualElements.hashtags.join(' ')}

#MinQ #習慣形成 #継続力
''';

      if (files.isNotEmpty) {
        await Share.shareXFiles(files, text: shareText, subject: story.title);
      } else {
        await Share.share(shareText, subject: story.title);
      }

      log('HabitStory: ストーリー共有完了');
    } catch (e) {
      log('HabitStory: ストーリー共有エラー - $e');
    }
  }

  /// ストーリーのプレビュー
  Widget buildStoryPreview(HabitStory story, {double? width, double? height}) {
    return Container(
      width: width ?? 200,
      height: height ?? 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            story.imageFile != null
                ? Image.file(story.imageFile!, fit: BoxFit.cover)
                : Container(
                  decoration: BoxDecoration(
                    gradient: story.visualElements.backgroundGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          story.visualElements.iconEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          story.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  // ========== ヘルパーメソッド ==========

  String _generateStoryId() {
    return 'story_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  StoryType _getMilestoneStoryType(MilestoneType milestone) {
    switch (milestone) {
      case MilestoneType.firstWeek:
      case MilestoneType.firstMonth:
      case MilestoneType.hundredDays:
      case MilestoneType.oneYear:
        return StoryType.streakMilestone;
      case MilestoneType.perfectWeek:
        return StoryType.weeklyProgress;
      case MilestoneType.categoryMaster:
        return StoryType.celebration;
    }
  }

  HabitProgressData _combineWeeklyData(List<HabitProgressData> weeklyData) {
    if (weeklyData.isEmpty) {
      return HabitProgressData.empty();
    }

    final totalCompletions = weeklyData.fold(
      0,
      (sum, data) => sum + data.totalCompletions,
    );
    final averageMood =
        weeklyData.fold(0.0, (sum, data) => sum + data.averageWeeklyMood) /
        weeklyData.length;
    final allAchievements =
        weeklyData.expand((data) => data.achievements).toSet().toList();

    return HabitProgressData(
      habitTitle: '週次サマリー',
      category: 'summary',
      currentStreak: weeklyData.first.currentStreak,
      totalCompletions: totalCompletions,
      weeklyCompletionRate:
          weeklyData.fold(0.0, (sum, data) => sum + data.weeklyCompletionRate) /
          weeklyData.length,
      averageWeeklyMood: averageMood,
      todayMood: weeklyData.last.todayMood,
      activeHabits: weeklyData.length,
      achievements: allAchievements,
      startDate: weeklyData.first.startDate,
    );
  }

  // テンプレート生成メソッド
  StoryTemplate _getDailyAchievementTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'daily_achievement',
      layout: TemplateLayout.centered,
      backgroundStyle: BackgroundStyle.gradient,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      showProgress: true,
      showMood: true,
      animationDuration: const Duration(seconds: 3),
    );
  }

  StoryTemplate _getStreakMilestoneTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'streak_milestone',
      layout: TemplateLayout.celebration,
      backgroundStyle: BackgroundStyle.confetti,
      textStyle: const TextStyle(color: Colors.white, fontSize: 18),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      showProgress: true,
      showMood: false,
      animationDuration: const Duration(seconds: 5),
    );
  }

  StoryTemplate _getWeeklyProgressTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'weekly_progress',
      layout: TemplateLayout.chart,
      backgroundStyle: BackgroundStyle.minimal,
      textStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      titleStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      showProgress: true,
      showMood: true,
      animationDuration: const Duration(seconds: 4),
    );
  }

  StoryTemplate _getMonthlyReflectionTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'monthly_reflection',
      layout: TemplateLayout.timeline,
      backgroundStyle: BackgroundStyle.gradient,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      showProgress: true,
      showMood: true,
      animationDuration: const Duration(seconds: 6),
    );
  }

  StoryTemplate _getYearlyJourneyTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'yearly_journey',
      layout: TemplateLayout.journey,
      backgroundStyle: BackgroundStyle.stars,
      textStyle: const TextStyle(color: Colors.white, fontSize: 18),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      showProgress: true,
      showMood: true,
      animationDuration: const Duration(seconds: 8),
    );
  }

  StoryTemplate _getWeeklySummaryTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'weekly_summary',
      layout: TemplateLayout.grid,
      backgroundStyle: BackgroundStyle.gradient,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      showProgress: true,
      showMood: true,
      animationDuration: const Duration(seconds: 4),
    );
  }

  StoryTemplate _getMotivationalTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'motivational',
      layout: TemplateLayout.quote,
      backgroundStyle: BackgroundStyle.inspirational,
      textStyle: const TextStyle(color: Colors.white, fontSize: 18),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      showProgress: false,
      showMood: false,
      animationDuration: const Duration(seconds: 3),
    );
  }

  StoryTemplate _getCelebrationTemplate(HabitProgressData data) {
    return StoryTemplate(
      name: 'celebration',
      layout: TemplateLayout.celebration,
      backgroundStyle: BackgroundStyle.fireworks,
      textStyle: const TextStyle(color: Colors.white, fontSize: 20),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      showProgress: true,
      showMood: false,
      animationDuration: const Duration(seconds: 5),
    );
  }

  // ビジュアル要素生成メソッド
  LinearGradient _selectBackgroundGradient(
    StoryType type,
    HabitProgressData data,
  ) {
    switch (data.category) {
      case 'fitness':
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mindfulness':
        return const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'learning':
        return const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _selectPrimaryColor(String category) {
    switch (category) {
      case 'fitness':
        return const Color(0xFF667eea);
      case 'mindfulness':
        return const Color(0xFF4facfe);
      case 'learning':
        return const Color(0xFFf093fb);
      default:
        return const Color(0xFF43e97b);
    }
  }

  Color _selectAccentColor(String category) {
    switch (category) {
      case 'fitness':
        return const Color(0xFF764ba2);
      case 'mindfulness':
        return const Color(0xFF00f2fe);
      case 'learning':
        return const Color(0xFFf5576c);
      default:
        return const Color(0xFF38f9d7);
    }
  }

  String _selectIconEmoji(String category) {
    switch (category) {
      case 'fitness':
        return '💪';
      case 'mindfulness':
        return '🧘';
      case 'learning':
        return '📚';
      case 'health':
        return '🌱';
      case 'productivity':
        return '⚡';
      case 'creative':
        return '🎨';
      default:
        return '⭐';
    }
  }

  List<DecorativeElement> _generateDecorativeElements(
    StoryType type,
    HabitProgressData data,
  ) {
    switch (type) {
      case StoryType.celebration:
        return [
          DecorativeElement(
            type: ElementType.confetti,
            position: const Offset(0.5, 0.2),
          ),
          DecorativeElement(
            type: ElementType.sparkles,
            position: const Offset(0.8, 0.3),
          ),
          DecorativeElement(
            type: ElementType.stars,
            position: const Offset(0.2, 0.7),
          ),
        ];
      case StoryType.streakMilestone:
        return [
          DecorativeElement(
            type: ElementType.fire,
            position: const Offset(0.9, 0.1),
          ),
          DecorativeElement(
            type: ElementType.trophy,
            position: const Offset(0.1, 0.9),
          ),
        ];
      default:
        return [
          DecorativeElement(
            type: ElementType.sparkles,
            position: const Offset(0.9, 0.2),
          ),
        ];
    }
  }

  Widget _createProgressVisualization(HabitProgressData data) {
    return Container(
      width: 200,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withAlpha(77),
      ),
      child: FractionallySizedBox(
        widthFactor: data.weeklyCompletionRate,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _createMoodVisualization(HabitProgressData data) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < data.todayMood ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  List<String> _generateHashtags(StoryType type) {
    switch (type) {
      case StoryType.dailyAchievement:
        return ['#今日の成果', '#習慣継続', '#小さな積み重ね'];
      case StoryType.streakMilestone:
        return ['#ストリーク達成', '#継続力', '#習慣の力'];
      case StoryType.weeklyProgress:
        return ['#週次振り返り', '#成長記録', '#習慣形成'];
      default:
        return ['#習慣', '#継続', '#成長'];
    }
  }

  String _getDefaultTitle(StoryType type) {
    switch (type) {
      case StoryType.dailyAchievement:
        return '今日も達成！';
      case StoryType.streakMilestone:
        return 'ストリーク更新！';
      case StoryType.weeklyProgress:
        return '今週の成果';
      case StoryType.monthlyReflection:
        return '今月の振り返り';
      case StoryType.yearlyJourney:
        return '1年間の軌跡';
      case StoryType.weeklySummary:
        return '週次サマリー';
      case StoryType.motivational:
        return '継続の力';
      case StoryType.celebration:
        return 'お祝い！';
    }
  }

  StoryText _getFallbackStoryText(StoryType type, HabitProgressData data) {
    switch (type) {
      case StoryType.dailyAchievement:
        return StoryText(
          title: '今日も達成！',
          content:
              '${data.habitTitle}を${data.currentStreak}日連続で継続中！小さな積み重ねが大きな成果を生みます。',
          hashtags: _generateHashtags(type),
        );
      case StoryType.streakMilestone:
        return StoryText(
          title: '${data.currentStreak}日達成！',
          content:
              '${data.habitTitle}を${data.currentStreak}日間継続しました！この調子で更なる高みを目指しましょう。',
          hashtags: _generateHashtags(type),
        );
      default:
        return StoryText(
          title: '素晴らしい継続力！',
          content: '${data.habitTitle}の継続、お疲れさまです。あなたの努力が実を結んでいます。',
          hashtags: _generateHashtags(type),
        );
    }
  }
}

// ========== カスタムペインター ==========

class StoryPainter extends CustomPainter {
  final StoryTemplate template;
  final StoryText storyText;
  final VisualElements visualElements;
  final StorySettings settings;

  StoryPainter({
    required this.template,
    required this.storyText,
    required this.visualElements,
    required this.settings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 背景の描画
    _drawBackground(canvas, size);

    // テキストの描画
    _drawText(canvas, size);

    // 装飾要素の描画
    _drawDecorations(canvas, size);

    // プログレスの描画
    if (template.showProgress) {
      _drawProgress(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint();

    switch (template.backgroundStyle) {
      case BackgroundStyle.gradient:
        paint.shader = visualElements.backgroundGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
        break;
      case BackgroundStyle.solid:
        paint.color = visualElements.primaryColor;
        break;
      default:
        paint.shader = visualElements.backgroundGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawText(Canvas canvas, Size size) {
    // タイトルの描画
    final titlePainter = TextPainter(
      text: TextSpan(text: storyText.title, style: template.titleStyle),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: size.width * 0.8);

    final titleOffset = Offset(
      (size.width - titlePainter.width) / 2,
      size.height * 0.3,
    );
    titlePainter.paint(canvas, titleOffset);

    // コンテンツの描画
    final contentPainter = TextPainter(
      text: TextSpan(text: storyText.content, style: template.textStyle),
      textDirection: TextDirection.ltr,
    );
    contentPainter.layout(maxWidth: size.width * 0.8);

    final contentOffset = Offset(
      (size.width - contentPainter.width) / 2,
      size.height * 0.5,
    );
    contentPainter.paint(canvas, contentOffset);
  }

  void _drawDecorations(Canvas canvas, Size size) {
    for (final element in visualElements.decorativeElements) {
      _drawDecorativeElement(canvas, size, element);
    }
  }

  void _drawDecorativeElement(
    Canvas canvas,
    Size size,
    DecorativeElement element,
  ) {
    final paint = Paint()..color = Colors.white.withAlpha(204);
    final position = Offset(
      size.width * element.position.dx,
      size.height * element.position.dy,
    );

    switch (element.type) {
      case ElementType.sparkles:
        _drawSparkle(canvas, position, paint);
        break;
      case ElementType.stars:
        _drawStar(canvas, position, paint);
        break;
      case ElementType.confetti:
        _drawConfetti(canvas, position, paint);
        break;
      default:
        canvas.drawCircle(position, 5, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    path.moveTo(position.dx, position.dy - 8);
    path.lineTo(position.dx + 2, position.dy - 2);
    path.lineTo(position.dx + 8, position.dy);
    path.lineTo(position.dx + 2, position.dy + 2);
    path.lineTo(position.dx, position.dy + 8);
    path.lineTo(position.dx - 2, position.dy + 2);
    path.lineTo(position.dx - 8, position.dy);
    path.lineTo(position.dx - 2, position.dy - 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Offset position, Paint paint) {
    canvas.drawCircle(position, 6, paint);
  }

  void _drawConfetti(Canvas canvas, Offset position, Paint paint) {
    final rect = Rect.fromCenter(center: position, width: 8, height: 12);
    canvas.drawRect(rect, paint);
  }

  void _drawProgress(Canvas canvas, Size size) {
    // プログレスバーの描画（簡略版）
    final progressRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.8,
      size.width * 0.8,
      8,
    );

    final backgroundPaint = Paint()..color = Colors.white.withAlpha(77);
    canvas.drawRRect(
      RRect.fromRectAndRadius(progressRect, const Radius.circular(4)),
      backgroundPaint,
    );

    final progressPaint = Paint()..color = Colors.white;
    final progressWidth = progressRect.width * 0.7; // 仮の進捗
    final filledRect = Rect.fromLTWH(
      progressRect.left,
      progressRect.top,
      progressWidth,
      progressRect.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(filledRect, const Radius.circular(4)),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ========== データクラス ==========

/// ハビットストーリー
class HabitStory {
  final String id;
  final StoryType type;
  final String title;
  final String content;
  final StoryTemplate template;
  final VisualElements visualElements;
  final File? imageFile;
  final File? videoFile;
  final HabitProgressData progressData;
  final DateTime createdAt;
  final String? shareUrl;

  HabitStory({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.template,
    required this.visualElements,
    this.imageFile,
    this.videoFile,
    required this.progressData,
    required this.createdAt,
    this.shareUrl,
  });
}

/// 習慣進捗データ
class HabitProgressData {
  final String habitTitle;
  final String category;
  final int currentStreak;
  final int totalCompletions;
  final double weeklyCompletionRate;
  final double averageWeeklyMood;
  final int todayMood;
  final int activeHabits;
  final List<String> achievements;
  final DateTime startDate;

  HabitProgressData({
    required this.habitTitle,
    required this.category,
    required this.currentStreak,
    required this.totalCompletions,
    required this.weeklyCompletionRate,
    required this.averageWeeklyMood,
    required this.todayMood,
    required this.activeHabits,
    required this.achievements,
    required this.startDate,
  });

  factory HabitProgressData.empty() {
    return HabitProgressData(
      habitTitle: '',
      category: '',
      currentStreak: 0,
      totalCompletions: 0,
      weeklyCompletionRate: 0.0,
      averageWeeklyMood: 3.0,
      todayMood: 3,
      activeHabits: 0,
      achievements: [],
      startDate: DateTime.now(),
    );
  }
}

/// ストーリーテンプレート
class StoryTemplate {
  final String name;
  final TemplateLayout layout;
  final BackgroundStyle backgroundStyle;
  final TextStyle textStyle;
  final TextStyle titleStyle;
  final bool showProgress;
  final bool showMood;
  final Duration animationDuration;

  StoryTemplate({
    required this.name,
    required this.layout,
    required this.backgroundStyle,
    required this.textStyle,
    required this.titleStyle,
    required this.showProgress,
    required this.showMood,
    required this.animationDuration,
  });
}

/// ストーリーテキスト
class StoryText {
  final String title;
  final String content;
  final List<String> hashtags;

  StoryText({
    required this.title,
    required this.content,
    required this.hashtags,
  });
}

/// ビジュアル要素
class VisualElements {
  final LinearGradient backgroundGradient;
  final Color primaryColor;
  final Color accentColor;
  final String iconEmoji;
  final List<DecorativeElement> decorativeElements;
  final Widget progressVisualization;
  final Widget moodVisualization;
  final List<String> hashtags;

  VisualElements({
    required this.backgroundGradient,
    required this.primaryColor,
    required this.accentColor,
    required this.iconEmoji,
    required this.decorativeElements,
    required this.progressVisualization,
    required this.moodVisualization,
    this.hashtags = const [],
  });
}

/// 装飾要素
class DecorativeElement {
  final ElementType type;
  final Offset position;
  final double size;
  final Color color;

  DecorativeElement({
    required this.type,
    required this.position,
    this.size = 1.0,
    this.color = Colors.white,
  });
}

/// ストーリー設定
class StorySettings {
  final int width;
  final int height;
  final bool includeVideo;
  final bool includeMusic;
  final Duration videoDuration;
  final double quality;

  const StorySettings({
    this.width = 1080,
    this.height = 1920,
    this.includeVideo = false,
    this.includeMusic = false,
    this.videoDuration = const Duration(seconds: 5),
    this.quality = 1.0,
  });
}

/// 列挙型
enum StoryType {
  dailyAchievement,
  streakMilestone,
  weeklyProgress,
  monthlyReflection,
  yearlyJourney,
  weeklySummary,
  motivational,
  celebration,
}

enum MilestoneType {
  firstWeek,
  firstMonth,
  hundredDays,
  oneYear,
  perfectWeek,
  categoryMaster,
}

enum TemplateLayout {
  centered,
  celebration,
  chart,
  timeline,
  journey,
  grid,
  quote,
}

enum BackgroundStyle {
  gradient,
  solid,
  minimal,
  confetti,
  stars,
  fireworks,
  inspirational,
}

enum ElementType { sparkles, stars, confetti, fire, trophy, heart }

enum SharePlatform { instagram, twitter, facebook, line, general }
